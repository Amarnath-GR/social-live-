const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api/v1';

async function testAddComment() {
  console.log('Testing Add Comment...\n');

  try {
    const postId = '1';
    
    // 1. Add a comment
    console.log('1. Adding a comment...');
    const addResponse = await axios.post(`${BASE_URL}/comments/post/${postId}`, {
      content: 'This is my first comment!'
    });
    console.log('✓ Comment added:', JSON.stringify(addResponse.data, null, 2));

    // 2. Add another comment
    console.log('\n2. Adding another comment...');
    const addResponse2 = await axios.post(`${BASE_URL}/comments/post/${postId}`, {
      content: 'This is my second comment!'
    });
    console.log('✓ Comment added:', JSON.stringify(addResponse2.data, null, 2));

    // 3. Get all comments
    console.log('\n3. Fetching all comments...');
    const getResponse = await axios.get(`${BASE_URL}/comments/post/${postId}`);
    console.log('✓ Comments retrieved:');
    console.log(JSON.stringify(getResponse.data, null, 2));
    
    console.log(`\n✅ Success! Found ${getResponse.data.comments.length} comments`);

  } catch (error) {
    console.error('\n❌ Error:', error.message);
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data:', error.response.data);
    }
  }
}

testAddComment();
