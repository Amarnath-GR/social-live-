const AWS = require('aws-sdk');

class CdnService {
  constructor() {
    this.cloudfront = new AWS.CloudFront();
    this.distributionId = process.env.CLOUDFRONT_DISTRIBUTION_ID;
  }

  async invalidateCache(paths) {
    const params = {
      DistributionId: this.distributionId,
      InvalidationBatch: {
        Paths: {
          Quantity: paths.length,
          Items: paths.map(path => path.startsWith('/') ? path : `/${path}`)
        },
        CallerReference: `invalidation-${Date.now()}`
      }
    };

    try {
      const result = await this.cloudfront.createInvalidation(params).promise();
      return {
        success: true,
        invalidationId: result.Invalidation.Id,
        status: result.Invalidation.Status
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  async getInvalidationStatus(invalidationId) {
    const params = {
      DistributionId: this.distributionId,
      Id: invalidationId
    };

    try {
      const result = await this.cloudfront.getInvalidation(params).promise();
      return {
        success: true,
        status: result.Invalidation.Status,
        createTime: result.Invalidation.CreateTime
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  getCdnUrl(path) {
    const cdnDomain = process.env.CDN_DOMAIN;
    return `https://${cdnDomain}/${path}`;
  }

  getVideoStreamUrl(videoId) {
    return this.getCdnUrl(`videos/${videoId}/master.m3u8`);
  }

  async invalidateVideoCache(videoId) {
    const paths = [
      `/videos/${videoId}/*`,
      `/videos/${videoId}/master.m3u8`,
      `/videos/${videoId}/*.m3u8`,
      `/videos/${videoId}/*.ts`
    ];
    
    return await this.invalidateCache(paths);
  }

  getOptimalCacheStrategy(contentType) {
    const strategies = {
      'video/mp4': {
        ttl: 86400, // 24 hours
        maxAge: 31536000, // 1 year
        compress: true
      },
      'application/x-mpegURL': { // .m3u8
        ttl: 10, // 10 seconds
        maxAge: 60, // 1 minute
        compress: false
      },
      'video/MP2T': { // .ts segments
        ttl: 3600, // 1 hour
        maxAge: 86400, // 24 hours
        compress: true
      },
      'image/jpeg': {
        ttl: 3600, // 1 hour
        maxAge: 604800, // 1 week
        compress: true
      }
    };

    return strategies[contentType] || {
      ttl: 3600,
      maxAge: 86400,
      compress: true
    };
  }
}

module.exports = CdnService;