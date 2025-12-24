const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

async function testRoutes() {
  console.log('Testing Backend Routes...\n');

  // Test various auth endpoints
  const authEndpoints = [
    '/auth/login',
    '/api/auth/login',
    '/login'
  ];

  for (const endpoint of authEndpoints) {
    try {
      const response = await axios.post(`${BASE_URL}${endpoint}`, {
        email: 'john@example.com',
        password: 'password123'
      });
      console.log(`✓ ${endpoint} works!`);
      console.log('Response:', response.data);
      return; // Found working endpoint
    } catch (error) {
      console.log(`✗ ${endpoint} - ${error.response?.status || 'failed'}`);
    }
  }

  // Try to get any info from root
  try {
    const response = await axios.get(`${BASE_URL}/`);
    console.log('\nRoot endpoint response:', response.data);
  } catch (error) {
    console.log('\nRoot endpoint error:', error.message);
  }

  // Try health check
  try {
    const response = await axios.get(`${BASE_URL}/health`);
    console.log('\nHealth check:', response.data);
  } catch (error) {
    console.log('\nHealth check failed');
  }
}

testRoutes();
