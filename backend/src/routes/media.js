const express = require('express');
const MediaService = require('../services/mediaService');
const CdnService = require('../services/cdnService');
const auth = require('../middleware/auth');

const router = express.Router();
const mediaService = new MediaService();
const cdnService = new CdnService();

// Upload video
router.post('/upload', auth, mediaService.getUploadMiddleware().single('video'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'No video file provided' });
    }

    const uploadResult = await mediaService.uploadToS3(req.file, req.user.id);
    
    if (!uploadResult.success) {
      return res.status(500).json(uploadResult);
    }

    res.json({
      success: true,
      data: {
        uploadKey: uploadResult.key,
        message: 'Video uploaded successfully. Transcoding will begin shortly.'
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Get video metadata
router.get('/videos/:videoId/metadata', auth, async (req, res) => {
  try {
    const { videoId } = req.params;
    const videos = await mediaService.listTranscodedVideos(videoId);
    
    if (!videos.success || videos.videos.length === 0) {
      return res.status(404).json({ success: false, message: 'Video not found' });
    }

    const metadata = {
      videoId,
      streamUrl: cdnService.getVideoStreamUrl(videoId),
      files: videos.videos,
      cdnUrl: cdnService.getCdnUrl(`videos/${videoId}/`)
    };

    res.json({ success: true, data: metadata });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Get transcoding status
router.get('/jobs/:jobId/status', auth, async (req, res) => {
  try {
    const { jobId } = req.params;
    const status = await mediaService.getTranscodingStatus(jobId);
    res.json(status);
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Delete video
router.delete('/videos/:videoId', auth, async (req, res) => {
  try {
    const { videoId } = req.params;
    const result = await mediaService.deleteVideo(videoId, req.user.id);
    res.json(result);
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// CDN cache invalidation
router.post('/cdn/invalidate', auth, async (req, res) => {
  try {
    const { paths } = req.body;
    
    if (!paths || !Array.isArray(paths)) {
      return res.status(400).json({ success: false, message: 'Paths array required' });
    }

    const result = await cdnService.invalidateCache(paths);
    res.json(result);
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Get invalidation status
router.get('/cdn/invalidation/:invalidationId', auth, async (req, res) => {
  try {
    const { invalidationId } = req.params;
    const result = await cdnService.getInvalidationStatus(invalidationId);
    res.json(result);
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;