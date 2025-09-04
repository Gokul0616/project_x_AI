const express = require('express');
const { body, validationResult } = require('express-validator');
const { Conversation, Message } = require('../models/Message');
const User = require('../models/User');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// @route   GET /api/messages/conversations
// @desc    Get user's conversations
// @access  Private
router.get('/conversations', authMiddleware, async (req, res) => {
  try {
    const userId = req.user._id;
    const { page = 1, limit = 20 } = req.query;

    const conversations = await Conversation.find({
      participants: userId,
      'settings.archived': false
    })
    .populate([
      {
        path: 'participants',
        select: 'username displayName avatar isVerified',
        match: { _id: { $ne: userId } }
      },
      {
        path: 'lastMessage',
        populate: {
          path: 'sender',
          select: 'username displayName avatar'
        }
      }
    ])
    .sort({ lastActivity: -1 })
    .limit(limit * 1)
    .skip((page - 1) * limit);

    // Add unread count for each conversation
    const conversationsWithUnread = await Promise.all(
      conversations.map(async (conv) => {
        const unreadCount = await Message.countDocuments({
          conversation: conv._id,
          sender: { $ne: userId },
          readBy: { $not: { $elemMatch: { user: userId } } }
        });

        return {
          ...conv.toObject(),
          unreadCount
        };
      })
    );

    res.json({
      success: true,
      conversations: conversationsWithUnread,
      pagination: {
        currentPage: parseInt(page),
        hasMore: conversations.length === parseInt(limit)
      }
    });
  } catch (error) {
    console.error('Get conversations error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   POST /api/messages/conversations
// @desc    Create or get existing conversation
// @access  Private
router.post('/conversations', authMiddleware, [
  body('participantId')
    .isMongoId()
    .withMessage('Invalid participant ID')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { participantId } = req.body;
    const userId = req.user._id;

    if (userId.toString() === participantId) {
      return res.status(400).json({
        success: false,
        message: 'Cannot create conversation with yourself'
      });
    }

    // Check if participant exists
    const participant = await User.findById(participantId);
    if (!participant) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Check if conversation already exists
    let conversation = await Conversation.findOne({
      participants: { $all: [userId, participantId], $size: 2 },
      isGroup: false
    }).populate([
      {
        path: 'participants',
        select: 'username displayName avatar isVerified'
      },
      {
        path: 'lastMessage',
        populate: {
          path: 'sender',
          select: 'username displayName avatar'
        }
      }
    ]);

    // Create new conversation if doesn't exist
    if (!conversation) {
      conversation = new Conversation({
        participants: [userId, participantId]
      });
      await conversation.save();
      await conversation.populate([
        {
          path: 'participants',
          select: 'username displayName avatar isVerified'
        }
      ]);
    }

    res.json({
      success: true,
      conversation
    });
  } catch (error) {
    console.error('Create conversation error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/messages/conversations/:conversationId/messages
// @desc    Get messages in a conversation
// @access  Private
router.get('/conversations/:conversationId/messages', authMiddleware, async (req, res) => {
  try {
    const { conversationId } = req.params;
    const { page = 1, limit = 50 } = req.query;
    const userId = req.user._id;

    // Check if user is part of the conversation
    const conversation = await Conversation.findOne({
      _id: conversationId,
      participants: userId
    });

    if (!conversation) {
      return res.status(404).json({
        success: false,
        message: 'Conversation not found'
      });
    }

    const messages = await Message.find({
      conversation: conversationId,
      isDeleted: false,
      deletedFor: { $ne: userId }
    })
    .populate([
      {
        path: 'sender',
        select: 'username displayName avatar'
      },
      {
        path: 'replyTo',
        populate: {
          path: 'sender',
          select: 'username displayName'
        }
      },
      {
        path: 'sharedTweet',
        populate: {
          path: 'author',
          select: 'username displayName avatar isVerified'
        }
      }
    ])
    .sort({ createdAt: -1 })
    .limit(limit * 1)
    .skip((page - 1) * limit);

    // Mark messages as read
    await Message.updateMany(
      {
        conversation: conversationId,
        sender: { $ne: userId },
        readBy: { $not: { $elemMatch: { user: userId } } }
      },
      {
        $push: { readBy: { user: userId } }
      }
    );

    res.json({
      success: true,
      messages: messages.reverse(), // Reverse to get chronological order
      pagination: {
        currentPage: parseInt(page),
        hasMore: messages.length === parseInt(limit)
      }
    });
  } catch (error) {
    console.error('Get messages error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   POST /api/messages/conversations/:conversationId/messages
// @desc    Send a message
// @access  Private
router.post('/conversations/:conversationId/messages', authMiddleware, [
  body('content')
    .optional()
    .isLength({ min: 1, max: 1000 })
    .withMessage('Message content must be between 1 and 1000 characters'),
  body('messageType')
    .optional()
    .isIn(['text', 'image', 'video', 'gif', 'file', 'tweet_share'])
    .withMessage('Invalid message type')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { conversationId } = req.params;
    const { content, messageType = 'text', media, sharedTweet, replyTo } = req.body;
    const userId = req.user._id;

    // Check if user is part of the conversation
    const conversation = await Conversation.findOne({
      _id: conversationId,
      participants: userId
    });

    if (!conversation) {
      return res.status(404).json({
        success: false,
        message: 'Conversation not found'
      });
    }

    // Validate message content
    if (!content && !media && !sharedTweet) {
      return res.status(400).json({
        success: false,
        message: 'Message must have content, media, or shared tweet'
      });
    }

    const message = new Message({
      conversation: conversationId,
      sender: userId,
      content,
      messageType,
      media: media || [],
      sharedTweet,
      replyTo
    });

    await message.save();
    await message.populate([
      {
        path: 'sender',
        select: 'username displayName avatar'
      },
      {
        path: 'replyTo',
        populate: {
          path: 'sender',
          select: 'username displayName'
        }
      },
      {
        path: 'sharedTweet',
        populate: {
          path: 'author',
          select: 'username displayName avatar isVerified'
        }
      }
    ]);

    // Update conversation's last message and activity
    conversation.lastMessage = message._id;
    conversation.lastActivity = new Date();
    await conversation.save();

    // Emit real-time message to other participants
    const otherParticipants = conversation.participants.filter(
      p => !p.equals(userId)
    );

    otherParticipants.forEach(participantId => {
      req.io.to(`user-${participantId}`).emit('new-message', {
        conversationId,
        message,
        sender: req.user
      });
    });

    res.status(201).json({
      success: true,
      message: 'Message sent successfully',
      data: message
    });
  } catch (error) {
    console.error('Send message error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   PUT /api/messages/:messageId/reactions
// @desc    Add or remove reaction to message
// @access  Private
router.put('/:messageId/reactions', authMiddleware, [
  body('emoji')
    .notEmpty()
    .withMessage('Emoji is required')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { messageId } = req.params;
    const { emoji } = req.body;
    const userId = req.user._id;

    const message = await Message.findById(messageId);
    if (!message) {
      return res.status(404).json({
        success: false,
        message: 'Message not found'
      });
    }

    // Check if user is part of the conversation
    const conversation = await Conversation.findOne({
      _id: message.conversation,
      participants: userId
    });

    if (!conversation) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized'
      });
    }

    const existingReaction = message.reactions.find(
      r => r.user.equals(userId) && r.emoji === emoji
    );

    if (existingReaction) {
      message.removeReaction(userId, emoji);
    } else {
      message.addReaction(userId, emoji);
    }

    await message.save();

    // Emit real-time reaction update
    const otherParticipants = conversation.participants.filter(
      p => !p.equals(userId)
    );

    otherParticipants.forEach(participantId => {
      req.io.to(`user-${participantId}`).emit('message-reaction', {
        messageId,
        userId,
        emoji,
        action: existingReaction ? 'remove' : 'add'
      });
    });

    res.json({
      success: true,
      message: 'Reaction updated',
      reactions: message.reactions
    });
  } catch (error) {
    console.error('Message reaction error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   DELETE /api/messages/:messageId
// @desc    Delete a message
// @access  Private
router.delete('/:messageId', authMiddleware, async (req, res) => {
  try {
    const { messageId } = req.params;
    const { deleteFor = 'me' } = req.body; // 'me' or 'everyone'
    const userId = req.user._id;

    const message = await Message.findById(messageId);
    if (!message) {
      return res.status(404).json({
        success: false,
        message: 'Message not found'
      });
    }

    // Check if user is authorized
    if (!message.sender.equals(userId)) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete this message'
      });
    }

    if (deleteFor === 'everyone') {
      message.isDeleted = true;
      message.deletedAt = new Date();
    } else {
      // Delete for current user only
      if (!message.deletedFor.includes(userId)) {
        message.deletedFor.push(userId);
      }
    }

    await message.save();

    // Emit real-time message deletion
    if (deleteFor === 'everyone') {
      const conversation = await Conversation.findById(message.conversation);
      const otherParticipants = conversation.participants.filter(
        p => !p.equals(userId)
      );

      otherParticipants.forEach(participantId => {
        req.io.to(`user-${participantId}`).emit('message-deleted', {
          messageId,
          conversationId: message.conversation
        });
      });
    }

    res.json({
      success: true,
      message: 'Message deleted successfully'
    });
  } catch (error) {
    console.error('Delete message error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/messages/unread-count
// @desc    Get total unread messages count
// @access  Private
router.get('/unread-count', authMiddleware, async (req, res) => {
  try {
    const userId = req.user._id;

    const conversations = await Conversation.find({
      participants: userId
    }).select('_id');

    const conversationIds = conversations.map(c => c._id);

    const unreadCount = await Message.countDocuments({
      conversation: { $in: conversationIds },
      sender: { $ne: userId },
      readBy: { $not: { $elemMatch: { user: userId } } }
    });

    res.json({
      success: true,
      unreadCount
    });
  } catch (error) {
    console.error('Get unread count error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

module.exports = router;