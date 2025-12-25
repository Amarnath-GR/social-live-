from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
from contextlib import asynccontextmanager
from .services.model_training import ModelTrainingService
from .services.feature_extraction import FeatureExtractionService
from .services.inference import InferenceService
from .api.routes import router

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    await ModelTrainingService.initialize()
    yield
    # Shutdown
    pass

app = FastAPI(
    title="ML Recommendation Service",
    version="1.0.0",
    lifespan=lifespan
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router, prefix="/api/v1")

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "ml-recommendation"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8001)