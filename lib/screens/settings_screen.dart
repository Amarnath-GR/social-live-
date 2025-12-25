import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'profile_settings_screen.dart';
import 'notification_settings_screen.dart';
import 'privacy_settings_screen.dart';
import 'help_support_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  bool _autoPlayVideos = true;
  bool _saveDataMode = false;
  String _language = 'English';
  String _videoQuality = 'Auto';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? true;
      _autoPlayVideos = prefs.getBool('auto_play_videos') ?? true;
      _saveDataMode = prefs.getBool('save_data_mode') ?? false;
      _language = prefs.getString('language') ?? 'English';
      _videoQuality = prefs.getString('video_quality') ?? 'Auto';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('dark_mode_enabled', _darkModeEnabled);
    await prefs.setBool('auto_play_videos', _autoPlayVideos);
    await prefs.setBool('save_data_mode', _saveDataMode);
    await prefs.setString('language', _language);
    await prefs.setString('video_quality', _videoQuality);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text('Settings', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          _buildSection('Account', [
            _buildListTile(
              icon: Icons.person,
              title: 'Edit Profile',
              subtitle: 'Update your profile information',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileSettingsScreen()),
              ),
            ),
            _buildListTile(
              icon: Icons.security,
              title: 'Privacy & Security',
              subtitle: 'Manage your privacy settings',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrivacySettingsScreen()),
              ),
            ),
            _buildListTile(
              icon: Icons.block,
              title: 'Blocked Users',
              subtitle: 'Manage blocked accounts',
              onTap: () => _showBlockedUsers(),
            ),
          ]),
          
          _buildSection('Notifications', [
            _buildSwitchTile(
              icon: Icons.notifications,
              title: 'Push Notifications',
              subtitle: 'Receive notifications for likes, comments, and follows',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
                _saveSettings();
              },
            ),
            _buildListTile(
              icon: Icons.tune,
              title: 'Notification Settings',
              subtitle: 'Customize notification preferences',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationSettingsScreen()),
              ),
            ),
          ]),

          _buildSection('Playback & Performance', [
            _buildSwitchTile(
              icon: Icons.play_arrow,
              title: 'Auto-play Videos',
              subtitle: 'Automatically play videos in feed',
              value: _autoPlayVideos,
              onChanged: (value) {
                setState(() => _autoPlayVideos = value);
                _saveSettings();
              },
            ),
            _buildSwitchTile(
              icon: Icons.data_usage,
              title: 'Data Saver Mode',
              subtitle: 'Reduce data usage',
              value: _saveDataMode,
              onChanged: (value) {
                setState(() => _saveDataMode = value);
                _saveSettings();
              },
            ),
            _buildListTile(
              icon: Icons.high_quality,
              title: 'Video Quality',
              subtitle: _videoQuality,
              onTap: () => _showVideoQualityDialog(),
            ),
          ]),

          _buildSection('App Preferences', [
            _buildSwitchTile(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              subtitle: 'Use dark theme',
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() => _darkModeEnabled = value);
                _saveSettings();
              },
            ),
            _buildListTile(
              icon: Icons.language,
              title: 'Language',
              subtitle: _language,
              onTap: () => _showLanguageDialog(),
            ),
            _buildListTile(
              icon: Icons.storage,
              title: 'Storage & Cache',
              subtitle: 'Manage app storage',
              onTap: () => _showStorageDialog(),
            ),
          ]),

          _buildSection('Support & Legal', [
            _buildListTile(
              icon: Icons.help,
              title: 'Help & Support',
              subtitle: 'Get help and contact support',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpSupportScreen()),
              ),
            ),
            _buildListTile(
              icon: Icons.info,
              title: 'About',
              subtitle: 'App version and information',
              onTap: () => _showAboutDialog(),
            ),
            _buildListTile(
              icon: Icons.description,
              title: 'Terms of Service',
              subtitle: 'Read our terms and conditions',
              onTap: () => _showTermsDialog(),
            ),
            _buildListTile(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              onTap: () => _showPrivacyDialog(),
            ),
          ]),

          _buildSection('Account Actions', [
            _buildListTile(
              icon: Icons.logout,
              title: 'Sign Out',
              subtitle: 'Sign out of your account',
              onTap: () => _showSignOutDialog(),
              textColor: Colors.orange,
            ),
            _buildListTile(
              icon: Icons.delete_forever,
              title: 'Delete Account',
              subtitle: 'Permanently delete your account',
              onTap: () => _showDeleteAccountDialog(),
              textColor: Colors.red,
            ),
          ]),

          SizedBox(height: 20),
          Center(
            child: Text(
              'Social Live v1.0.0',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.purple[300],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...children,
        Divider(color: Colors.grey[800], height: 1),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.white),
      title: Text(title, style: TextStyle(color: textColor ?? Colors.white)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[400])),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[400])),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.purple,
      ),
    );
  }

  void _showVideoQualityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Video Quality', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Auto', 'High', 'Medium', 'Low'].map((quality) {
            return RadioListTile<String>(
              title: Text(quality, style: TextStyle(color: Colors.white)),
              value: quality,
              groupValue: _videoQuality,
              activeColor: Colors.purple,
              onChanged: (value) {
                setState(() => _videoQuality = value!);
                _saveSettings();
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Language', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Spanish', 'French', 'German', 'Chinese'].map((lang) {
            return RadioListTile<String>(
              title: Text(lang, style: TextStyle(color: Colors.white)),
              value: lang,
              groupValue: _language,
              activeColor: Colors.purple,
              onChanged: (value) {
                setState(() => _language = value!);
                _saveSettings();
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showStorageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Storage & Cache', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('App Size: 45.2 MB', style: TextStyle(color: Colors.white)),
            SizedBox(height: 8),
            Text('Cache Size: 12.8 MB', style: TextStyle(color: Colors.white)),
            SizedBox(height: 8),
            Text('Downloaded Videos: 128.5 MB', style: TextStyle(color: Colors.white)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _clearCache();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: Text('Clear Cache', style: TextStyle(color: Colors.white)),
            ),
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

  void _showBlockedUsers() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Blocked Users', style: TextStyle(color: Colors.white)),
        content: Container(
          width: double.maxFinite,
          height: 200,
          child: ListView(
            children: [
              ListTile(
                leading: CircleAvatar(child: Text('U1')),
                title: Text('user123', style: TextStyle(color: Colors.white)),
                trailing: TextButton(
                  onPressed: () {},
                  child: Text('Unblock', style: TextStyle(color: Colors.purple)),
                ),
              ),
              ListTile(
                leading: CircleAvatar(child: Text('U2')),
                title: Text('spammer456', style: TextStyle(color: Colors.white)),
                trailing: TextButton(
                  onPressed: () {},
                  child: Text('Unblock', style: TextStyle(color: Colors.purple)),
                ),
              ),
            ],
          ),
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

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Social Live',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(Icons.live_tv, color: Colors.purple, size: 48),
      children: [
        Text('A social media platform for live streaming and content sharing.'),
        SizedBox(height: 16),
        Text('© 2024 Social Live. All rights reserved.'),
      ],
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Terms of Service', style: TextStyle(color: Colors.white)),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: Text(
              'Terms of Service\n\n'
              '1. Acceptance of Terms\n'
              'By using Social Live, you agree to these terms...\n\n'
              '2. User Conduct\n'
              'You agree to use the service responsibly...\n\n'
              '3. Content Policy\n'
              'All content must comply with our guidelines...\n\n'
              '4. Privacy\n'
              'We respect your privacy and protect your data...\n\n'
              '5. Termination\n'
              'We may terminate accounts that violate our terms...',
              style: TextStyle(color: Colors.white),
            ),
          ),
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

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Privacy Policy', style: TextStyle(color: Colors.white)),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: Text(
              'Privacy Policy\n\n'
              '1. Information We Collect\n'
              'We collect information you provide directly...\n\n'
              '2. How We Use Information\n'
              'We use your information to provide services...\n\n'
              '3. Information Sharing\n'
              'We do not sell your personal information...\n\n'
              '4. Data Security\n'
              'We implement security measures to protect data...\n\n'
              '5. Your Rights\n'
              'You have rights regarding your personal data...',
              style: TextStyle(color: Colors.white),
            ),
          ),
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

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Sign Out', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService().logout();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            child: Text('Sign Out', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Delete Account', style: TextStyle(color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action cannot be undone. Deleting your account will:',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 12),
            Text('• Remove all your videos and content', style: TextStyle(color: Colors.grey[400])),
            Text('• Delete your profile and followers', style: TextStyle(color: Colors.grey[400])),
            Text('• Cancel any active subscriptions', style: TextStyle(color: Colors.grey[400])),
            Text('• Remove all your data permanently', style: TextStyle(color: Colors.grey[400])),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteAccount();
            },
            child: Text('Delete Account', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Final Confirmation', style: TextStyle(color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Type "DELETE" to confirm account deletion:',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 12),
            TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type DELETE here',
                hintStyle: TextStyle(color: Colors.grey[600]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
              onChanged: (value) {
                // Handle text change
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Account deletion initiated. You will receive a confirmation email.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text('DELETE ACCOUNT', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cache cleared successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}