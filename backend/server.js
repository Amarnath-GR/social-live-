const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

// Health check
app.get('/api/v1', (req, res) => {
  res.json({ success: true, message: 'Backend running' });
});

// User endpoints
app.get('/api/v1/users/me', (req, res) => {
  res.json({
    success: true,
    data: {
      id: 'user_1',
      username: 'myusername',
      name: 'My Name',
      email: 'user@example.com',
      bio: 'Content Creator & Social Media Enthusiast',
      avatar: null,
      role: 'USER',
      isBlocked: false,
      kycVerified: false,
      followersCount: 0,
      followingCount: 237,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    }
  });
});

app.get('/api/v1/posts/user/:userId', (req, res) => {
  res.json({ success: true, posts: [] });
});

app.post('/api/v1/users/avatar', (req, res) => {
  res.json({ success: true, data: { url: 'https://via.placeholder.com/150' } });
});

app.put('/api/v1/users/me', (req, res) => {
  res.json({ success: true, data: req.body });
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Backend running on http://localhost:${PORT}/api/v1`);
});
