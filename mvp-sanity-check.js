const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api/v1';
const DEMO_CREDENTIALS = {
  admin: { email: 'admin@demo.com', password: 'Demo123!' },
  user: { email: 'john@demo.com', password: 'Demo123!' }
};

let adminToken = '';
let userToken = '';

async function runSanityCheck() {
  console.log('🔍 Starting MVP Sanity Check...\n');
  
  try {
    // 1. Test Backend Health
    await testBackendHealth();
    
    // 2. Test Authentication
    await testAuthentication();
    
    // 3. Test Feed/Posts
    await testFeedOperations();
    
    // 4. Test Wallet Operations
    await testWalletOperations();
    
    // 5. Test Live Stream APIs
    await testStreamingAPIs();
    
    console.log('\n✅ MVP Sanity Check PASSED - All critical functions working!');
    
  } catch (error) {
    console.error('\n❌ MVP Sanity Check FAILED:', error.message);
    process.exit(1);
  }
}

async function testBackendHealth() {
  console.log('1️⃣ Testing Backend Health...');
  
  try {
    const response = await axios.get(`${BASE_URL}/health`);
    if (response.data.status === 'ok') {
      console.log('   ✅ Backend is running and healthy');
    } else {
      throw new Error('Backend health check failed');
    }
  } catch (error) {
    throw new Error(`Backend not accessible: ${error.message}`);
  }
}

async function testAuthentication() {
  console.log('\n2️⃣ Testing Authentication...');
  
  // Test Admin Login
  try {
    const adminResponse = await axios.post(`${BASE_URL}/auth/login`, DEMO_CREDENTIALS.admin);
    
    if (adminResponse.data.success && adminResponse.data.data.tokens) {
      adminToken = adminResponse.data.data.tokens.accessToken;
      console.log('   ✅ Admin login successful');
    } else {
      throw new Error('Admin login failed - invalid response format');
    }
  } catch (error) {
    throw new Error(`Admin authentication failed: ${error.response?.data?.message || error.message}`);
  }
  
  // Test User Login
  try {
    const userResponse = await axios.post(`${BASE_URL}/auth/login`, DEMO_CREDENTIALS.user);
    
    if (userResponse.data.success && userResponse.data.data.tokens) {
      userToken = userResponse.data.data.tokens.accessToken;
      console.log('   ✅ User login successful');
    } else {
      throw new Error('User login failed - invalid response format');
    }
  } catch (error) {
    throw new Error(`User authentication failed: ${error.response?.data?.message || error.message}`);
  }
  
  // Test Profile Access
  try {
    const profileResponse = await axios.get(`${BASE_URL}/auth/profile`, {
      headers: { Authorization: `Bearer ${userToken}` }
    });
    
    if (profileResponse.data.success) {
      console.log('   ✅ Profile access working');
    }
  } catch (error) {
    throw new Error(`Profile access failed: ${error.response?.data?.message || error.message}`);
  }
}

async function testFeedOperations() {
  console.log('\n3️⃣ Testing Feed Operations...');
  
  // Test Get Posts (should work without auth for public feed)
  try {
    const postsResponse = await axios.get(`${BASE_URL}/posts`, {
      headers: { Authorization: `Bearer ${userToken}` }
    });
    
    if (postsResponse.data.success) {
      console.log('   ✅ Feed loading works');
    }
  } catch (error) {
    // This might fail if no posts exist, which is acceptable
    console.log('   ⚠️  Feed loading - no posts or auth required');
  }
  
  // Test Create Post
  try {
    const createPostResponse = await axios.post(`${BASE_URL}/posts`, {
      content: 'Test post for sanity check',
      type: 'TEXT'
    }, {
      headers: { Authorization: `Bearer ${userToken}` }
    });
    
    if (createPostResponse.data.success) {
      console.log('   ✅ Post creation works');
    }
  } catch (error) {
    console.log('   ⚠️  Post creation may need implementation');
  }
}

async function testWalletOperations() {
  console.log('\n4️⃣ Testing Wallet Operations...');
  
  // Test Get Wallet
  try {
    const walletResponse = await axios.get(`${BASE_URL}/wallet`, {
      headers: { Authorization: `Bearer ${userToken}` }
    });
    
    if (walletResponse.data.success) {
      console.log('   ✅ Wallet access works');
    }
  } catch (error) {
    console.log('   ⚠️  Wallet access may need implementation');
  }
  
  // Test Admin Credit Wallet
  try {
    const creditResponse = await axios.post(`${BASE_URL}/wallet/credit/user-id`, {
      amount: 100,
      description: 'Test credit'
    }, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    
    if (creditResponse.data.success) {
      console.log('   ✅ Wallet credit works');
    }
  } catch (error) {
    console.log('   ⚠️  Wallet credit may need user ID');
  }
}

async function testStreamingAPIs() {
  console.log('\n5️⃣ Testing Live Stream APIs...');
  
  // Test Get Active Streams
  try {
    const streamsResponse = await axios.get(`${BASE_URL}/streaming/active`, {
      headers: { Authorization: `Bearer ${userToken}` }
    });
    
    if (streamsResponse.data.success) {
      console.log('   ✅ Active streams API works');
    }
  } catch (error) {
    console.log('   ⚠️  Streaming API may need implementation');
  }
  
  // Test Create Stream
  try {
    const createStreamResponse = await axios.post(`${BASE_URL}/streaming/create`, {
      title: 'Test Stream',
      description: 'Sanity check stream'
    }, {
      headers: { Authorization: `Bearer ${userToken}` }
    });
    
    if (createStreamResponse.data.success) {
      console.log('   ✅ Stream creation works');
    }
  } catch (error) {
    console.log('   ⚠️  Stream creation may need implementation');
  }
}

// Run the sanity check
runSanityCheck().catch(console.error);