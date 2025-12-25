import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _likesNotifications = true;
  bool _commentsNotifications = true;
  bool _followsNotifications = true;
  bool _mentionsNotifications = true;
  bool _liveStreamNotifications = true;
  bool _marketplaceNotifications = true;
  bool _walletNotifications = true;
  bool _systemNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = false;
  bool _pushNotifications = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _quietHoursStart = '22:00';
  String _quietHoursEnd = '08:00';
  bool _quietHoursEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _likesNotifications = prefs.getBool('likes_notifications') ?? true;
      _commentsNotifications = prefs.getBool('comments_notifications') ?? true;
      _followsNotifications = prefs.getBool('follows_notifications') ?? true;
      _mentionsNotifications = prefs.getBool('mentions_notifications') ?? true;
      _liveStreamNotifications = prefs.getBool('live_stream_notifications') ?? true;
      _marketplaceNotifications = prefs.getBool('marketplace_notifications') ?? true;
      _walletNotifications = prefs.getBool('wallet_notifications') ?? true;
      _systemNotifications = prefs.getBool('system_notifications') ?? true;
      _emailNotifications = prefs.getBool('email_notifications') ?? false;
      _smsNotifications = prefs.getBool('sms_notifications') ?? false;
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _quietHoursStart = prefs.getString('quiet_hours_start') ?? '22:00';
      _quietHoursEnd = prefs.getString('quiet_hours_end') ?? '08:00';
      _quietHoursEnabled = prefs.getBool('quiet_hours_enabled') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('likes_notifications', _likesNotifications);
    await prefs.setBool('comments_notifications', _commentsNotifications);
    await prefs.setBool('follows_notifications', _followsNotifications);
    await prefs.setBool('mentions_notifications', _mentionsNotifications);
    await prefs.setBool('live_stream_notifications', _liveStreamNotifications);
    await prefs.setBool('marketplace_notifications', _marketplaceNotifications);
    await prefs.setBool('wallet_notifications', _walletNotifications);
    await prefs.setBool('system_notifications', _systemNotifications);
    await prefs.setBool('email_notifications', _emailNotifications);
    await prefs.setBool('sms_notifications', _smsNotifications);
    await prefs.setBool('push_notifications', _pushNotifications);
    await prefs.setBool('sound_enabled', _soundEnabled);
    await prefs.setBool('vibration_enabled', _vibrationEnabled);
    await prefs.setString('quiet_hours_start', _quietHoursStart);
    await prefs.setString('quiet_hours_end', _quietHoursEnd);
    await prefs.setBool('quiet_hours_enabled', _quietHoursEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text('Notification Settings', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          _buildSection('Push Notifications', [
            _buildSwitchTile(
              icon: Icons.notifications,
              title: 'Push Notifications',
              subtitle: 'Receive push notifications on this device',
              value: _pushNotifications,
              onChanged: (value) {
                setState(() => _pushNotifications = value);
                _saveSettings();
              },
            ),
            _buildSwitchTile(
              icon: Icons.volume_up,
              title: 'Sound',
              subtitle: 'Play sound for notifications',
              value: _soundEnabled,
              onChanged: (value) {
                setState(() => _soundEnabled = value);
                _saveSettings();
              },
            ),
            _buildSwitchTile(
              icon: Icons.vibration,
              title: 'Vibration',
              subtitle: 'Vibrate for notifications',
              value: _vibrationEnabled,
              onChanged: (value) {
                setState(() => _vibrationEnabled = value);
                _saveSettings();
              },
            ),
          ]),

          _buildSection('Activity Notifications', [
            _buildSwitchTile(
              icon: Icons.favorite,
              title: 'Likes',
              subtitle: 'When someone likes your content',
              value: _likesNotifications,
              onChanged: (value) {
                setState(() => _likesNotifications = value);
                _saveSettings();
              },
            ),
            _buildSwitchTile(
              icon: Icons.comment,
              title: 'Comments',
              subtitle: 'When someone comments on your content',
              value: _commentsNotifications,
              onChanged: (value) {
                setState(() => _commentsNotifications = value);
                _saveSettings();
              },
            ),
            _buildSwitchTile(
              icon: Icons.person_add,
              title: 'New Followers',
              subtitle: 'When someone follows you',
              value: _followsNotifications,
              onChanged: (value) {
                setState(() => _followsNotifications = value);
                _saveSettings();
              },
            ),
            _buildSwitchTile(
              icon: Icons.alternate_email,
              title: 'Mentions',
              subtitle: 'When someone mentions you',
              value: _mentionsNotifications,
              onChanged: (value) {
                setState(() => _mentionsNotifications = value);
                _saveSettings();
              },
            ),
          ]),

          _buildSection('Content Notifications', [
            _buildSwitchTile(
              icon: Icons.live_tv,
              title: 'Live Streams',
              subtitle: 'When people you follow go live',
              value: _liveStreamNotifications,
              onChanged: (value) {
                setState(() => _liveStreamNotifications = value);
                _saveSettings();
              },
            ),
            _buildSwitchTile(
              icon: Icons.shopping_bag,
              title: 'Marketplace',
              subtitle: 'New products and deals',
              value: _marketplaceNotifications,
              onChanged: (value) {
                setState(() => _marketplaceNotifications = value);
                _saveSettings();
              },
            ),
            _buildSwitchTile(
              icon: Icons.account_balance_wallet,
              title: 'Wallet',
              subtitle: 'Transactions and balance updates',
              value: _walletNotifications,
              onChanged: (value) {
                setState(() => _walletNotifications = value);
                _saveSettings();
              },
            ),
          ]),

          _buildSection('System Notifications', [
            _buildSwitchTile(
              icon: Icons.system_update,
              title: 'System Updates',
              subtitle: 'App updates and maintenance',
              value: _systemNotifications,
              onChanged: (value) {
                setState(() => _systemNotifications = value);
                _saveSettings();
              },
            ),
          ]),

          _buildSection('Other Channels', [
            _buildSwitchTile(
              icon: Icons.email,
              title: 'Email Notifications',
              subtitle: 'Receive notifications via email',
              value: _emailNotifications,
              onChanged: (value) {
                setState(() => _emailNotifications = value);
                _saveSettings();
              },
            ),
            _buildSwitchTile(
              icon: Icons.sms,
              title: 'SMS Notifications',
              subtitle: 'Receive notifications via SMS',
              value: _smsNotifications,
              onChanged: (value) {
                setState(() => _smsNotifications = value);
                _saveSettings();
              },
            ),
          ]),

          _buildSection('Quiet Hours', [
            _buildSwitchTile(
              icon: Icons.bedtime,
              title: 'Enable Quiet Hours',
              subtitle: 'Mute notifications during specified hours',
              value: _quietHoursEnabled,
              onChanged: (value) {
                setState(() => _quietHoursEnabled = value);
                _saveSettings();
              },
            ),
            if (_quietHoursEnabled) ...[
              _buildTimeTile(
                icon: Icons.bedtime,
                title: 'Start Time',
                subtitle: 'When quiet hours begin',
                time: _quietHoursStart,
                onTap: () => _selectTime(true),
              ),
              _buildTimeTile(
                icon: Icons.wb_sunny,
                title: 'End Time',
                subtitle: 'When quiet hours end',
                time: _quietHoursEnd,
                onTap: () => _selectTime(false),
              ),
            ],
          ]),

          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _testNotification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('Test Notification', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _resetToDefaults,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[600]!),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('Reset to Defaults', style: TextStyle(color: Colors.white)),
                ),
              ],
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

  Widget _buildTimeTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[400])),
      trailing: Text(time, style: TextStyle(color: Colors.purple[300])),
      onTap: onTap,
    );
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        DateTime.parse('2024-01-01 ${isStartTime ? _quietHoursStart : _quietHoursEnd}:00'),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.purple,
              onPrimary: Colors.white,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final timeString = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isStartTime) {
          _quietHoursStart = timeString;
        } else {
          _quietHoursEnd = timeString;
        }
      });
      _saveSettings();
    }
  }

  void _testNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.notifications, color: Colors.white),
            SizedBox(width: 12),
            Text('Test notification sent!'),
          ],
        ),
        backgroundColor: Colors.purple,
        duration: Duration(seconds: 2),
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
          'This will reset all notification settings to their default values. Continue?',
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
      _likesNotifications = true;
      _commentsNotifications = true;
      _followsNotifications = true;
      _mentionsNotifications = true;
      _liveStreamNotifications = true;
      _marketplaceNotifications = true;
      _walletNotifications = true;
      _systemNotifications = true;
      _emailNotifications = false;
      _smsNotifications = false;
      _pushNotifications = true;
      _soundEnabled = true;
      _vibrationEnabled = true;
      _quietHoursStart = '22:00';
      _quietHoursEnd = '08:00';
      _quietHoursEnabled = false;
    });
    _saveSettings();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Settings reset to defaults'),
        backgroundColor: Colors.green,
      ),
    );
  }
}