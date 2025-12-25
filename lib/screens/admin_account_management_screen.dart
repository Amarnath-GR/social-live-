import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AdminAccountManagementScreen extends StatefulWidget {
  const AdminAccountManagementScreen({super.key});

  @override
  State<AdminAccountManagementScreen> createState() => _AdminAccountManagementScreenState();
}

class _AdminAccountManagementScreenState extends State<AdminAccountManagementScreen> {
  final _searchController = TextEditingController();
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final result = await AuthService.getAllUsers();
      if (result['success']) {
        setState(() {
          _users = result['users'];
          _filteredUsers = _users;
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to load users: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = _users.where((user) =>
        user.username.toLowerCase().contains(query.toLowerCase()) ||
        user.email.toLowerCase().contains(query.toLowerCase()) ||
        user.name.toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  Future<void> _performUserAction(UserModel user, String action) async {
    setState(() => _isLoading = true);
    try {
      Map<String, dynamic> result;
      switch (action) {
        case 'suspend':
          result = await AuthService.suspendUser(user.id);
          break;
        case 'activate':
          result = await AuthService.activateUser(user.id);
          break;
        case 'delete':
          result = await AuthService.deleteUser(user.id);
          break;
        case 'reset_password':
          result = await AuthService.resetUserPassword(user.id);
          break;
        default:
          return;
      }

      if (result['success']) {
        _showSuccessDialog('Action completed successfully');
        _loadUsers();
      } else {
        _showErrorDialog(result['message']);
      }
    } catch (e) {
      _showErrorDialog('Action failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showUserActions(UserModel user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage ${user.username}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.pause_circle, color: Colors.orange),
              title: const Text('Suspend Account'),
              onTap: () {
                Navigator.pop(context);
                _confirmAction(user, 'suspend', 'suspend this account');
              },
            ),
            ListTile(
              leading: const Icon(Icons.play_circle, color: Colors.green),
              title: const Text('Activate Account'),
              onTap: () {
                Navigator.pop(context);
                _confirmAction(user, 'activate', 'activate this account');
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_reset, color: Colors.blue),
              title: const Text('Reset Password'),
              onTap: () {
                Navigator.pop(context);
                _confirmAction(user, 'reset_password', 'reset password for this account');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete Account'),
              onTap: () {
                Navigator.pop(context);
                _confirmAction(user, 'delete', 'permanently delete this account');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmAction(UserModel user, String action, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Action'),
        content: Text('Are you sure you want to $description for ${user.username}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performUserAction(user, action);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'delete' ? Colors.red : Theme.of(context).primaryColor,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('User Management', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Search users...',
                labelStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.purple[300]),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filterUsers,
            ),
          ),
          
          // Stats Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.blue[700]!, Colors.blue[900]!]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.people, size: 32, color: Colors.white),
                        const SizedBox(height: 8),
                        Text(
                          '${_users.length}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const Text('Total Users', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.green[700]!, Colors.green[900]!]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.verified_user, size: 32, color: Colors.white),
                        const SizedBox(height: 8),
                        Text(
                          '${_users.where((u) => u.verified).length}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const Text('Verified', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Users List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? const Center(
                        child: Text(
                          'No users found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.purple.withOpacity(0.2)),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: user.avatar != null
                                    ? NetworkImage(user.avatar!)
                                    : null,
                                child: user.avatar == null
                                    ? Text(user.username[0].toUpperCase())
                                    : null,
                              ),
                              title: Row(
                                children: [
                                  Text(user.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  if (user.verified) ...[
                                    const SizedBox(width: 4),
                                    Icon(Icons.verified, size: 16, color: Colors.blue[300]),
                                  ],
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.email, style: TextStyle(color: Colors.grey[400])),
                                  Text(
                                    'Role: ${user.role}',
                                    style: TextStyle(
                                      color: user.role == 'admin' ? Colors.red[300] : Colors.grey[500],
                                      fontWeight: user.role == 'admin' ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: user.isActive ? Colors.green[700] : Colors.red[700],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      user.isActive ? 'Active' : 'Suspended',
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(Icons.more_vert, color: Colors.purple[300]),
                                    onPressed: () => _showUserActions(user),
                                  ),
                                ],
                              ),
                              onTap: () => _showUserDetails(user),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details: ${user.username}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email', user.email),
              _buildDetailRow('Name', user.name),
              _buildDetailRow('Role', user.role),
              _buildDetailRow('Status', user.isActive ? 'Active' : 'Suspended'),
              _buildDetailRow('Verified', user.verified ? 'Yes' : 'No'),
              _buildDetailRow('Created', user.createdAt.toString().split('.')[0]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showUserActions(user);
            },
            child: const Text('Manage'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}