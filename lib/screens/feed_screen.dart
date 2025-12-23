import 'package:flutter/material.dart';
import '../services/feed_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<dynamic> _posts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await FeedService.getChronologicalFeed();
    
    setState(() {
      _isLoading = false;
      if (result['success']) {
        _posts = List<dynamic>.from(result['data'] ?? []);
      } else {
        _error = result['message'];
      }
    });
  }

  void _onPostView(int postId) {
    FeedService.trackView(postId);
  }

  void _onPostLike(int postId) {
    FeedService.trackLike(postId);
  }

  void _onPostComment(int postId) {
    FeedService.trackComment(postId);
  }

  void _onPostShare(int postId) {
    FeedService.trackShare(postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFeed,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No videos yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start creating content to see videos here',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFeed,
      child: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return _buildPostCard(post);
        },
      ),
    );
  }

  Widget _buildPostCard(dynamic post) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              child: Text(post['user']?['name']?[0] ?? 'U'),
            ),
            title: Text(post['user']?['name'] ?? 'Unknown'),
            subtitle: Text(_formatDate(post['createdAt'])),
          ),
          if (post['title'] != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                post['title'],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          if (post['content'] != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(post['content']),
            ),
          if (post['imageUrl'] != null)
            Image.network(
              post['imageUrl'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image),
                );
              },
            ),
          _buildEngagementBar(post),
        ],
      ),
    );
  }

  Widget _buildEngagementBar(dynamic post) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildEngagementButton(
            Icons.thumb_up,
            '0',
            () => _onPostLike(int.tryParse(post['id']?.toString() ?? '0') ?? 0),
          ),
          _buildEngagementButton(
            Icons.comment,
            '0',
            () => _onPostComment(int.tryParse(post['id']?.toString() ?? '0') ?? 0),
          ),
          _buildEngagementButton(
            Icons.share,
            '0',
            () => _onPostShare(int.tryParse(post['id']?.toString() ?? '0') ?? 0),
          ),
          _buildEngagementButton(
            Icons.visibility,
            '0',
            () => _onPostView(int.tryParse(post['id']?.toString() ?? '0') ?? 0),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementButton(IconData icon, String count, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 4),
            Text(count),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      
      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
      return 'Just now';
    } catch (e) {
      return '';
    }
  }
}
