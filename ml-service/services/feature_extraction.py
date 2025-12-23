import pandas as pd
import numpy as np
from typing import Dict, List, Optional
from datetime import datetime, timedelta
import asyncio
from .database import DatabaseService

class FeatureExtractionService:
    def __init__(self):
        self.db = DatabaseService()
    
    async def extract_user_features(self, user_id: str) -> Dict:
        """Extract user-level features for recommendation"""
        user_data = await self.db.get_user_engagement_history(user_id, days=30)
        
        if not user_data:
            return self._default_user_features()
        
        df = pd.DataFrame(user_data)
        
        features = {
            'user_id': user_id,
            'total_engagements': len(df),
            'avg_session_duration': df['duration'].mean() if 'duration' in df else 0,
            'engagement_rate': self._calculate_engagement_rate(df),
            'preferred_hours': self._get_preferred_hours(df),
            'content_diversity': self._calculate_content_diversity(df),
            'social_activity': self._calculate_social_activity(df),
            'recency_score': self._calculate_recency_score(df)
        }
        
        return features
    
    async def extract_post_features(self, post_id: str) -> Dict:
        """Extract post-level features"""
        post_data = await self.db.get_post_data(post_id)
        engagement_data = await self.db.get_post_engagement_data(post_id)
        
        if not post_data:
            return self._default_post_features(post_id)
        
        features = {
            'post_id': post_id,
            'age_hours': (datetime.now() - post_data['created_at']).total_seconds() / 3600,
            'total_views': engagement_data.get('views', 0),
            'total_likes': engagement_data.get('likes', 0),
            'total_comments': engagement_data.get('comments', 0),
            'total_shares': engagement_data.get('shares', 0),
            'engagement_velocity': self._calculate_engagement_velocity(engagement_data),
            'author_popularity': await self._get_author_popularity(post_data['user_id']),
            'content_length': len(post_data.get('content', '')),
            'has_media': bool(post_data.get('image_url')),
            'virality_score': self._calculate_virality_score(engagement_data)
        }
        
        return features
    
    async def extract_interaction_features(self, user_id: str, post_id: str) -> Dict:
        """Extract user-post interaction features"""
        user_features = await self.extract_user_features(user_id)
        post_features = await self.extract_post_features(post_id)
        
        # Get historical interactions between user and post author
        author_id = await self.db.get_post_author(post_id)
        interaction_history = await self.db.get_user_author_interactions(user_id, author_id)
        
        features = {
            'user_post_similarity': self._calculate_user_post_similarity(user_features, post_features),
            'author_affinity': len(interaction_history) / max(user_features['total_engagements'], 1),
            'time_match': self._calculate_time_match(user_features, post_features),
            'freshness_score': self._calculate_freshness_score(post_features['age_hours']),
            'popularity_match': self._calculate_popularity_match(user_features, post_features)
        }
        
        return {**user_features, **post_features, **features}
    
    def _default_user_features(self) -> Dict:
        return {
            'total_engagements': 0,
            'avg_session_duration': 0,
            'engagement_rate': 0,
            'preferred_hours': [12, 18, 20],
            'content_diversity': 0,
            'social_activity': 0,
            'recency_score': 0
        }
    
    def _default_post_features(self, post_id: str) -> Dict:
        return {
            'post_id': post_id,
            'age_hours': 0,
            'total_views': 0,
            'total_likes': 0,
            'total_comments': 0,
            'total_shares': 0,
            'engagement_velocity': 0,
            'author_popularity': 0,
            'content_length': 0,
            'has_media': False,
            'virality_score': 0
        }
    
    def _calculate_engagement_rate(self, df: pd.DataFrame) -> float:
        if len(df) == 0:
            return 0
        
        views = len(df[df['engagement_type'] == 'VIEW'])
        interactions = len(df[df['engagement_type'].isin(['LIKE', 'COMMENT', 'SHARE'])])
        
        return interactions / max(views, 1)
    
    def _get_preferred_hours(self, df: pd.DataFrame) -> List[int]:
        if len(df) == 0:
            return [12, 18, 20]
        
        df['hour'] = pd.to_datetime(df['timestamp']).dt.hour
        hour_counts = df['hour'].value_counts()
        return hour_counts.head(3).index.tolist()
    
    def _calculate_content_diversity(self, df: pd.DataFrame) -> float:
        if len(df) == 0:
            return 0
        
        unique_posts = df['post_id'].nunique()
        total_engagements = len(df)
        
        return unique_posts / max(total_engagements, 1)
    
    def _calculate_social_activity(self, df: pd.DataFrame) -> float:
        if len(df) == 0:
            return 0
        
        social_engagements = len(df[df['engagement_type'].isin(['LIKE', 'COMMENT', 'SHARE'])])
        return social_engagements / max(len(df), 1)
    
    def _calculate_recency_score(self, df: pd.DataFrame) -> float:
        if len(df) == 0:
            return 0
        
        df['timestamp'] = pd.to_datetime(df['timestamp'])
        recent_engagements = len(df[df['timestamp'] > datetime.now() - timedelta(days=7)])
        
        return recent_engagements / max(len(df), 1)
    
    def _calculate_engagement_velocity(self, engagement_data: Dict) -> float:
        total_engagements = sum(engagement_data.values())
        # Simplified velocity calculation
        return total_engagements / max(1, engagement_data.get('age_hours', 1))
    
    async def _get_author_popularity(self, author_id: str) -> float:
        author_stats = await self.db.get_author_stats(author_id)
        return author_stats.get('avg_engagement_per_post', 0)
    
    def _calculate_virality_score(self, engagement_data: Dict) -> float:
        shares = engagement_data.get('shares', 0)
        views = engagement_data.get('views', 1)
        return shares / max(views, 1)
    
    def _calculate_user_post_similarity(self, user_features: Dict, post_features: Dict) -> float:
        # Simplified similarity based on engagement patterns
        user_social = user_features.get('social_activity', 0)
        post_social = post_features.get('engagement_velocity', 0)
        
        return 1 / (1 + abs(user_social - post_social))
    
    def _calculate_time_match(self, user_features: Dict, post_features: Dict) -> float:
        current_hour = datetime.now().hour
        preferred_hours = user_features.get('preferred_hours', [])
        
        if current_hour in preferred_hours:
            return 1.0
        
        min_distance = min([abs(current_hour - h) for h in preferred_hours])
        return 1 / (1 + min_distance)
    
    def _calculate_freshness_score(self, age_hours: float) -> float:
        # Exponential decay for freshness
        return np.exp(-age_hours / 24)  # Half-life of 24 hours
    
    def _calculate_popularity_match(self, user_features: Dict, post_features: Dict) -> float:
        user_engagement = user_features.get('engagement_rate', 0)
        post_popularity = post_features.get('engagement_velocity', 0)
        
        return 1 / (1 + abs(user_engagement - post_popularity))