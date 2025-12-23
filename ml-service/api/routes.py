from fastapi import APIRouter, HTTPException, BackgroundTasks
from pydantic import BaseModel
from typing import List, Dict, Optional
from datetime import datetime
from ..services.model_training import ModelTrainingService
from ..services.inference import InferenceService
from ..services.feature_extraction import FeatureExtractionService

router = APIRouter()

# Pydantic models for request/response
class RankingRequest(BaseModel):
    user_id: str
    post_ids: List[str]
    limit: Optional[int] = 20

class RankingResponse(BaseModel):
    post_id: str
    score: float
    timestamp: str

class RecommendationRequest(BaseModel):
    user_id: str
    limit: Optional[int] = 20

class TrainingRequest(BaseModel):
    force_retrain: Optional[bool] = False

# Initialize services
model_training = ModelTrainingService()
inference_service = InferenceService()
feature_extractor = FeatureExtractionService()

@router.post("/rank", response_model=List[RankingResponse])
async def rank_posts(request: RankingRequest):
    """Rank posts for a specific user"""
    try:
        rankings = await inference_service.rank_posts_for_user(
            request.user_id,
            request.post_ids,
            request.limit
        )
        
        return [RankingResponse(**ranking) for ranking in rankings]
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Ranking failed: {str(e)}")

@router.post("/recommend", response_model=List[RankingResponse])
async def get_recommendations(request: RecommendationRequest):
    """Get personalized recommendations for a user"""
    try:
        recommendations = await inference_service.get_user_recommendations(
            request.user_id,
            request.limit
        )
        
        return [RankingResponse(**rec) for rec in recommendations]
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Recommendation failed: {str(e)}")

@router.post("/train")
async def train_model(request: TrainingRequest, background_tasks: BackgroundTasks):
    """Train or retrain the recommendation model"""
    try:
        if request.force_retrain or not model_training.model:
            # Run training in background
            background_tasks.add_task(model_training.train_recommendation_model)
            return {"message": "Model training started", "status": "training"}
        else:
            return {"message": "Model already trained", "status": "ready"}
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Training failed: {str(e)}")

@router.get("/model/status")
async def get_model_status():
    """Get current model status and information"""
    try:
        model_info = model_training.get_model_info()
        return model_info
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Status check failed: {str(e)}")

@router.get("/model/evaluate")
async def evaluate_model():
    """Evaluate current model performance"""
    try:
        evaluation = await model_training.evaluate_model()
        return evaluation
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Evaluation failed: {str(e)}")

@router.get("/features/user/{user_id}")
async def get_user_features(user_id: str):
    """Get extracted features for a user"""
    try:
        features = await feature_extractor.extract_user_features(user_id)
        return features
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Feature extraction failed: {str(e)}")

@router.get("/features/post/{post_id}")
async def get_post_features(post_id: str):
    """Get extracted features for a post"""
    try:
        features = await feature_extractor.extract_post_features(post_id)
        return features
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Feature extraction failed: {str(e)}")

@router.get("/features/interaction/{user_id}/{post_id}")
async def get_interaction_features(user_id: str, post_id: str):
    """Get interaction features for user-post pair"""
    try:
        features = await feature_extractor.extract_interaction_features(user_id, post_id)
        return features
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Feature extraction failed: {str(e)}")

@router.post("/retrain")
async def retrain_model(background_tasks: BackgroundTasks):
    """Force retrain the model with latest data"""
    try:
        background_tasks.add_task(model_training.retrain_model)
        return {"message": "Model retraining started", "status": "retraining"}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Retraining failed: {str(e)}")

@router.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "service": "ml-recommendation"
    }