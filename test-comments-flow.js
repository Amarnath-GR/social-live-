const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api/v1';

async function testCommentsFlow() {
  console.log('Testing Comments Flow...\n');

  try {
    // 1. Get posts
    console.log('1. Fetching posts...');
    const postsResponse = await axios.get(`${BASE_URL}/posts`);
    const posts = postsResponse.data;
    console.log(`✓ Found ${posts.length} posts`);
    
    if (posts.length === 0) {
      console.log('❌ No posts available');
      return;
    }
    
    const postId = posts[0].id;
    console.log(`Using post ID: ${postId}\n`);

    // 2. Try to get comments WITHOUT auth
    console.log('2. Getting comments (no auth)...');
    try {
      const commentsResponse = await axios.get(`${BASE_URL}/comments/post/${postId}`);
      console.log('✓ Comments endpoint works without auth!');
      console.log('Response:', JSON.stringify(commentsResponse.data, null, 2));
    } catch (error) {
      console.log(`✗ Status: ${error.response?.status} - ${error.response?.data?.message || error.message}`);
      
      if (error.response?.status === 401) {
        console.log('\n❌ Comments require authentication');
        console.log('Need to implement auth or make comments public');
      }
    }

    // 3. Try different comment endpoint patterns
    console.log('\n3. Trying alternative endpoints...');
    const alternatives = [
      `/posts/${postId}/comments`,
      `/post/${postId}/comments`,
      `/comments/${postId}`,
    ];

    for (const endpoint of alternatives) {
      try {
        const response = await axios.get(`${BASE_URL}${endpoint}`);
        console.log(`✓ ${endpoint} works!`);
        console.log('Response:', JSON.stringify(response.data, null, 2));
        break;
      } catch (error) {
        console.log(`✗ ${endpoint} - Status: ${error.response?.status || 'failed'}`);
      }
    }

  } catch (error) {
    console.error('\n❌ Error:', error.message);
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data:', error.response.data);
    }
  }
}

testCommentsFlow();
