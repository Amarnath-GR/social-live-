const axios = require('axios');

async function discoverRoutes() {
  const baseUrls = [
    'http://localhost:3000',
    'http://localhost:3000/api',
    'http://localhost:3000/api/v1'
  ];

  const testPaths = [
    '/',
    '/health',
    '/auth/login',
    '/feed',
    '/posts',
    '/comments',
    '/users'
  ];

  console.log('Discovering available routes...\n');

  for (const baseUrl of baseUrls) {
    console.log(`\nTesting ${baseUrl}:`);
    console.log('='.repeat(50));
    
    for (const path of testPaths) {
      try {
        const response = await axios.get(`${baseUrl}${path}`, {
          timeout: 2000,
          validateStatus: () => true // Accept any status
        });
        console.log(`✓ GET ${path} - Status: ${response.status}`);
        if (response.status === 200 && response.data) {
          console.log(`  Response: ${JSON.stringify(response.data).substring(0, 100)}`);
        }
      } catch (error) {
        if (error.response) {
          console.log(`✗ GET ${path} - Status: ${error.response.status}`);
        } else {
          console.log(`✗ GET ${path} - ${error.code || 'Error'}`);
        }
      }
    }
  }
}

discoverRoutes();
