const AWS = require('aws-sdk');
const multer = require('multer');
const path = require('path');
const CdnService = require('./cdnService');

class MediaService {
  constructor() {
    this.s3 = new AWS.S3();
    this.mediaConvert = new AWS.MediaConvert();
    this.cdnService = new CdnService();
    this.sourceBucket = process.env.SOURCE_BUCKET;
    this.mediaBucket = process.env.MEDIA_BUCKET;
  }

  getUploadMiddleware() {
    const storage = multer.memoryStorage();
    return multer({
      storage,
      limits: { fileSize: 500 * 1024 * 1024 }, // 500MB
      fileFilter: (req, file, cb) => {
        const allowedTypes = ['video/mp4', 'video/avi', 'video/mov', 'video/wmv'];
        cb(null, allowedTypes.includes(file.mimetype));
      }
    });
  }

  async uploadToS3(file, userId) {
    const key = `uploads/${userId}/${Date.now()}-${file.originalname}`;
    
    const params = {
      Bucket: this.sourceBucket,
      Key: key,
      Body: file.buffer,
      ContentType: file.mimetype,
      Metadata: {
        userId: userId.toString(),
        originalName: file.originalname
      }
    };

    try {
      const result = await this.s3.upload(params).promise();
      return {
        success: true,
        key,
        location: result.Location,
        etag: result.ETag
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  async getTranscodingStatus(jobId) {
    try {
      const params = { Id: jobId };
      const result = await this.mediaConvert.getJob(params).promise();
      
      return {
        success: true,
        status: result.Job.Status,
        progress: result.Job.JobPercentComplete || 0,
        createdAt: result.Job.CreatedAt,
        outputs: result.Job.Settings.OutputGroups
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  async listTranscodedVideos(prefix) {
    const params = {
      Bucket: this.mediaBucket,
      Prefix: `videos/${prefix}`,
      Delimiter: '/'
    };

    try {
      const result = await this.s3.listObjectsV2(params).promise();
      
      const videos = result.Contents
        .filter(obj => obj.Key.endsWith('.m3u8'))
        .map(obj => ({
          key: obj.Key,
          url: this.cdnService.getCdnUrl(obj.Key),
          lastModified: obj.LastModified,
          size: obj.Size
        }));

      return {
        success: true,
        videos
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  async deleteVideo(videoId, userId) {
    const prefix = `videos/${videoId}`;
    
    try {
      // List all objects with the prefix
      const listParams = {
        Bucket: this.mediaBucket,
        Prefix: prefix
      };
      
      const objects = await this.s3.listObjectsV2(listParams).promise();
      
      if (objects.Contents.length === 0) {
        return { success: false, error: 'Video not found' };
      }

      // Delete all objects
      const deleteParams = {
        Bucket: this.mediaBucket,
        Delete: {
          Objects: objects.Contents.map(obj => ({ Key: obj.Key }))
        }
      };
      
      await this.s3.deleteObjects(deleteParams).promise();
      
      // Invalidate CDN cache
      await this.cdnService.invalidateVideoCache(videoId);
      
      return { success: true, deletedCount: objects.Contents.length };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  generateVideoMetadata(videoId, transcodingResult) {
    return {
      videoId,
      status: 'ready',
      streamUrl: this.cdnService.getVideoStreamUrl(videoId),
      qualities: this.extractQualityLevels(transcodingResult),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
  }

  extractQualityLevels(transcodingResult) {
    const qualities = [];
    
    if (transcodingResult.outputs) {
      transcodingResult.outputs.forEach(output => {
        if (output.VideoDescription) {
          const video = output.VideoDescription;
          qualities.push({
            width: video.Width,
            height: video.Height,
            bitrate: video.CodecSettings?.H264Settings?.Bitrate || 0,
            label: `${video.Height}p`
          });
        }
      });
    }
    
    return qualities.sort((a, b) => b.bitrate - a.bitrate);
  }
}

module.exports = MediaService;