import os
from typing import Dict, List, Optional
from datetime import datetime, timedelta
import asyncio
import asyncpg

class DatabaseService:
    def __init__(self):
        self.pool = None
        self.db_url = os.getenv('DATABASE_URL', 'postgresql://user:password@localhost:5432/social_live')
    
    async def connect(self):
        """Initialize database connection pool"""
        if not self.pool:
            self.pool = await asyncpg.create_pool(self.db_url, min_size=2, max_size=10)
    
    async def close(self):
        """Close database connection pool"""
        if self.pool:
            await self.pool.close()
    
    async def get_engagement_data(self, start_date: datetime, end_date: datetime) -> List[Dict]:
        """Get engagement data for training"""
        await self.connect()
        
        query = """
            SELECT user_id, post_id, engagement_type, timestamp, duration
            FROM user_engagement
            WHERE timestamp BETWEEN $1 AND $2
            ORDER BY timestamp DESC
        """
        
        async with self.pool.acquire() as conn:
            rows = await conn.fetch(query, start_date, end_date)
            return [dict(row) for row in rows]
    
    async def get_user_engagement_history(self, user_id: str, days: int = 30) -> List[Dict]:
        """Get user's engagement history"""
        await self.connect()
        
        start_date = datetime.now() - timedelta(days=days)
        
        query = """
            SELECT post_id, engagement_type, timestamp, duration
            FROM user_engagement
            WHERE user_id = $1 AND timestamp >= $2
            ORDER BY timestamp DESC
        """
        
        async with self.pool.acquire() as conn:
            rows = await conn.fetch(query, user_id, start_date)
            return [dict(row) for row in rows]
    
    async def get_post_data(self, post_id: str) -> Optional[Dict]:
        """Get post data"""
        await self.connect()
        
        query = """
            SELECT id, user_id, content, image_url, created_at
            FROM posts
            WHERE id = $1
        """
        
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(query, post_id)
            return dict(row) if row else None
    
    async def get_post_engagement_data(self, post_id: str) -> Dict:
        """Get aggregated engagement data for a post"""
        await self.connect()
        
        query = """
            SELECT 
                COUNT(CASE WHEN engagement_type = 'VIEW' THEN 1 END) as views,
                COUNT(CASE WHEN engagement_type = 'LIKE' THEN 1 END) as likes,
                COUNT(CASE WHEN engagement_type = 'COMMENT' THEN 1 END) as comments,
                COUNT(CASE WHEN engagement_type = 'SHARE' THEN 1 END) as shares
            FROM user_engagement
            WHERE post_id = $1
        """
        
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(query, post_id)
            return dict(row) if row else {'views': 0, 'likes': 0, 'comments': 0, 'shares': 0}
    
    async def get_post_author(self, post_id: str) -> Optional[str]:
        """Get post author ID"""
        await self.connect()
        
        query = "SELECT user_id FROM posts WHERE id = $1"
        
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(query, post_id)
            return row['user_id'] if row else None
    
    async def get_user_author_interactions(self, user_id: str, author_id: str) -> List[Dict]:
        """Get user's interactions with a specific author's posts"""
        await self.connect()
        
        query = """
            SELECT ue.post_id, ue.engagement_type, ue.timestamp
            FROM user_engagement ue
            JOIN posts p ON ue.post_id = p.id
            WHERE ue.user_id = $1 AND p.user_id = $2
            ORDER BY ue.timestamp DESC
            LIMIT 50
        """
        
        async with self.pool.acquire() as conn:
            rows = await conn.fetch(query, user_id, author_id)
            return [dict(row) for row in rows]
    
    async def get_author_stats(self, author_id: str) -> Dict:
        """Get author statistics"""
        await self.connect()
        
        query = """
            SELECT 
                COUNT(DISTINCT p.id) as total_posts,
                COUNT(ue.id) as total_engagements,
                COALESCE(COUNT(ue.id)::float / NULLIF(COUNT(DISTINCT p.id), 0), 0) as avg_engagement_per_post
            FROM posts p
            LEFT JOIN user_engagement ue ON p.id = ue.post_id
            WHERE p.user_id = $1
        """
        
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(query, author_id)
            return dict(row) if row else {'total_posts': 0, 'total_engagements': 0, 'avg_engagement_per_post': 0}
    
    async def find_users_by_posts(self, post_ids: List[str]) -> List[str]:
        """Find users who engaged with specific posts"""
        await self.connect()
        
        query = """
            SELECT DISTINCT user_id
            FROM user_engagement
            WHERE post_id = ANY($1)
            LIMIT 50
        """
        
        async with self.pool.acquire() as conn:
            rows = await conn.fetch(query, post_ids)
            return [row['user_id'] for row in rows]
    
    async def find_similar_posts(self, target_engagement: float, target_popularity: float, limit: int = 20) -> List[str]:
        """Find posts with similar engagement characteristics"""
        await self.connect()
        
        query = """
            SELECT p.id
            FROM posts p
            LEFT JOIN user_engagement ue ON p.id = ue.post_id
            GROUP BY p.id
            ORDER BY RANDOM()
            LIMIT $1
        """
        
        async with self.pool.acquire() as conn:
            rows = await conn.fetch(query, limit)
            return [row['id'] for row in rows]
    
    async def get_recent_posts(self, hours: int = 24, limit: int = 100) -> List[str]:
        """Get recent posts"""
        await self.connect()
        
        start_time = datetime.now() - timedelta(hours=hours)
        
        query = """
            SELECT id
            FROM posts
            WHERE created_at >= $1
            ORDER BY created_at DESC
            LIMIT $2
        """
        
        async with self.pool.acquire() as conn:
            rows = await conn.fetch(query, start_time, limit)
            return [row['id'] for row in rows]
    
    async def get_trending_posts(self, limit: int = 50) -> List[str]:
        """Get trending posts based on recent engagement"""
        await self.connect()
        
        recent_time = datetime.now() - timedelta(hours=24)
        
        query = """
            SELECT ue.post_id, COUNT(*) as engagement_count
            FROM user_engagement ue
            WHERE ue.timestamp >= $1
            GROUP BY ue.post_id
            ORDER BY engagement_count DESC
            LIMIT $2
        """
        
        async with self.pool.acquire() as conn:
            rows = await conn.fetch(query, recent_time, limit)
            return [row['post_id'] for row in rows]
    
    async def save_model_metadata(self, metadata: Dict):
        """Save model training metadata"""
        await self.connect()
        
        query = """
            INSERT INTO ml_models (model_version, training_date, data_size, metadata)
            VALUES ($1, $2, $3, $4)
            ON CONFLICT (model_version) DO UPDATE
            SET training_date = $2, data_size = $3, metadata = $4
        """
        
        async with self.pool.acquire() as conn:
            await conn.execute(
                query,
                metadata['model_version'],
                datetime.fromisoformat(metadata['training_date']),
                metadata['data_size'],
                str(metadata)
            )
    
    async def get_latest_model_metadata(self) -> Optional[Dict]:
        """Get latest model metadata"""
        await self.connect()
        
        query = """
            SELECT model_version, training_date, data_size, metadata
            FROM ml_models
            ORDER BY training_date DESC
            LIMIT 1
        """
        
        async with self.pool.acquire() as conn:
            row = await conn.fetchrow(query)
            return dict(row) if row else None