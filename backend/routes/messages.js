const express = require('express');
const { body, query, validationResult } = require('express-validator');
const { Message, Conversation } = require('../models/Message');
const User = require('../models/User');
const { auth } = require('../middleware/auth');

const router = express.Router();

// Get user's conversations
router.get('/conversations', auth, [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 50 }).withMessage('Limit must be between 1 and 50')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const conversations = await Conversation.find({
      participants: req.user._id
    })
    .populate('participants', 'username displayName profileImageUrl isVerified isOnline lastActive')
    .populate({
      path: 'lastMessage',
      populate: {
        path: 'sender',
        select: 'username displayName'
      }
    })
    .sort({ lastActivity: -1 })
    .skip(skip)
    .limit(limit);

    // Add unread count for each conversation
    const conversationsWithUnread = conversations.map(conv => {
      const unreadCount = conv.unreadCounts.find(
        uc => uc.user.toString() === req.user._id.toString()
      )?.count || 0;

      return {
        ...conv.toObject(),
        unreadCount
      };
    });

    const totalConversations = await Conversation.countDocuments({
      participants: req.user._id
    });

    res.json({
      conversations: conversationsWithUnread,
      pagination: {
        currentPage: page,
        totalPages: Math.ceil(totalConversations / limit),
        totalConversations,
        hasNext: page * limit < totalConversations,
        hasPrev: page > 1
      }
    });
  } catch (error) {
    console.error('Get conversations error:', error);
    res.status(500).json({ error: 'Failed to fetch conversations' });
  }
});

// Get messages in a conversation
router.get('/conversations/:id/messages', auth, [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const conversationId = req.params.id;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 50;
    const skip = (page - 1) * limit;

    // Check if user is part of the conversation
    const conversation = await Conversation.findOne({
      _id: conversationId,
      participants: req.user._id
    });

    if (!conversation) {
      return res.status(404).json({ error: 'Conversation not found or access denied' });
    }

    const messages = await Message.find({
      conversation: conversationId,
      isDeleted: false,
      deletedBy: { $not: { $elemMatch: { user: req.user._id } } }
    })
    .populate('sender', 'username displayName profileImageUrl')
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(limit);

    const totalMessages = await Message.countDocuments({
      conversation: conversationId,
      isDeleted: false,
      deletedBy: { $not: { $elemMatch: { user: req.user._id } } }
    });

    // Mark messages as read
    await Message.updateMany(
      {
        conversation: conversationId,
        recipient: req.user._id,
        isRead: false
      },
      {
        isRead: true,
        readAt: new Date()
      }
    );

    // Reset unread count for this user in the conversation
    await Conversation.updateOne(
      { _id: conversationId },
      { $set: { 'unreadCounts.$[elem].count': 0 } },
      { arrayFilters: [{ 'elem.user': req.user._id }] }
    );

    res.json({
      messages: messages.reverse(), // Return in chronological order
      conversation,
      pagination: {
        currentPage: page,
        totalPages: Math.ceil(totalMessages / limit),
        totalMessages,
        hasNext: page * limit < totalMessages,
        hasPrev: page > 1
      }
    });
  } catch (error) {
    console.error('Get messages error:', error);
    res.status(500).json({ error: 'Failed to fetch messages' });
  }
});

// Send a message
router.post('/conversations/:id/messages', auth, [
  body('content')
    .isLength({ min: 1, max: 1000 })
    .withMessage('Message content must be between 1 and 1000 characters'),
  body('mediaUrl')
    .optional()
    .isURL()
    .withMessage('Media URL must be valid'),
  body('mediaType')
    .optional()
    .isIn(['image', 'video', 'gif'])
    .withMessage('Media type must be image, video, or gif')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const conversationId = req.params.id;
    const { content, mediaUrl, mediaType } = req.body;

    // Check if user is part of the conversation
    const conversation = await Conversation.findOne({
      _id: conversationId,
      participants: req.user._id
    });

    if (!conversation) {
      return res.status(404).json({ error: 'Conversation not found or access denied' });
    }

    // Get recipient (other participant)
    const recipient = conversation.participants.find(
      p => p.toString() !== req.user._id.toString()
    );

    // Create message
    const message = new Message({
      sender: req.user._id,
      recipient,
      content,
      mediaUrl,
      mediaType,
      conversation: conversationId
    });

    await message.save();

    // Update conversation
    conversation.lastMessage = message._id;
    conversation.lastActivity = new Date();

    // Increment unread count for recipient
    const recipientUnreadIndex = conversation.unreadCounts.findIndex(
      uc => uc.user.toString() === recipient.toString()
    );

    if (recipientUnreadIndex !== -1) {
      conversation.unreadCounts[recipientUnreadIndex].count += 1;
    } else {
      conversation.unreadCounts.push({
        user: recipient,
        count: 1
      });
    }

    await conversation.save();

    // Populate and return the message
    const populatedMessage = await Message.findById(message._id)
      .populate('sender', 'username displayName profileImageUrl');

    res.status(201).json({
      message: 'Message sent successfully',
      data: populatedMessage
    });
  } catch (error) {
    console.error('Send message error:', error);
    res.status(500).json({ error: 'Failed to send message' });
  }
});

// Start a new conversation
router.post('/conversations', auth, [
  body('username')
    .notEmpty()
    .withMessage('Username is required')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { username } = req.body;

    // Find the user to start conversation with
    const otherUser = await User.findOne({ username });
    if (!otherUser) {
      return res.status(404).json({ error: 'User not found' });
    }

    if (otherUser._id.toString() === req.user._id.toString()) {
      return res.status(400).json({ error: 'Cannot start conversation with yourself' });
    }

    // Find or create conversation
    const conversation = await Conversation.findOrCreateConversation([
      req.user._id,
      otherUser._id
    ]);

    // Populate conversation
    const populatedConversation = await Conversation.findById(conversation._id)
      .populate('participants', 'username displayName profileImageUrl isVerified isOnline lastActive')
      .populate({
        path: 'lastMessage',
        populate: {
          path: 'sender',
          select: 'username displayName'
        }
      });

    res.json({
      message: 'Conversation ready',
      conversation: populatedConversation
    });
  } catch (error) {
    console.error('Start conversation error:', error);
    res.status(500).json({ error: 'Failed to start conversation' });
  }
});

// Delete a message
router.delete('/messages/:id', auth, async (req, res) => {
  try {
    const message = await Message.findById(req.params.id);
    
    if (!message) {
      return res.status(404).json({ error: 'Message not found' });
    }

    // Check if user is sender or recipient
    if (message.sender.toString() !== req.user._id.toString() && 
        message.recipient.toString() !== req.user._id.toString()) {
      return res.status(403).json({ error: 'Not authorized to delete this message' });
    }

    // Add user to deletedBy array (soft delete)
    if (!message.deletedBy.some(d => d.user.toString() === req.user._id.toString())) {
      message.deletedBy.push({ user: req.user._id });
    }

    // If both users have deleted, mark as deleted
    if (message.deletedBy.length >= 2) {
      message.isDeleted = true;
    }

    await message.save();

    res.json({ message: 'Message deleted successfully' });
  } catch (error) {
    console.error('Delete message error:', error);
    res.status(500).json({ error: 'Failed to delete message' });
  }
});

module.exports = router;