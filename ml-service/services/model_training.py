import pandas as pd
import numpy as np
from sklearn.decomposition import NMF
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.preprocessing import StandardScaler
import pickle
import asyncio
from datetime import datetime, timedelta
from typing import Dict, List, Tuple, Optional
from .database import DatabaseService
from .feature_extraction import FeatureExtractionService

class ModelTrainingService:
    def __init__(self):
        self.db = DatabaseService()
        self.feature_extractor = FeatureExtractionService()
        self.model = None
        self.user_factors = None
        self.item_factors = None
        self.scaler = StandardScaler()
        self.model_version = None
        
    @classmethod
    async def initialize(cls):
        """Initialize the service and load existing model if available"""
        instance = cls()
        await instance.load_model()
        return instance
    
    async def train_recommendation_model(self) -> Dict:
        """Train the main recommendation model using collaborative filtering"""
        print("Starting model training...")
        
        # Get training data
        training_data = await self._prepare_training_data()
        
        if len(training_data) < 100:  # Minimum data requirement
            print("Insufficient training data, using fallback model")
            return await self._create_fallback_model()
        
        # Create user-item interaction matrix
        interaction_matrix = self._create_interaction_matrix(training_data)
        
        # Train collaborative filtering model
        model_results = await self._train_collaborative_filtering(interaction_matrix)
        
        # Train content-based features
        content_model = await self._train_content_model(training_data)
        
        # Combine models
        combined_model = {
            'collaborative': model_results,
            'content': content_model,
            'metadata': {
                'training_date': datetime.now().isoformat(),
                'data_size': len(training_data),
                'model_version': f"v{datetime.now().strftime('%Y%m%d_%H%M%S')}"
            }
        }
        
        # Save model
        await self._save_model(combined_model)
        self.model = combined_model
        self.model_version = combined_model['metadata']['model_version']
        
        print(f"Model training completed. Version: {self.model_version}")
        return combined_model
    
    async def _prepare_training_data(self) -> pd.DataFrame:
        """Prepare training data from engagement history"""
        # Get engagement data from last 30 days
        end_date = datetime.now()
        start_date = end_date - timedelta(days=30)
        
        engagement_data = await self.db.get_engagement_data(start_date, end_date)
        
        if not engagement_data:
            return pd.DataFrame()
        
        df = pd.DataFrame(engagement_data)
        
        # Create engagement scores
        engagement_weights = {
            'VIEW': 1.0,
            'LIKE': 3.0,
            'COMMENT': 5.0,
            'SHARE': 7.0
        }
        
        df['engagement_score'] = df['engagement_type'].map(engagement_weights)
        
        # Aggregate by user-post pairs
        user_post_scores = df.groupby(['user_id', 'post_id']).agg({
            'engagement_score': 'sum',
            'timestamp': 'max'
        }).reset_index()
        
        # Add time decay
        now = datetime.now()
        user_post_scores['days_ago'] = (now - pd.to_datetime(user_post_scores['timestamp'])).dt.days
        user_post_scores['time_weight'] = np.exp(-user_post_scores['days_ago'] / 7)  # 7-day half-life
        user_post_scores['final_score'] = user_post_scores['engagement_score'] * user_post_scores['time_weight']
        
        return user_post_scores
    
    def _create_interaction_matrix(self, training_data: pd.DataFrame) -> pd.DataFrame:
        """Create user-item interaction matrix"""
        interaction_matrix = training_data.pivot_table(
            index='user_id',
            columns='post_id',
            values='final_score',
            fill_value=0
        )
        
        return interaction_matrix
    
    async def _train_collaborative_filtering(self, interaction_matrix: pd.DataFrame) -> Dict:
        """Train collaborative filtering model using NMF"""
        # Normalize the matrix
        normalized_matrix = interaction_matrix.div(interaction_matrix.sum(axis=1), axis=0).fillna(0)
        
        # Determine number of factors
        n_factors = min(50, min(interaction_matrix.shape) // 2)
        
        # Train NMF model
        nmf_model = NMF(n_components=n_factors, random_state=42, max_iter=200)
        user_factors = nmf_model.fit_transform(normalized_matrix)
        item_factors = nmf_model.components_
        
        # Store factors
        self.user_factors = user_factors
        self.item_factors = item_factors
        
        # Calculate user and item similarities
        user_similarity = cosine_similarity(user_factors)
        item_similarity = cosine_similarity(item_factors.T)
        
        return {
            'model': nmf_model,
            'user_factors': user_factors,
            'item_factors': item_factors,
            'user_similarity': user_similarity,
            'item_similarity': item_similarity,
            'user_index': interaction_matrix.index.tolist(),
            'item_index': interaction_matrix.columns.tolist(),
            'n_factors': n_factors
        }
    
    async def _train_content_model(self, training_data: pd.DataFrame) -> Dict:
        """Train content-based model"""
        # Get unique posts from training data
        unique_posts = training_data['post_id'].unique()
        
        # Extract features for posts
        post_features = []
        for post_id in unique_posts[:1000]:  # Limit for performance
            features = await self.feature_extractor.extract_post_features(post_id)
            post_features.append(features)
        
        if not post_features:
            return {'features': [], 'scaler': None}
        
        # Create feature matrix
        feature_df = pd.DataFrame(post_features)
        numeric_columns = feature_df.select_dtypes(include=[np.number]).columns
        feature_matrix = feature_df[numeric_columns].fillna(0)
        
        # Normalize features
        normalized_features = self.scaler.fit_transform(feature_matrix)
        
        # Calculate content similarity
        content_similarity = cosine_similarity(normalized_features)
        
        return {
            'features': normalized_features,
            'feature_columns': numeric_columns.tolist(),
            'post_ids': feature_df['post_id'].tolist(),
            'scaler': self.scaler,
            'content_similarity': content_similarity
        }
    
    async def _create_fallback_model(self) -> Dict:
        """Create a simple fallback model when insufficient data"""
        return {
            'collaborative': {
                'model': None,
                'user_factors': np.array([]),
                'item_factors': np.array([]),
                'user_similarity': np.array([]),
                'item_similarity': np.array([]),
                'user_index': [],
                'item_index': [],
                'n_factors': 0
            },
            'content': {
                'features': [],
                'scaler': None
            },
            'metadata': {
                'training_date': datetime.now().isoformat(),
                'data_size': 0,
                'model_version': 'fallback_v1',
                'is_fallback': True
            }
        }
    
    async def _save_model(self, model: Dict):
        """Save trained model to disk"""
        model_path = f"models/recommendation_model_{model['metadata']['model_version']}.pkl"
        
        with open(model_path, 'wb') as f:
            pickle.dump(model, f)
        
        # Save model metadata to database
        await self.db.save_model_metadata(model['metadata'])
    
    async def load_model(self) -> Optional[Dict]:
        """Load the latest trained model"""
        try:
            # Get latest model metadata
            model_metadata = await self.db.get_latest_model_metadata()
            
            if not model_metadata:
                print("No trained model found")
                return None
            
            model_path = f"models/recommendation_model_{model_metadata['model_version']}.pkl"
            
            with open(model_path, 'rb') as f:
                self.model = pickle.load(f)
            
            self.model_version = model_metadata['model_version']
            
            # Load factors for quick access
            if self.model and 'collaborative' in self.model:
                self.user_factors = self.model['collaborative']['user_factors']
                self.item_factors = self.model['collaborative']['item_factors']
            
            print(f"Loaded model version: {self.model_version}")
            return self.model
            
        except Exception as e:
            print(f"Error loading model: {e}")
            return None
    
    async def retrain_model(self) -> Dict:
        """Retrain the model with latest data"""
        return await self.train_recommendation_model()
    
    async def evaluate_model(self) -> Dict:
        """Evaluate model performance"""
        if not self.model:
            return {'error': 'No model available for evaluation'}
        
        # Get test data (last 7 days)
        end_date = datetime.now()
        start_date = end_date - timedelta(days=7)
        test_data = await self.db.get_engagement_data(start_date, end_date)
        
        if not test_data:
            return {'error': 'No test data available'}
        
        # Calculate basic metrics
        test_df = pd.DataFrame(test_data)
        unique_users = test_df['user_id'].nunique()
        unique_posts = test_df['post_id'].nunique()
        total_interactions = len(test_df)
        
        # Calculate coverage
        model_users = len(self.model['collaborative']['user_index'])
        model_posts = len(self.model['collaborative']['item_index'])
        
        user_coverage = min(unique_users / max(model_users, 1), 1.0)
        item_coverage = min(unique_posts / max(model_posts, 1), 1.0)
        
        return {
            'model_version': self.model_version,
            'test_period_days': 7,
            'test_interactions': total_interactions,
            'unique_test_users': unique_users,
            'unique_test_posts': unique_posts,
            'user_coverage': user_coverage,
            'item_coverage': item_coverage,
            'model_size': {
                'users': model_users,
                'posts': model_posts,
                'factors': self.model['collaborative']['n_factors']
            }
        }
    
    def get_model_info(self) -> Dict:
        """Get current model information"""
        if not self.model:
            return {'status': 'no_model'}
        
        return {
            'status': 'loaded',
            'version': self.model_version,
            'metadata': self.model.get('metadata', {}),
            'collaborative_factors': self.model['collaborative']['n_factors'],
            'is_fallback': self.model['metadata'].get('is_fallback', False)
        }