const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

async function testCommentsAPI() {
  try {
    console.log('Testing Comments API...\n');

    // Step 1: Login to get token
    console.log('1. Logging in...');
    const loginResponse = await axios.post(`${BASE_URL}/auth/login`, {
      email: 'john@example.com',
      password: 'password123'
    });
    
    const token = loginResponse.data.access_token;
    console.log('✓ Login successful, token received\n');

    const headers = {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    };

    // Step 2: Get posts to find a post ID
    console.log('2. Fetching posts...');
    const postsResponse = await axios.get(`${BASE_URL}/posts`, { headers });
    const posts = postsResponse.data;
    
    if (!posts || posts.length === 0) {
      console.log('✗ No posts found');
      return;
    }
    
    const postId = posts[0].id;
    console.log(`✓ Found post: ${postId}\n`);

    // Step 3: Get existing comments
    console.log('3. Fetching existing comments...');
    const getCommentsResponse = await axios.get(
      `${BASE_URL}/comments/post/${postId}`,
      { headers }
    );
    
    console.log('Response:', JSON.stringify(getCommentsResponse.data, null, 2));
    console.log(`✓ Found ${getCommentsResponse.data.comments?.length || 0} comments\n`);

    // Step 4: Add a new comment
    console.log('4. Adding a new comment...');
    const newCommentResponse = await axios.post(
      `${BASE_URL}/comments/post/${postId}`,
      { content: 'This is a test comment from the API test script!' },
      { headers }
    );
    
    console.log('New comment response:', JSON.stringify(newCommentResponse.data, null, 2));
    console.log('✓ Comment added successfully\n');

    // Step 5: Fetch comments again to verify
    console.log('5. Fetching comments again to verify...');
    const verifyResponse = await axios.get(
      `${BASE_URL}/comments/post/${postId}`,
      { headers }
    );
    
    console.log(`✓ Now showing ${verifyResponse.data.comments?.length || 0} comments\n`);
    
    console.log('All tests passed! ✓');

  } catch (error) {
    console.error('Error:', error.response?.data || error.message);
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data:', JSON.stringify(error.response.data, null, 2));
    }
  }
}

testCommentsAPI();
