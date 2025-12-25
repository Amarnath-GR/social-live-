import 'package:flutter/material.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _stats = [
    {'title': 'Total Users', 'value': '1.2M', 'icon': Icons.people, 'color': Colors.blue},
    {'title': 'Active Posts', 'value': '45K', 'icon': Icons.video_library, 'color': Colors.purple},
    {'title': 'Reports', 'value': '234', 'icon': Icons.flag, 'color': Colors.orange},
    {'title': 'Revenue', 'value': '\$12.5K', 'icon': Icons.attach_money, 'color': Colors.green},
  ];

  final List<Map<String, dynamic>> _users = [
    {'name': 'John Doe', 'email': 'john@demo.com', 'status': 'Active', 'posts': 45},
    {'name': 'Jane Smith', 'email': 'jane@demo.com', 'status': 'Active', 'posts': 32},
    {'name': 'Mike Johnson', 'email': 'mike@demo.com', 'status': 'Suspended', 'posts': 12},
    {'name': 'Sarah Wilson', 'email': 'sarah@demo.com', 'status': 'Active', 'posts': 67},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text('Admin Panel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopStats(),
            SizedBox(height: 16),
            _buildTabBar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStats() {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: _stats.length,
        itemBuilder: (context, index) {
          final stat = _stats[index];
          return Container(
            width: 140,
            margin: EdgeInsets.only(right: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(stat['icon'], color: stat['color'], size: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat['value'],
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      stat['title'],
                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 50,
      child: Row(
        children: [
          _buildTab('Users', 0),
          _buildTab('Content', 1),
          _buildTab('Reports', 2),
          _buildTab('Settings', 3),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.purple : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildUsersTab();
      case 1:
        return _buildContentTab();
      case 2:
        return _buildReportsTab();
      case 3:
        return _buildSettingsTab();
      default:
        return _buildUsersTab();
    }
  }

  Widget _buildUsersTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.purple,
                child: Text(user['name'][0], style: TextStyle(color: Colors.white)),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['name'],
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user['email'],
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: user['status'] == 'Active' ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user['status'],
                  style: TextStyle(
                    color: user['status'] == 'Active' ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(width: 8),
              PopupMenuButton(
                icon: Icon(Icons.more_vert, color: Colors.white),
                color: Colors.grey[800],
                onSelected: (value) {
                  if (value == 'view') {
                    _showUserProfile(user);
                  } else if (value == 'suspend') {
                    _suspendUser(index);
                  } else if (value == 'delete') {
                    _deleteUser(index);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Text('View Profile', style: TextStyle(color: Colors.white)),
                    value: 'view',
                  ),
                  PopupMenuItem(
                    child: Text('Suspend', style: TextStyle(color: Colors.orange)),
                    value: 'suspend',
                  ),
                  PopupMenuItem(
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                    value: 'delete',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUserProfile(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('User Profile', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${user['name']}', style: TextStyle(color: Colors.white)),
            SizedBox(height: 8),
            Text('Email: ${user['email']}', style: TextStyle(color: Colors.grey[400])),
            SizedBox(height: 8),
            Text('Status: ${user['status']}', style: TextStyle(color: Colors.grey[400])),
            SizedBox(height: 8),
            Text('Posts: ${user['posts']}', style: TextStyle(color: Colors.grey[400])),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
    );
  }

  void _suspendUser(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Suspend User', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to suspend ${_users[index]['name']}?',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _users[index]['status'] = 'Suspended';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('User suspended'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Suspend', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteUser(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Delete User', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete ${_users[index]['name']}? This action cannot be undone.',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _users.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('User deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildContentTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library, color: Colors.grey[600], size: 64),
          SizedBox(height: 16),
          Text('Content Management', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
          SizedBox(height: 8),
          Text('Manage posts and videos', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flag, color: Colors.grey[600], size: 64),
          SizedBox(height: 16),
          Text('Reports', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
          SizedBox(height: 8),
          Text('Review user reports', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildSettingItem('Platform Settings', Icons.settings),
        _buildSettingItem('User Permissions', Icons.security),
        _buildSettingItem('Content Moderation', Icons.shield),
        _buildSettingItem('Analytics', Icons.analytics),
        _buildSettingItem('Notifications', Icons.notifications),
      ],
    );
  }

  Widget _buildSettingItem(String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(title, style: TextStyle(color: Colors.white)),
            content: Text(
              'This feature is coming soon!',
              style: TextStyle(color: Colors.grey[400]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK', style: TextStyle(color: Colors.purple)),
              ),
            ],
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.purple),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16),
          ],
        ),
      ),
    );
  }
}
