import 'package:flutter/material.dart';
import '../models/user_models.dart';
import '../services/profile_service.dart';
import 'profile_edit_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final bool isCurrentUser;

  const UserProfileScreen({
    super.key,
    required this.userId,
    this.isCurrentUser = false,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with SingleTickerProviderStateMixin {
  User? _user;
  bool _isLoading = true;
  bool _isFollowing = false;
  late TabController _tabController;
  List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> _likedPosts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    
    final result = widget.isCurrentUser 
        ? await ProfileService.getCurrentUser()
        : await ProfileService.getUserById(widget.userId);
    
    if (result['success']) {
      setState(() {
        _user = result['user'];
        _isFollowing = _user?.isFollowing ?? false;
      });
      _loadPosts();
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _loadPosts() async {
    final result = await ProfileService.getUserPosts(widget.userId);
    if (result['success']) {
      setState(() => _posts = List<Map<String, dynamic>>.from(result['posts'] ?? []));
    }
  }

  Future<void> _toggleFollow() async {
    final result = _isFollowing 
        ? await ProfileService.unfollowUser(widget.userId)
        : await ProfileService.followUser(widget.userId);
    
    if (result['success']) {
      setState(() => _isFollowing = !_isFollowing);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('User not found')),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            title: Text(_user!.username),
            actions: [
              if (widget.isCurrentUser)
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {},
                ),
            ],
          ),
        ],
        body: Column(
          children: [
            _buildProfileHeader(),
            _buildTabBar(),
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundImage: _user!.avatar != null ? NetworkImage(_user!.avatar!) : null,
                child: _user!.avatar == null ? const Icon(Icons.person, size: 45) : null,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn('Posts', _user!.stats?.posts ?? 0),
                    _buildStatColumn('Followers', _user!.followersCount),
                    _buildStatColumn('Following', _user!.followingCount),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _user!.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (_user!.bio != null) ...[
                  const SizedBox(height: 4),
                  Text(_user!.bio!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (widget.isCurrentUser) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileEditScreen(user: _user!)),
                );
                if (result == true) _loadProfile();
              },
              child: const Text('Edit Profile'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              child: const Text('Share Profile'),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _toggleFollow,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isFollowing ? Colors.grey[300] : Theme.of(context).primaryColor,
              foregroundColor: _isFollowing ? Colors.black : Colors.white,
            ),
            child: Text(_isFollowing ? 'Following' : 'Follow'),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () {},
          child: const Icon(Icons.message),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(icon: Icon(Icons.grid_on)),
        Tab(icon: Icon(Icons.favorite_border)),
      ],
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildPostsGrid(_posts),
        _buildPostsGrid(_likedPosts),
      ],
    );
  }

  Widget _buildPostsGrid(List<Map<String, dynamic>> posts) {
    if (posts.isEmpty) {
      return const Center(child: Text('No posts yet'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return GestureDetector(
          onTap: () {},
          child: Container(
            color: Colors.grey[300],
            child: post['thumbnailUrl'] != null
                ? Image.network(post['thumbnailUrl'], fit: BoxFit.cover)
                : const Icon(Icons.video_library, size: 50),
          ),
        );
      },
    );
  }
}
