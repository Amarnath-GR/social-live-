# ML-Based Recommendation Engine

This implementation replaces the heuristic feed ordering with a sophisticated ML-based recommendation system using collaborative filtering, content-based filtering, and real-time inference.

## Architecture

### Components

1. **Python ML Service** (`ml-service/`)
   - FastAPI-based microservice
   - Collaborative filtering using NMF (Non-negative Matrix Factorization)
   - Content-based filtering with feature extraction
   - Real-time inference API
   - Model training pipeline

2. **Node.js Integration** (`src/ml/`)
   - Updated ML inference service
   - HTTP client for Python ML service
   - Fallback mechanisms
   - Feature flag integration

3. **Database Schema**
   - ML model metadata storage
   - Enhanced indexing for performance
   - Feature flags for gradual rollout

## Features

### Model Training Pipeline
- **Collaborative Filtering**: NMF-based matrix factorization
- **Content-Based Filtering**: Feature extraction and similarity matching
- **Hybrid Approach**: Combines multiple signals for better recommendations
- **Automated Training**: Scheduled retraining with latest data
- **Cold Start Handling**: Similarity-based recommendations for new users/posts

### Feature Extraction
- **User Features**: Engagement patterns, preferences, activity timing
- **Post Features**: Age, engagement metrics, author popularity, content characteristics
- **Interaction Features**: User-post compatibility, time matching, freshness scores

### Real-time Inference
- **Ranking API**: Ranks posts for specific users
- **Recommendation API**: Generates personalized feed recommendations
- **Fallback System**: Graceful degradation when ML service unavailable
- **Performance Optimization**: Caching and batch processing

## Setup Instructions

### 1. Install Python Dependencies
```bash
cd ml-service
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Start ML Service
```bash
# Linux/Mac
./start-ml-service.sh

# Windows
start-ml-service.bat

# Or manually
cd ml-service
python -m uvicorn main:app --host 0.0.0.0 --port 8001 --reload
```

### 3. Update Environment Variables
Add to your `.env` file:
```
ML_SERVICE_URL=http://localhost:8001
```

### 4. Run Database Migration
```sql
-- Execute the migration script
\i prisma/migrations/add_ml_support.sql
```

### 5. Start with Docker Compose
```bash
docker-compose -f docker-compose.ml.yml up
```

## API Endpoints

### ML Service (Port 8001)

#### Training
- `POST /api/v1/train` - Trigger model training
- `POST /api/v1/retrain` - Force model retraining
- `GET /api/v1/model/status` - Get model status
- `GET /api/v1/model/evaluate` - Evaluate model performance

#### Inference
- `POST /api/v1/rank` - Rank posts for user
- `POST /api/v1/recommend` - Get personalized recommendations

#### Features
- `GET /api/v1/features/user/{userId}` - Get user features
- `GET /api/v1/features/post/{postId}` - Get post features
- `GET /api/v1/features/interaction/{userId}/{postId}` - Get interaction features

### Node.js Service Integration

#### ML Management
- `GET /ml/status` - Check ML service health and model status
- `POST /ml/train` - Trigger training via Node.js
- `POST /ml/predict` - Get predictions for user-post pairs
- `POST /ml/recommend` - Get recommendations via Node.js

## Configuration

### Feature Flags
- `mlRecommendations`: Enable/disable ML-based recommendations
- `personalizedFeed`: Enable personalized feed (fallback)
- `engagementRanking`: Enable engagement-based ranking (fallback)

### Model Parameters
- **Collaborative Filtering**: 50 factors (max), NMF algorithm
- **Content Weights**: Configurable via system_config table
- **Time Decay**: 7-day half-life for engagement recency
- **Training Schedule**: Daily at 2 AM (configurable)

## Performance Considerations

### Optimization Strategies
1. **Caching**: Model results cached for 30 minutes
2. **Batch Processing**: Multiple predictions in single request
3. **Fallback System**: Heuristic ranking when ML unavailable
4. **Database Indexing**: Optimized queries for engagement data
5. **Async Processing**: Non-blocking model training

### Scalability
- **Horizontal Scaling**: Multiple ML service instances
- **Model Versioning**: Support for A/B testing different models
- **Feature Store**: Centralized feature computation and storage
- **Real-time Updates**: Incremental model updates

## Monitoring and Evaluation

### Metrics Tracked
- **Model Performance**: Coverage, accuracy, training time
- **Business Metrics**: Engagement rate, session duration, retention
- **System Metrics**: Response time, error rate, throughput
- **A/B Testing**: Comparison with heuristic baseline

### Health Checks
- ML service availability
- Model freshness and version
- Database connectivity
- Feature extraction performance

## Deployment

### Production Checklist
1. ✅ ML service containerized and deployed
2. ✅ Database migrations applied
3. ✅ Environment variables configured
4. ✅ Feature flags enabled gradually
5. ✅ Monitoring and alerting setup
6. ✅ Fallback mechanisms tested
7. ✅ Performance benchmarks established

### Rollout Strategy
1. **Phase 1**: Deploy ML service, keep feature flag disabled
2. **Phase 2**: Enable for 10% of users, monitor metrics
3. **Phase 3**: Gradual rollout to 50%, then 100%
4. **Phase 4**: Disable heuristic fallback once stable

## Troubleshooting

### Common Issues
- **ML Service Down**: Automatic fallback to heuristic ranking
- **Model Training Fails**: Uses previous model version
- **Cold Start**: Similarity-based recommendations for new users
- **Performance Issues**: Check database indexes and caching

### Debug Endpoints
- `/ml/status` - Overall system health
- `/api/v1/health` - ML service health
- `/api/v1/model/status` - Model information
- `/api/v1/model/evaluate` - Performance metrics

## Future Enhancements

### Planned Features
1. **Deep Learning Models**: Neural collaborative filtering
2. **Real-time Learning**: Online model updates
3. **Multi-objective Optimization**: Balance engagement and diversity
4. **Contextual Bandits**: Dynamic exploration vs exploitation
5. **Graph Neural Networks**: Social network-based recommendations
6. **Federated Learning**: Privacy-preserving model training

### Advanced Analytics
- **Recommendation Explainability**: Why certain posts were recommended
- **Bias Detection**: Monitor and mitigate algorithmic bias
- **Long-term Impact**: Track user satisfaction and platform health
- **Personalization Depth**: Individual vs segment-based models