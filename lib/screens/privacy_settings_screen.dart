import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  _PrivacySettingsScreenState createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _privateAccount = false;
  bool _showOnlineStatus = true;
  bool _allowDirectMessages = true;
  bool _allowTagging = true;
  bool _allowDownloads = false;
  bool _showInSearch = true;
  bool _allowComments = true;
  bool _allowDuets = true;
  bool _allowStitches = true;
  bool _showViewHistory = false;
  bool _allowLocationSharing = false;
  bool _allowContactSync = false;
  String _whoCanMessage = 'Everyone';
  String _whoCanComment = 'Everyone';
  String _whoCanDuet = 'Everyone';
  String _whoCanViewProfile = 'Everyone';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _privateAccount = prefs.getBool('private_account') ?? false;
      _showOnlineStatus = prefs.getBool('show_online_status') ?? true;
      _allowDirectMessages = prefs.getBool('allow_direct_messages') ?? true;
      _allowTagging = prefs.getBool('allow_tagging') ?? true;
      _allowDownloads = prefs.getBool('allow_downloads') ?? false;
      _showInSearch = prefs.getBool('show_in_search') ?? true;
      _allowComments = prefs.getBool('allow_comments') ?? true;
      _allowDuets = prefs.getBool('allow_duets') ?? true;
      _allowStitches = prefs.getBool('allow_stitches') ?? true;
      _showViewHistory = prefs.getBool('show_view_history') ?? false;
      _allowLocationSharing = prefs.getBool('allow_location_sharing') ?? false;
      _allowContactSync = prefs.getBool('allow_contact_sync') ?? false;
      _whoCanMessage = prefs.getString('who_can_message') ?? 'Everyone';
      _whoCanComment = prefs.getString('who_can_comment') ?? 'Everyone';
      _whoCanDuet = prefs.getString('who_can_duet') ?? 'Everyone';
      _whoCanViewProfile = prefs.getString('who_can_view_profile') ?? 'Everyone';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('private_account', _privateAccount);
    await prefs.setBool('show_online_status', _showOnlineStatus);
    await prefs.setBool('allow_direct_messages', _allowDirectMessages);
    await prefs.setBool('allow_tagging', _allowTagging);
    await prefs.setBool('allow_downloads', _allowDownloads);
    await prefs.setBool('show_in_search', _showInSearch);
    await prefs.setBool('allow_comments', _allowComments);
    await prefs.setBool('allow_duets', _allowDuets);
    await prefs.setBool('allow_stitches', _allowStitches);
    await prefs.setBool('show_view_history', _showViewHistory);
    await prefs.setBool('allow_location_sharing', _allowLocationSharing);
    await prefs.setBool('allow_contact_sync', _allowContactSync);
    await prefs.setString('who_can_message', _whoCanMessage);
    await prefs.setString('who_can_comment', _whoCanComment);
    await prefs.setString('who_can_duet', _whoCanDuet);
    await prefs.setString('who_can_view_profile', _whoCanViewProfile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text('Privacy & Security', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          _buildSection('Account Privacy', [
            _buildSwitchTile(
              icon: Icons.lock,
              title: 'Private Account',
              subtitle: 'Only approved followers can see your content',
              value: _privateAccount,
              onChanged: (value) {
                setState(() => _privateAccount = value);
                _saveSettings();
              },
            ),
            _buildSwitchTile(
              icon: Icons.search,
              title: 'Show in Search Results',
              subtitle: 'Allow others to find your profile in search',
              value: _showInSearch,
              onChanged: (value) {
                setState(() => _showInSearch = value);
                _saveSettings();
              },
            ),
            _buildDropdownTile(
              icon: Icons.visibility,
              title: 'Who Can View Your Profile',
              subtitle: _whoCanViewProfile,
              options: ['Everyone', 'Followers', 'Friends', 'Nobody'],
              currentValue: _whoCanViewProfile,
              onChanged: (value) {
                setState(() => _whoCanViewProfile = value);
                _saveSettings();
              },
            ),
          ]),

          _buildSection('Activity Status', [
            _buildSwitchTile(
              icon: Icons.circle,
              title: 'Show Online Status',
              subtitle: 'Let others see when you\'re active',
              value: _showOnlineStatus,
              onChanged: (value) {
                setState(() => _showOnlineStatus = value);
                _saveSettings();
              },
            ),
            _buildSwitchTile(
              icon: Icons.history,
              title: 'Show View History',
              subtitle: 'Let others see what you\'ve viewed',
              value: _showViewHistory,
              onChanged: (value) {
                setState(() => _showViewHistory = value);
                _saveSettings();
              },
            ),
          ]),

          _buildSection('Interactions', [
            _buildSwitchTile(
              icon: Icons.comment,
              title: 'Allow Comments',
              subtitle: 'Let others comment on your content',
              value: _allowComments,
              onChanged: (value) {
                setState(() => _allowComments = value);
                _saveSettings();
              },
            ),
            _buildDropdownTile(
              icon: Icons.comment_outlined,
              title: 'Who Can Comment',
              subtitle: _whoCanComment,
              options: ['Everyone', 'Followers', 'Friends', 'Nobody'],
              currentValue: _whoCanComment,
              onChanged: (value) {
                setState(() => _whoCanComment = value);
                _saveSettings();
              },
            ),
            _buildSwitchTile(
              icon: Icons.alternate_email,
              title: 'Allow Tagging',
              subtitle: 'Let others tag you in their content',
              value: _allowTagging,
              onChanged: (value) {
                setState(() => _allowTagging = value);
                _saveSettings();
              },
            ),
          ]),

          _buildSection('Messages', [
            _buildSwitchTile(
              icon: Icons.message,
              title: 'Allow Direct Messages',
              subtitle: 'Let others send you direct messages',
              value: _allowDirectMessages,
              onChanged: (value) {
                setState(() => _allowDirectMessages = value);
                _saveSettings();
              },
            ),
            _buildDropdownTile(
              icon: Icons.message_outlined,
              title: 'Who Can Message You',
              subtitle: _whoCanMessage,
              options: ['Everyone', 'Followers', 'Friends', 'Nobody'],
              currentValue: _whoCanMessage,
              onChanged: (value) {
                setState(() => _whoCanMessage = value);
                _saveSettings();
              },
            ),
          ]),

          _buildSection('Content Interactions', [
            _buildSwitchTile(
              icon: Icons.video_call,
              title: 'Allow Duets',
              subtitle: 'Let others create duets with your videos',
              value: _allowDuets,
              onChanged: (value) {
                setState(() => _allowDuets = value);
                _saveSettings();
              },
            ),
            _buildDropdownTile(
              icon: Icons.video_call_outlined,
              title: 'Who Can Duet',
              subtitle: _whoCanDuet,
              options: ['Everyone', 'Followers', 'Friends', 'Nobody'],
              currentValue: _whoCanDuet,
              onChanged: (value) {
                setState(() => _whoCanDuet = value);
                _saveSettings();
              },
            ),
            _buildSwitchTile(
              icon: Icons.content_cut,
              title: 'Allow Stitches',
              subtitle: 'Let others stitch parts of your videos',
              value: _allowStitches,
              onChanged: (value) {
                setState(() => _allowStitches = value);
                _saveSettings();
              },
            ),
            _buildSwitchTile(
              icon: Icons.download,
              title: 'Allow Downloads',
              subtitle: 'Let others download your videos',
              value: _allowDownloads,
              onChanged: (value) {
                setState(() => _allowDownloads = value);
                _saveSettings();
              },
            ),
          ]),

          _buildSection('Location & Contacts', [
            _buildSwitchTile(
              icon: Icons.location_on,
              title: 'Location Sharing',
              subtitle: 'Share your location in posts',
              value: _allowLocationSharing,
              onChanged: (value) {
                setState(() => _allowLocationSharing = value);
                _saveSettings();
              },
            ),
            _buildSwitchTile(
              icon: Icons.contacts,
              title: 'Contact Sync',
              subtitle: 'Sync contacts to find friends',
              value: _allowContactSync,
              onChanged: (value) {
                setState(() => _allowContactSync = value);
                _saveSettings();
              },
            ),
          ]),

          _buildSection('Data & Security', [
            _buildListTile(
              icon: Icons.download_for_offline,
              title: 'Download My Data',
              subtitle: 'Get a copy of your data',
              onTap: () => _showDownloadDataDialog(),
            ),
            _buildListTile(
              icon: Icons.block,
              title: 'Blocked Accounts',
              subtitle: 'Manage blocked users',
              onTap: () => _showBlockedAccounts(),
            ),
            _buildListTile(
              icon: Icons.report,
              title: 'Report a Problem',
              subtitle: 'Report issues or violations',
              onTap: () => _showReportDialog(),
            ),
            _buildListTile(
              icon: Icons.security,
              title: 'Two-Factor Authentication',
              subtitle: 'Add extra security to your account',
              onTap: () => _show2FADialog(),
            ),
            _buildListTile(
              icon: Icons.password,
              title: 'Change Password',
              subtitle: 'Update your account password',
              onTap: () => _showChangePasswordDialog(),
            ),
          ]),

          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: _resetToDefaults,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey[600]!),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Reset to Defaults', style: TextStyle(color: Colors.white)),
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

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[400])),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
      onTap: onTap,
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.purple[300])),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
      onTap: () => _showOptionsDialog(title, options, currentValue, onChanged),
    );
  }

  void _showOptionsDialog(String title, List<String> options, String currentValue, ValueChanged<String> onChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(title, style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            return RadioListTile<String>(
              title: Text(option, style: TextStyle(color: Colors.white)),
              value: option,
              groupValue: currentValue,
              activeColor: Colors.purple,
              onChanged: (value) {
                onChanged(value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDownloadDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Download Your Data', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We\'ll prepare a file with your Social Live data including:',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 12),
            Text('• Profile information', style: TextStyle(color: Colors.grey[400])),
            Text('• Videos and photos', style: TextStyle(color: Colors.grey[400])),
            Text('• Comments and likes', style: TextStyle(color: Colors.grey[400])),
            Text('• Messages and activity', style: TextStyle(color: Colors.grey[400])),
            SizedBox(height: 12),
            Text(
              'This may take up to 24 hours. We\'ll email you when it\'s ready.',
              style: TextStyle(color: Colors.grey[400]),
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
                  content: Text('Data download request submitted'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Request Download', style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
    );
  }

  void _showBlockedAccounts() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Blocked Accounts', style: TextStyle(color: Colors.white)),
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

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Report a Problem', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Harassment or Bullying', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: Text('Spam or Fake Account', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: Text('Inappropriate Content', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: Text('Technical Issue', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: Text('Other', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _show2FADialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Two-Factor Authentication', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add an extra layer of security to your account by enabling two-factor authentication.',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            Text('Choose your preferred method:', style: TextStyle(color: Colors.grey[400])),
            SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.sms, color: Colors.white),
              title: Text('SMS', style: TextStyle(color: Colors.white)),
              subtitle: Text('Receive codes via text message', style: TextStyle(color: Colors.grey[400])),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('SMS 2FA setup initiated')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.apps, color: Colors.white),
              title: Text('Authenticator App', style: TextStyle(color: Colors.white)),
              subtitle: Text('Use Google Authenticator or similar', style: TextStyle(color: Colors.grey[400])),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Authenticator 2FA setup initiated')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Change Password', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Current Password',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'New Password',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
              ),
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
                  content: Text('Password changed successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Change Password', style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
    );
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Reset to Defaults', style: TextStyle(color: Colors.white)),
        content: Text(
          'This will reset all privacy settings to their default values. Continue?',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetSettings();
            },
            child: Text('Reset', style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    setState(() {
      _privateAccount = false;
      _showOnlineStatus = true;
      _allowDirectMessages = true;
      _allowTagging = true;
      _allowDownloads = false;
      _showInSearch = true;
      _allowComments = true;
      _allowDuets = true;
      _allowStitches = true;
      _showViewHistory = false;
      _allowLocationSharing = false;
      _allowContactSync = false;
      _whoCanMessage = 'Everyone';
      _whoCanComment = 'Everyone';
      _whoCanDuet = 'Everyone';
      _whoCanViewProfile = 'Everyone';
    });
    _saveSettings();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Privacy settings reset to defaults'),
        backgroundColor: Colors.green,
      ),
    );
  }
}