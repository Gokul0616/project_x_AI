const express = require('express');
const multer = require('multer');
const sharp = require('sharp');
const path = require('path');
const fs = require('fs').promises;
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// Ensure upload directory exists
const uploadDir = path.join(__dirname, '../uploads');
const ensureUploadDir = async () => {
  try {
    await fs.access(uploadDir);
  } catch {
    await fs.mkdir(uploadDir, { recursive: true });
  }
};

// Configure multer for file upload
const storage = multer.diskStorage({
  destination: async (req, file, cb) => {
    await ensureUploadDir();
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const extension = path.extname(file.originalname);
    cb(null, `${file.fieldname}-${uniqueSuffix}${extension}`);
  }
});

const fileFilter = (req, file, cb) => {
  // Check file type
  if (file.fieldname === 'avatar' || file.fieldname === 'banner') {
    // For profile images
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed for profile pictures'), false);
    }
  } else if (file.fieldname === 'media') {
    // For tweet media
    if (file.mimetype.startsWith('image/') || file.mimetype.startsWith('video/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image and video files are allowed'), false);
    }
  } else {
    cb(new Error('Invalid field name'), false);
  }
};

const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 5 * 1024 * 1024, // 5MB default
    files: 4 // Maximum 4 files per request
  }
});

// @route   POST /api/upload/profile/avatar
// @desc    Upload profile avatar
// @access  Private
router.post('/profile/avatar', authMiddleware, upload.single('avatar'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No file uploaded'
      });
    }

    const { filename, path: filePath } = req.file;
    
    // Process image with sharp
    const processedFilename = `processed-${filename}`;
    const processedPath = path.join(uploadDir, processedFilename);

    await sharp(filePath)
      .resize(400, 400, {
        fit: 'cover',
        position: 'centre'
      })
      .jpeg({
        quality: 85,
        progressive: true
      })
      .toFile(processedPath);

    // Delete original file
    await fs.unlink(filePath);

    // Update user avatar URL
    const User = require('../models/User');
    const avatarUrl = `/uploads/${processedFilename}`;
    
    await User.findByIdAndUpdate(req.user._id, { avatar: avatarUrl });

    res.json({
      success: true,
      message: 'Avatar uploaded successfully',
      avatarUrl
    });
  } catch (error) {
    console.error('Avatar upload error:', error);
    
    // Clean up files on error
    if (req.file) {
      try {
        await fs.unlink(req.file.path);
      } catch (unlinkError) {
        console.error('Error deleting file:', unlinkError);
      }
    }

    res.status(500).json({
      success: false,
      message: 'Error uploading avatar'
    });
  }
});

// @route   POST /api/upload/profile/banner
// @desc    Upload profile banner
// @access  Private
router.post('/profile/banner', authMiddleware, upload.single('banner'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No file uploaded'
      });
    }

    const { filename, path: filePath } = req.file;
    
    // Process image with sharp
    const processedFilename = `processed-${filename}`;
    const processedPath = path.join(uploadDir, processedFilename);

    await sharp(filePath)
      .resize(1500, 500, {
        fit: 'cover',
        position: 'centre'
      })
      .jpeg({
        quality: 85,
        progressive: true
      })
      .toFile(processedPath);

    // Delete original file
    await fs.unlink(filePath);

    // Update user banner URL
    const User = require('../models/User');
    const bannerUrl = `/uploads/${processedFilename}`;
    
    await User.findByIdAndUpdate(req.user._id, { banner: bannerUrl });

    res.json({
      success: true,
      message: 'Banner uploaded successfully',
      bannerUrl
    });
  } catch (error) {
    console.error('Banner upload error:', error);
    
    // Clean up files on error
    if (req.file) {
      try {
        await fs.unlink(req.file.path);
      } catch (unlinkError) {
        console.error('Error deleting file:', unlinkError);
      }
    }

    res.status(500).json({
      success: false,
      message: 'Error uploading banner'
    });
  }
});

