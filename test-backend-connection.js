const http = require('http');

const testBackend = () => {
  const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/api/v1/posts',
    method: 'GET',
    headers: {
      'Content-Type': 'application/json'
    }
  };

  const req = http.request(options, (res) => {
    console.log(`✅ Backend server is running on port 3000`);
    console.log(`Status: ${res.statusCode}`);
    console.log(`Headers:`, res.headers);
    
    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
    });
    
    res.on('end', () => {
      console.log('Response:', data);
    });
  });

  req.on('error', (err) => {
    console.log(`❌ Backend server connection failed: ${err.message}`);
    console.log('Make sure the backend server is running on port 3000');
  });

  req.setTimeout(5000, () => {
    console.log('❌ Connection timeout - backend server may not be running');
    req.destroy();
  });

  req.end();
};

console.log('🔍 Testing backend server connectivity...');
testBackend();