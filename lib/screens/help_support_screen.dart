import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  _HelpSupportScreenState createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _messageController = TextEditingController();
  String _selectedCategory = 'General';
  
  final List<String> _categories = [
    'General',
    'Account Issues',
    'Technical Problems',
    'Content Issues',
    'Payment & Billing',
    'Privacy & Security',
    'Feature Request',
    'Bug Report',
  ];

  final List<Map<String, dynamic>> _faqItems = [
    {
      'question': 'How do I create an account?',
      'answer': 'To create an account, tap the "Sign Up" button on the login screen and follow the prompts to enter your email, username, and password.',
      'category': 'Account',
    },
    {
      'question': 'How do I upload a video?',
      'answer': 'Tap the "+" button at the bottom of the screen, record or select a video, add effects and music, then tap "Post" to share it.',
      'category': 'Content',
    },
    {
      'question': 'How do I go live?',
      'answer': 'Tap the "+" button, then select "Live" mode. Add a title for your stream and tap "Go Live" to start broadcasting.',
      'category': 'Live Streaming',
    },
    {
      'question': 'How do I earn money on the platform?',
      'answer': 'You can earn through live stream gifts, brand partnerships, and selling products in the marketplace. Check the Wallet section for more details.',
      'category': 'Monetization',
    },
    {
      'question': 'How do I report inappropriate content?',
      'answer': 'Tap and hold on any video or comment, then select "Report" and choose the appropriate reason. Our team will review it promptly.',
      'category': 'Safety',
    },
    {
      'question': 'How do I change my privacy settings?',
      'answer': 'Go to Profile > Settings > Privacy & Security to adjust who can see your content, message you, and interact with your posts.',
      'category': 'Privacy',
    },
    {
      'question': 'Why isn\'t my video uploading?',
      'answer': 'Check your internet connection, ensure the video is under 60 seconds and less than 100MB. Try closing and reopening the app.',
      'category': 'Technical',
    },
    {
      'question': 'How do I delete my account?',
      'answer': 'Go to Profile > Settings > Account Actions > Delete Account. Note that this action is permanent and cannot be undone.',
      'category': 'Account',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text('Help & Support', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              indicatorColor: Colors.purple,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[400],
              tabs: [
                Tab(text: 'FAQ'),
                Tab(text: 'Contact'),
                Tab(text: 'Resources'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildFAQTab(),
                  _buildContactTab(),
                  _buildResourcesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQTab() {
    final Map<String, List<Map<String, dynamic>>> groupedFAQ = {};
    for (var item in _faqItems) {
      final category = item['category'] as String;
      if (!groupedFAQ.containsKey(category)) {
        groupedFAQ[category] = [];
      }
      groupedFAQ[category]!.add(item);
    }

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text(
          'Frequently Asked Questions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        TextField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search FAQ...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 20),
        ...groupedFAQ.entries.map((entry) => _buildFAQCategory(entry.key, entry.value)),
      ],
    );
  }

  Widget _buildFAQCategory(String category, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            category,
            style: TextStyle(
              color: Colors.purple[300],
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...items.map((item) => _buildFAQItem(item['question'], item['answer'])),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      color: Colors.grey[900],
      margin: EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        iconColor: Colors.purple[300],
        collapsedIconColor: Colors.grey[400],
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              answer,
              style: TextStyle(color: Colors.grey[300], height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text(
          'Contact Support',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        
        _buildContactOption(
          icon: Icons.chat,
          title: 'Live Chat',
          subtitle: 'Chat with our support team',
          available: true,
          onTap: () => _startLiveChat(),
        ),
        
        _buildContactOption(
          icon: Icons.email,
          title: 'Email Support',
          subtitle: 'Send us an email',
          available: true,
          onTap: () => _sendEmail(),
        ),
        
        _buildContactOption(
          icon: Icons.phone,
          title: 'Phone Support',
          subtitle: 'Call our support line',
          available: false,
          availableHours: 'Mon-Fri 9AM-6PM EST',
          onTap: () => _callSupport(),
        ),
        
        SizedBox(height: 24),
        
        Text(
          'Send us a message',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16),
        
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          dropdownColor: Colors.grey[900],
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Category',
            labelStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.purple),
            ),
          ),
          items: _categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedCategory = value!);
          },
        ),
        
        SizedBox(height: 16),
        
        TextField(
          controller: _messageController,
          maxLines: 5,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Describe your issue',
            labelStyle: TextStyle(color: Colors.grey[400]),
            hintText: 'Please provide as much detail as possible...',
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.purple),
            ),
          ),
        ),
        
        SizedBox(height: 20),
        
        ElevatedButton(
          onPressed: _submitMessage,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Send Message',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        
        SizedBox(height: 24),
        
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Response Time',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• Live Chat: Immediate',
                style: TextStyle(color: Colors.grey[300]),
              ),
              Text(
                '• Email: Within 24 hours',
                style: TextStyle(color: Colors.grey[300]),
              ),
              Text(
                '• Phone: During business hours',
                style: TextStyle(color: Colors.grey[300]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool available,
    String? availableHours,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.grey[900],
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: available ? Colors.purple : Colors.grey[600]),
        title: Text(
          title,
          style: TextStyle(
            color: available ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[400]),
            ),
            if (!available && availableHours != null)
              Text(
                availableHours,
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
          ],
        ),
        trailing: available
            ? Icon(Icons.chevron_right, color: Colors.grey[400])
            : Text('Offline', style: TextStyle(color: Colors.grey[600])),
        onTap: available ? onTap : null,
      ),
    );
  }

  Widget _buildResourcesTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text(
          'Resources',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        
        _buildResourceCard(
          icon: Icons.school,
          title: 'Creator Academy',
          subtitle: 'Learn how to create engaging content',
          onTap: () => _openCreatorAcademy(),
        ),
        
        _buildResourceCard(
          icon: Icons.policy,
          title: 'Community Guidelines',
          subtitle: 'Understand our community rules',
          onTap: () => _openCommunityGuidelines(),
        ),
        
        _buildResourceCard(
          icon: Icons.security,
          title: 'Safety Center',
          subtitle: 'Stay safe on our platform',
          onTap: () => _openSafetyCenter(),
        ),
        
        _buildResourceCard(
          icon: Icons.trending_up,
          title: 'Creator Tools',
          subtitle: 'Analytics and growth tips',
          onTap: () => _openCreatorTools(),
        ),
        
        _buildResourceCard(
          icon: Icons.bug_report,
          title: 'Report a Bug',
          subtitle: 'Help us improve the app',
          onTap: () => _reportBug(),
        ),
        
        _buildResourceCard(
          icon: Icons.feedback,
          title: 'Send Feedback',
          subtitle: 'Share your thoughts and suggestions',
          onTap: () => _sendFeedback(),
        ),
        
        SizedBox(height: 24),
        
        Text(
          'Follow Us',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSocialButton(
              icon: Icons.facebook,
              label: 'Facebook',
              onTap: () => _openSocialMedia('facebook'),
            ),
            _buildSocialButton(
              icon: Icons.alternate_email,
              label: 'Twitter',
              onTap: () => _openSocialMedia('twitter'),
            ),
            _buildSocialButton(
              icon: Icons.camera_alt,
              label: 'Instagram',
              onTap: () => _openSocialMedia('instagram'),
            ),
            _buildSocialButton(
              icon: Icons.video_library,
              label: 'YouTube',
              onTap: () => _openSocialMedia('youtube'),
            ),
          ],
        ),
        
        SizedBox(height: 24),
        
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'App Information',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12),
              _buildInfoRow('Version', '1.0.0'),
              _buildInfoRow('Build', '100'),
              _buildInfoRow('Platform', 'Flutter'),
              _buildInfoRow('Last Updated', 'Dec 2024'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResourceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.grey[900],
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.purple),
        title: Text(
          title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[400]),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400])),
          Text(value, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  void _startLiveChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Live Chat', style: TextStyle(color: Colors.white)),
        content: Text(
          'Connecting you to our support team...',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
    
    // Simulate connection
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connected to support agent'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@sociallive.com',
      query: 'subject=Support Request&body=Please describe your issue...',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open email app'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _callSupport() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+1-800-SOCIAL');
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open phone app'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _submitMessage() {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a message'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Simulate sending message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Message sent! We\'ll respond within 24 hours.'),
        backgroundColor: Colors.green,
      ),
    );
    
    _messageController.clear();
  }

  void _openCreatorAcademy() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening Creator Academy...')),
    );
  }

  void _openCommunityGuidelines() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening Community Guidelines...')),
    );
  }

  void _openSafetyCenter() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening Safety Center...')),
    );
  }

  void _openCreatorTools() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening Creator Tools...')),
    );
  }

  void _reportBug() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Report a Bug', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Bug Description',
                labelStyle: TextStyle(color: Colors.grey[400]),
                hintText: 'Describe the bug you encountered...',
                hintStyle: TextStyle(color: Colors.grey[600]),
              ),
              maxLines: 3,
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
                  content: Text('Bug report submitted'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Submit', style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
    );
  }

  void _sendFeedback() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Send Feedback', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Your Feedback',
                labelStyle: TextStyle(color: Colors.grey[400]),
                hintText: 'Share your thoughts and suggestions...',
                hintStyle: TextStyle(color: Colors.grey[600]),
              ),
              maxLines: 3,
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
                  content: Text('Feedback sent! Thank you.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Send', style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
    );
  }

  void _openSocialMedia(String platform) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening $platform...')),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}