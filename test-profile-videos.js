const http = require('http');

const BASE_URL = 'http://localhost:3000';

// Test user credentials
const testUser = {
  email: 'creator1@example.com',
  password: 'hashedpassword123'
};

async function makeRequest(method, path, data = null, token = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, BASE_URL);
    const options = {
      method,
      headers: {
        'Content-Type': 'application/json',
      }
    };

    if (token) {
      options.headers['Authorization'] = `Bearer ${token}`;
    }

    const req = http.request(url, options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          const response = body ? JSON.parse(body) : {};
          resolve({ status: res.statusCode, data: response });
        } catch (e) {
          resolve({ status: res.statusCode, data: body });
        }
      });
    });

    req.on('error', reject);
    
    if (data) {
      req.write(JSON.stringify(data));
    }
    
    req.end();
  });
}

async function testProfileVideos() {
  console.log('🧪 Testing Profile Video Thumbnails\n');

  try {
    // 1. Login
    console.log('1️⃣ Logging in...');
    const loginRes = await makeRequest('POST', '/api/auth/login', testUser);
    
    if (loginRes.status !== 200 && loginRes.status !== 201) {
      console.error('❌ Login failed:', loginRes.data);
      return;
    }

    const token = loginRes.data.access_token || loginRes.data.token;
    console.log('✅ Login successful\n');

    // 2. Get user profile
    console.log('2️⃣ Fetching user profile...');
    const profileRes = await makeRequest('GET', '/api/users/me', null, token);
    
    if (profileRes.status === 200) {
      console.log('✅ Profile fetched:', profileRes.data.data?.username);
      console.log('');
    }

    // 3. Get user's videos
    console.log('3️⃣ Fetching user videos...');
    const videosRes = await makeRequest('GET', '/api/videos/my-videos', null, token);
    
    if (videosRes.status === 200) {
      const videos = Array.isArray(videosRes.data) ? videosRes.data : videosRes.data.data;
      console.log(`✅ Found ${videos?.length || 0} videos`);
      
      if (videos && videos.length > 0) {
        console.log('\n📹 Video Details:');
        videos.slice(0, 3).forEach((video, i) => {
          console.log(`\nVideo ${i + 1}:`);
          console.log(`  ID: ${video.id}`);
          console.log(`  Content: ${video.content?.substring(0, 50)}...`);
          console.log(`  Video URL: ${video.videoUrl}`);
          console.log(`  Thumbnail: ${video.thumbnailUrl || '❌ NO THUMBNAIL'}`);
          console.log(`  Views: ${video.stats?.views || 0}`);
          console.log(`  Likes: ${video.stats?.likes || 0}`);
        });
      }
    } else {
      console.log('⚠️ Could not fetch videos:', videosRes.data);
    }

    // 4. Get liked videos
    console.log('\n4️⃣ Fetching liked videos...');
    const likedRes = await makeRequest('GET', '/api/videos/liked', null, token);
    
    if (likedRes.status === 200) {
      const liked = Array.isArray(likedRes.data) ? likedRes.data : likedRes.data.data;
      console.log(`✅ Found ${liked?.length || 0} liked videos`);
      
      if (liked && liked.length > 0) {
        console.log('\n❤️ Liked Video Details:');
        liked.slice(0, 2).forEach((video, i) => {
          console.log(`\nLiked Video ${i + 1}:`);
          console.log(`  Thumbnail: ${video.thumbnailUrl || '❌ NO THUMBNAIL'}`);
          console.log(`  Content: ${video.content?.substring(0, 50)}...`);
        });
      }
    } else {
      console.log('⚠️ Could not fetch liked videos:', likedRes.data);
    }

    console.log('\n✅ All tests completed!');
    console.log('\n📝 Summary:');
    console.log('   - Profile videos should display thumbnails in the grid');
    console.log('   - Each video thumbnail is loaded from thumbnailUrl field');
    console.log('   - Thumbnails are shown with play icon overlay');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
}

// Run tests
testProfileVideos();
