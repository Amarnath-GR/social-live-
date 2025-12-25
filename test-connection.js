const http = require('http');

const testUrls = [
  'http://localhost:2307/api/v1/health',
  'http://127.0.0.1:2307/api/v1/health',
  'http://172.29.212.108:2307/api/v1/health'
];

console.log('Testing backend connectivity...\n');

testUrls.forEach((url, index) => {
  const urlObj = new URL(url);
  
  const options = {
    hostname: urlObj.hostname,
    port: urlObj.port,
    path: urlObj.pathname,
    method: 'GET',
    timeout: 5000
  };

  const req = http.request(options, (res) => {
    let data = '';
    res.on('data', (chunk) => data += chunk);
    res.on('end', () => {
      console.log(`✅ ${url} - Status: ${res.statusCode}`);
      if (res.statusCode === 200) {
        console.log(`   Response: ${data.substring(0, 100)}...`);
      }
    });
  });

  req.on('error', (err) => {
    console.log(`❌ ${url} - Error: ${err.message}`);
  });

  req.on('timeout', () => {
    console.log(`⏰ ${url} - Timeout`);
    req.destroy();
  });

  req.end();
});