// @route   POST /api/upload/tweet/media
// @desc    Upload media for tweets
// @access  Private
router.post('/tweet/media', authMiddleware, upload.array('media', 4), async (req, res) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No files uploaded'
      });
    }

    const processedFiles = [];

    for (const file of req.files) {
      const { filename, path: filePath, mimetype } = file;

      if (mimetype.startsWith('image/')) {
        // Process image
        const processedFilename = `processed-${filename}`;
        const processedPath = path.join(uploadDir, processedFilename);

        const metadata = await sharp(filePath)
          .resize(2048, 2048, {
            fit: 'inside',
            withoutEnlargement: true
          })
          .jpeg({
            quality: 85,
            progressive: true
          })
          .toFile(processedPath);

        // Delete original file
        await fs.unlink(filePath);

        processedFiles.push({
          type: 'image',
          url: `/uploads/${processedFilename}`,
          width: metadata.width,
          height: metadata.height,
          alt: `Image uploaded by ${req.user.username}`
        });
      } else if (mimetype.startsWith('video/')) {
        // For videos, just move the file (in production, you might want to use ffmpeg for processing)
        const videoUrl = `/uploads/${filename}`;
        
        processedFiles.push({
          type: 'video',
          url: videoUrl,
          alt: `Video uploaded by ${req.user.username}`
        });
      }
    }

    res.json({
      success: true,
      message: 'Media uploaded successfully',
      media: processedFiles
    });
  } catch (error) {
    console.error('Media upload error:', error);
    
    // Clean up files on error
    if (req.files) {
      for (const file of req.files) {
        try {
          await fs.unlink(file.path);
        } catch (unlinkError) {
          console.error('Error deleting file:', unlinkError);
        }
      }
    }

    res.status(500).json({
      success: false,
      message: 'Error uploading media'
    });
  }
});

// @route   POST /api/upload/community/avatar
// @desc    Upload community avatar
// @access  Private
router.post('/community/avatar', authMiddleware, upload.single('avatar'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No file uploaded'
      });
    }

    const { communityId } = req.body;
    if (!communityId) {
      return res.status(400).json({
        success: false,
        message: 'Community ID is required'
      });
    }

    const { filename, path: filePath } = req.file;
    
    // Process image with sharp
    const processedFilename = `processed-${filename}`;
    const processedPath = path.join(uploadDir, processedFilename);

    await sharp(filePath)
      .resize(200, 200, {
        fit: 'cover',
        position: 'centre'
      })
      .jpeg({
        quality: 85,
        progressive: true
      })
      .toFile(processedPath);

    // Delete original file
    await fs.unlink(filePath);

    // Update community avatar URL
    const Community = require('../models/Community');
    const community = await Community.findById(communityId);
    
    if (!community) {
      return res.status(404).json({
        success: false,
        message: 'Community not found'
      });
    }

    // Check if user is moderator
    if (!community.isModerator(req.user._id) && !community.creator.equals(req.user._id)) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to update community avatar'
      });
    }

    const avatarUrl = `/uploads/${processedFilename}`;
    community.avatar = avatarUrl;
    await community.save();

    res.json({
      success: true,
      message: 'Community avatar uploaded successfully',
      avatarUrl
    });
  } catch (error) {
    console.error('Community avatar upload error:', error);
    
    // Clean up files on error
    if (req.file) {
      try {
        await fs.unlink(req.file.path);
      } catch (unlinkError) {
        console.error('Error deleting file:', unlinkError);
      }
    }

    res.status(500).json({
      success: false,
      message: 'Error uploading community avatar'
    });
  }
});

// @route   DELETE /api/upload/:filename
// @desc    Delete uploaded file
// @access  Private
router.delete('/:filename', authMiddleware, async (req, res) => {
  try {
    const { filename } = req.params;
    const filePath = path.join(uploadDir, filename);

    // Check if file exists
    try {
      await fs.access(filePath);
    } catch {
      return res.status(404).json({
        success: false,
        message: 'File not found'
      });
    }

    // Delete file
    await fs.unlink(filePath);

    res.json({
      success: true,
      message: 'File deleted successfully'
    });
  } catch (error) {
    console.error('Delete file error:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting file'
    });
  }
});

module.exports = router;