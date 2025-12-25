const express = require('express');
const app = express();
const port = 3000;

app.use(express.json());
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  if (req.method === 'OPTIONS') {
    res.sendStatus(200);
  } else {
    next();
  }
});

// Health check
app.get('/api/v1/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Auth endpoints
app.post('/api/v1/auth/login', (req, res) => {
  const { email, password } = req.body;
  if (email === 'admin@demo.com' && password === 'Demo123!') {
    res.json({
      access_token: 'demo_token_admin',
      user: { id: 1, email: 'admin@demo.com', role: 'admin' }
    });
  } else if (email === 'john@demo.com' && password === 'Demo123!') {
    res.json({
      access_token: 'demo_token_user',
      user: { id: 2, email: 'john@demo.com', role: 'user' }
    });
  } else {
    res.status(401).json({ message: 'Invalid credentials' });
  }
});

app.listen(port, '0.0.0.0', () => {
  console.log(`🚀 Minimal server running on http://localhost:${port}`);
  console.log(`📡 API available at http://localhost:${port}/api/v1`);
  console.log(`✅ Server started successfully (minimal mode)`);
});