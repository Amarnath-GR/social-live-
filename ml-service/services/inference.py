import numpy as np
import pandas as pd
from typing import Dict, List, Tuple, Optional
from datetime import datetime
import asyncio
from .model_training import ModelTrainingService
from .feature_extraction import FeatureExtractionService
from .database import DatabaseService

class InferenceService:
    def __init__(self):
        self.model_training = ModelTrainingService()
        self.feature_extractor = FeatureExtractionService()
        self.db = DatabaseService()
        
    async def rank_posts_for_user(self, user_id: str, post_ids: List[str], limit: int = 20) -> List[Dict]:
        """Rank posts for a specific user using the trained model"""
        
        # Load model if not available
        if not self.model_training.model:
            await self.model_training.load_model()
        
        if not self.model_training.model:
            return await self._fallback_ranking(post_ids, limit)
        
        # Get predictions for all posts
        predictions = []
        
        for post_id in post_ids:
            try:
                score = await self._predict_user_post_score(user_id, post_id)
                predictions.append({
                    'post_id': post_id,
                    'score': score,
                    'timestamp': datetime.now().isoformat()
                })
            except Exception as e:
                print(f"Error predicting score for post {post_id}: {e}")
                predictions.append({
                    'post_id': post_id,
                    'score': 0.1,  # Low default score
                    'timestamp': datetime.now().isoformat()
                })
        
        # Sort by score and return top results
        ranked_posts = sorted(predictions, key=lambda x: x['score'], reverse=True)
        return ranked_posts[:limit]
    
    async def _predict_user_post_score(self, user_id: str, post_id: str) -> float:
        """Predict engagement score for user-post pair"""
        
        model = self.model_training.model
        
        # Get collaborative filtering score
        cf_score = await self._get_collaborative_score(user_id, post_id, model['collaborative'])
        
        # Get content-based score
        content_score = await self._get_content_score(user_id, post_id, model['content'])
        
        # Get popularity score
        popularity_score = await self._get_popularity_score(post_id)
        
        # Get freshness score
        freshness_score = await self._get_freshness_score(post_id)
        
        # Combine scores with weights
        weights = {
            'collaborative': 0.4,
            'content': 0.3,
            'popularity': 0.2,
            'freshness': 0.1
        }
        
        final_score = (
            cf_score * weights['collaborative'] +
            content_score * weights['content'] +
            popularity_score * weights['popularity'] +
            freshness_score * weights['freshness']
        )
        
        return max(0.0, min(1.0, final_score))  # Clamp between 0 and 1
    
    async def _get_collaborative_score(self, user_id: str, post_id: str, cf_model: Dict) -> float:
        """Get collaborative filtering score"""
        
        if not cf_model['user_factors'].size or not cf_model['item_factors'].size:
            return 0.5  # Neutral score for fallback
        
        try:
            user_index = cf_model['user_index']
            item_index = cf_model['item_index']
            
            if user_id not in user_index or post_id not in item_index:
                # Handle cold start with similarity-based approach
                return await self._handle_cold_start(user_id, post_id, cf_model)
            
            user_idx = user_index.index(user_id)
            item_idx = item_index.index(post_id)
            
            # Calculate dot product of user and item factors
            user_factors = cf_model['user_factors'][user_idx]
            item_factors = cf_model['item_factors'][:, item_idx]
            
            score = np.dot(user_factors, item_factors)
            
            # Normalize score
            return 1 / (1 + np.exp(-score))  # Sigmoid normalization
            
        except Exception as e:
            print(f"Error in collaborative filtering: {e}")
            return 0.5
    
    async def _handle_cold_start(self, user_id: str, post_id: str, cf_model: Dict) -> float:
        """Handle cold start problem using similarity"""
        
        try:
            # For new users, use average of similar users
            if user_id not in cf_model['user_index']:
                # Get user's recent engagements to find similar users
                user_engagements = await self.db.get_user_engagement_history(user_id, days=7)
                
                if not user_engagements:
                    return 0.3  # Low score for completely new users
                
                # Find users who engaged with similar posts
                similar_users = await self._find_similar_users(user_engagements, cf_model)
                
                if similar_users:
                    # Average their scores for this post
                    scores = []
                    for similar_user_id in similar_users[:5]:  # Top 5 similar users
                        if similar_user_id in cf_model['user_index']:
                            score = await self._get_collaborative_score(similar_user_id, post_id, cf_model)
                            scores.append(score)
                    
                    return np.mean(scores) if scores else 0.3
            
            # For new posts, use item-based similarity
            if post_id not in cf_model['item_index']:
                # Get post features and find similar posts
                post_features = await self.feature_extractor.extract_post_features(post_id)
                similar_posts = await self._find_similar_posts(post_features, cf_model)
                
                if similar_posts:
                    scores = []
                    for similar_post_id in similar_posts[:5]:
                        if similar_post_id in cf_model['item_index']:
                            score = await self._get_collaborative_score(user_id, similar_post_id, cf_model)
                            scores.append(score)
                    
                    return np.mean(scores) if scores else 0.3
            
            return 0.3  # Default for cold start
            
        except Exception as e:
            print(f"Error handling cold start: {e}")
            return 0.3
    
    async def _get_content_score(self, user_id: str, post_id: str, content_model: Dict) -> float:
        """Get content-based score"""
        
        try:
            # Extract interaction features
            features = await self.feature_extractor.extract_interaction_features(user_id, post_id)
            
            # Simple content scoring based on feature matching
            user_engagement_rate = features.get('engagement_rate', 0)
            post_engagement_velocity = features.get('engagement_velocity', 0)
            time_match = features.get('time_match', 0)
            freshness = features.get('freshness_score', 0)
            
            # Weighted combination of content features
            content_score = (
                user_engagement_rate * 0.3 +
                post_engagement_velocity * 0.3 +
                time_match * 0.2 +
                freshness * 0.2
            )
            
            return max(0.0, min(1.0, content_score))
            
        except Exception as e:
            print(f"Error in content scoring: {e}")
            return 0.5
    
    async def _get_popularity_score(self, post_id: str) -> float:
        """Get popularity-based score"""
        
        try:
            post_features = await self.feature_extractor.extract_post_features(post_id)
            
            # Normalize engagement metrics
            total_engagements = (
                post_features.get('total_views', 0) * 1 +
                post_features.get('total_likes', 0) * 3 +
                post_features.get('total_comments', 0) * 5 +
                post_features.get('total_shares', 0) * 7
            )
            
            # Apply logarithmic scaling to prevent popular posts from dominating
            popularity_score = np.log1p(total_engagements) / 10  # Normalize
            
            return max(0.0, min(1.0, popularity_score))
            
        except Exception as e:
            print(f"Error calculating popularity score: {e}")
            return 0.5
    
    async def _get_freshness_score(self, post_id: str) -> float:
        """Get freshness-based score"""
        
        try:
            post_data = await self.db.get_post_data(post_id)
            
            if not post_data:
                return 0.5
            
            # Calculate age in hours
            age_hours = (datetime.now() - post_data['created_at']).total_seconds() / 3600
            
            # Exponential decay with 24-hour half-life
            freshness_score = np.exp(-age_hours / 24)
            
            return max(0.0, min(1.0, freshness_score))
            
        except Exception as e:
            print(f"Error calculating freshness score: {e}")
            return 0.5
    
    async def _find_similar_users(self, user_engagements: List[Dict], cf_model: Dict) -> List[str]:
        """Find users with similar engagement patterns"""
        
        try:
            engaged_post_ids = [eng['post_id'] for eng in user_engagements]
            
            # Find users who engaged with the same posts
            similar_users = await self.db.find_users_by_posts(engaged_post_ids)
            
            return similar_users[:10]  # Return top 10 similar users
            
        except Exception as e:
            print(f"Error finding similar users: {e}")
            return []
    
    async def _find_similar_posts(self, post_features: Dict, cf_model: Dict) -> List[str]:
        """Find posts with similar features"""
        
        try:
            # Simple similarity based on engagement metrics
            target_engagement = post_features.get('engagement_velocity', 0)
            target_popularity = post_features.get('author_popularity', 0)
            
            # Find posts with similar characteristics
            similar_posts = await self.db.find_similar_posts(target_engagement, target_popularity)
            
            return similar_posts[:10]
            
        except Exception as e:
            print(f"Error finding similar posts: {e}")
            return []
    
    async def _fallback_ranking(self, post_ids: List[str], limit: int) -> List[Dict]:
        """Fallback ranking when no model is available"""
        
        print("Using fallback ranking")
        
        # Simple popularity + freshness ranking
        post_scores = []
        
        for post_id in post_ids:
            try:
                popularity_score = await self._get_popularity_score(post_id)
                freshness_score = await self._get_freshness_score(post_id)
                
                # Simple weighted combination
                final_score = popularity_score * 0.7 + freshness_score * 0.3
                
                post_scores.append({
                    'post_id': post_id,
                    'score': final_score,
                    'timestamp': datetime.now().isoformat()
                })
                
            except Exception as e:
                print(f"Error in fallback ranking for post {post_id}: {e}")
                post_scores.append({
                    'post_id': post_id,
                    'score': 0.1,
                    'timestamp': datetime.now().isoformat()
                })
        
        # Sort and return
        ranked_posts = sorted(post_scores, key=lambda x: x['score'], reverse=True)
        return ranked_posts[:limit]
    
    async def get_user_recommendations(self, user_id: str, limit: int = 20) -> List[Dict]:
        """Get personalized recommendations for a user"""
        
        # Get candidate posts (recent posts from followed users + trending posts)
        candidate_posts = await self._get_candidate_posts(user_id, limit * 3)
        
        if not candidate_posts:
            return []
        
        # Rank the candidate posts
        ranked_posts = await self.rank_posts_for_user(user_id, candidate_posts, limit)
        
        return ranked_posts
    
    async def _get_candidate_posts(self, user_id: str, limit: int) -> List[str]:
        """Get candidate posts for recommendation"""
        
        try:
            # Get recent posts (last 24 hours)
            recent_posts = await self.db.get_recent_posts(hours=24, limit=limit // 2)
            
            # Get trending posts
            trending_posts = await self.db.get_trending_posts(limit=limit // 2)
            
            # Combine and deduplicate
            all_posts = list(set(recent_posts + trending_posts))
            
            return all_posts[:limit]
            
        except Exception as e:
            print(f"Error getting candidate posts: {e}")
            return []