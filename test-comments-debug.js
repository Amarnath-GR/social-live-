const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api/v1';

async function testComments() {
  console.log('Testing Comments System...\n');

  try {
    // 1. Login to get token
    console.log('1. Logging in...');
    const loginResponse = await axios.post(`${BASE_URL}/auth/login`, {
      email: 'john@example.com',
      password: 'password123'
    });
    
    const token = loginResponse.data.access_token;
    console.log('✓ Login successful');
    console.log('Token:', token.substring(0, 20) + '...\n');

    // 2. Get all posts to find a valid postId
    console.log('2. Fetching posts...');
    const postsResponse = await axios.get(`${BASE_URL}/feed`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    const posts = postsResponse.data.posts || postsResponse.data;
    console.log(`✓ Found ${posts.length} posts`);
    
    if (posts.length === 0) {
      console.log('❌ No posts found. Cannot test comments.');
      return;
    }
    
    const postId = posts[0].id;
    console.log(`Using post ID: ${postId}\n`);

    // 3. Get existing comments for this post
    console.log('3. Fetching existing comments...');
    const getCommentsResponse = await axios.get(`${BASE_URL}/comments/post/${postId}`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    console.log('Comments response:', JSON.stringify(getCommentsResponse.data, null, 2));
    
    const existingComments = getCommentsResponse.data.comments || [];
    console.log(`✓ Found ${existingComments.length} existing comments\n`);

    // 4. Add a new comment
    console.log('4. Adding a new comment...');
    const addCommentResponse = await axios.post(
      `${BASE_URL}/comments/post/${postId}`,
      { content: 'This is a test comment from debug script!' },
      { headers: { Authorization: `Bearer ${token}` } }
    );
    
    console.log('Add comment response:', JSON.stringify(addCommentResponse.data, null, 2));
    console.log('✓ Comment added successfully\n');

    // 5. Fetch comments again to verify
    console.log('5. Fetching comments again...');
    const verifyResponse = await axios.get(`${BASE_URL}/comments/post/${postId}`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    const updatedComments = verifyResponse.data.comments || [];
    console.log(`✓ Now have ${updatedComments.length} comments`);
    console.log('\nAll comments:');
    updatedComments.forEach((comment, index) => {
      console.log(`  ${index + 1}. ${comment.user?.username || 'Unknown'}: ${comment.content}`);
    });

  } catch (error) {
    console.error('\n❌ Error:', error.response?.data || error.message);
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data:', JSON.stringify(error.response.data, null, 2));
    }
  }
}

testComments();
