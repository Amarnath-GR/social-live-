const http = require('http');
const url = require('url');

const PORT = 3000;

const server = http.createServer((req, res) => {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  
  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  const parsedUrl = url.parse(req.url, true);
  const path = parsedUrl.pathname;
  
  res.setHeader('Content-Type', 'application/json');

  // Health check
  if (path === '/api/v1/health' && req.method === 'GET') {
    res.writeHead(200);
    res.end(JSON.stringify({ 
      success: true, 
      message: 'Backend connected successfully', 
      timestamp: new Date().toISOString() 
    }));
    return;
  }

  // Login endpoint
  if (path === '/api/v1/auth/login' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      try {
        const { email, password } = JSON.parse(body);
        
        if ((email === 'admin@demo.com' || email === 'john@demo.com') && password === 'Demo123!') {
          res.writeHead(200);
          res.end(JSON.stringify({
            success: true,
            data: {
              tokens: {
                accessToken: 'mock-access-token',
                refreshToken: 'mock-refresh-token'
              },
              user: {
                id: '1',
                email: email,
                name: email === 'admin@demo.com' ? 'Admin User' : 'John Doe',
                role: email === 'admin@demo.com' ? 'admin' : 'user'
              }
            }
          }));
        } else {
          res.writeHead(401);
          res.end(JSON.stringify({ success: false, message: 'Invalid credentials' }));
        }
      } catch (e) {
        res.writeHead(400);
        res.end(JSON.stringify({ success: false, message: 'Invalid JSON' }));
      }
    });
    return;
  }

  // Posts endpoint
  if (path === '/api/v1/posts' && req.method === 'GET') {
    res.writeHead(200);
    res.end(JSON.stringify([
      { id: 1, title: 'Welcome to Social Live', content: 'Demo post 1' },
      { id: 2, title: 'Live Streaming', content: 'Demo post 2' }
    ]));
    return;
  }

  // Default 404
  res.writeHead(404);
  res.end(JSON.stringify({ success: false, message: 'Not found' }));
});

server.listen(PORT, () => {
  console.log(`Mock server running on http://localhost:${PORT}`);
  console.log('Endpoints: /api/v1/health, /api/v1/auth/login, /api/v1/posts');
});