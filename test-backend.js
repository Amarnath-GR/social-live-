const http = require('http');

function testBackend() {
  const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/api/v1/health',
    method: 'GET'
  };

  const req = http.request(options, (res) => {
    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
    });
    res.on('end', () => {
      console.log('✅ Backend Response:', JSON.parse(data));
      console.log('✅ Backend is working correctly!');
    });
  });

  req.on('error', (err) => {
    console.log('❌ Backend connection failed:', err.message);
    console.log('❌ Make sure to start the backend first with: node quick-backend.js');
  });

  req.end();
}

console.log('Testing backend connection...');
testBackend();