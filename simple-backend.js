const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

// In-memory storage
const comments = {};

// Health check
app.get('/api/v1', (req, res) => {
  res.json({ message: 'Social Live Backend is running!', status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/api/v1/health', (req, res) => {
  res.json({ status: 'ok', message: 'Backend is healthy', timestamp: new Date().toISOString() });
});

// Posts endpoint
app.get('/api/v1/posts', (req, res) => {
  res.json([
    {
      id: '1',
      content: 'Welcome to Social Live!',
      userId: 'system',
      createdAt: new Date().toISOString(),
      user: { id: 'system', username: 'system', name: 'System', avatar: null }
    },
    {
      id: '2',
      content: 'Test post with comments',
      userId: 'user1',
      createdAt: new Date().toISOString(),
      user: { id: 'user1', username: 'john_doe', name: 'John Doe', avatar: null }
    }
  ]);
});

// Mock endpoints
app.get('/api/v1/users/me', (req, res) => {
  res.json({
    success: true,
    data: {
      id: '1',
      username: 'testuser',
      name: 'Test User',
      email: 'test@example.com',
      avatar: null,
      bio: 'Test bio',
      followersCount: 100,
      followingCount: 50,
      stats: { posts: 10, likes: 200, comments: 30 }
    }
  });
});

app.get('/api/v1/wallet/balance', (req, res) => {
  res.json({ success: true, data: { balance: 1000 } });
});

app.get('/api/v1/wallet/transactions', (req, res) => {
  res.json({ success: true, data: [] });
});

app.get('/api/v1/posts/user/:userId', (req, res) => {
  res.json({ success: true, posts: [] });
});

// Get comments for a post
app.get('/api/v1/comments/post/:postId', (req, res) => {
  const { postId } = req.params;
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 20;
  
  const postComments = comments[postId] || [];
  const total = postComments.length;
  const start = (page - 1) * limit;
  const end = start + limit;
  const paginatedComments = postComments.slice(start, end);
  
  res.json({
    comments: paginatedComments,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit)
    }
  });
});

// Add a comment
app.post('/api/v1/comments/post/:postId', (req, res) => {
  const { postId } = req.params;
  const { content } = req.body;
  
  if (!comments[postId]) {
    comments[postId] = [];
  }
  
  const newComment = {
    id: `comment_${Date.now()}`,
    content,
    createdAt: new Date().toISOString(),
    postId,
    user: {
      id: '1',
      username: 'testuser',
      name: 'Test User',
      avatar: null
    }
  };
  
  comments[postId].unshift(newComment);
  res.json(newComment);
});

app.get('/api/v1/marketplace/orders/user', (req, res) => {
  res.json({ success: true, orders: [] });
});

const PORT = 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Backend server running on http://localhost:${PORT}`);
  console.log(`Backend server running on http://192.168.1.6:${PORT}`);
});