import 'package:flutter/material.dart';

class AdminContentModerationScreen extends StatefulWidget {
  const AdminContentModerationScreen({super.key});

  @override
  State<AdminContentModerationScreen> createState() => _AdminContentModerationScreenState();
}

class _AdminContentModerationScreenState extends State<AdminContentModerationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _flaggedContent = [
    {'id': '1', 'user': '@john_doe', 'reason': 'Inappropriate content', 'reports': 12, 'thumbnail': null, 'views': '125K'},
    {'id': '2', 'user': '@jane_smith', 'reason': 'Spam', 'reports': 8, 'thumbnail': null, 'views': '89K'},
    {'id': '3', 'user': '@creator_pro', 'reason': 'Copyright violation', 'reports': 5, 'thumbnail': null, 'views': '234K'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Content Moderation', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Flagged'),
            Tab(text: 'Pending'),
            Tab(text: 'Resolved'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFlaggedContent(),
          _buildPendingReview(),
          _buildResolved(),
        ],
      ),
    );
  }

  Widget _buildFlaggedContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _flaggedContent.length,
      itemBuilder: (context, index) {
        final content = _flaggedContent[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  width: 60,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.play_circle_outline, color: Colors.white, size: 32),
                ),
                title: Text(content['user'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.flag, color: Colors.red, size: 16),
                        const SizedBox(width: 4),
                        Text(content['reason'], style: TextStyle(color: Colors.red[300]), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.report, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text('${content['reports']} reports', style: TextStyle(color: Colors.grey[400]), overflow: TextOverflow.ellipsis),
                        const SizedBox(width: 16),
                        Icon(Icons.visibility, color: Colors.blue, size: 16),
                        const SizedBox(width: 4),
                        Text('${content['views']} views', style: TextStyle(color: Colors.grey[400]), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.grey, height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showContentDetails(content),
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('Review'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _approveContent(content['id']),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _removeContent(content['id']),
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Remove'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPendingReview() {
    return const Center(child: Text('No pending reviews', style: TextStyle(color: Colors.grey)));
  }

  Widget _buildResolved() {
    return const Center(child: Text('No resolved cases', style: TextStyle(color: Colors.grey)));
  }

  void _showContentDetails(Map<String, dynamic> content) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.grey[900],
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.play_circle_outline, color: Colors.white, size: 64),
                ),
              ),
              const SizedBox(height: 16),
              Text('Content by ${content['user']}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Reason: ${content['reason']}', style: TextStyle(color: Colors.red[300])),
              Text('Reports: ${content['reports']}', style: TextStyle(color: Colors.grey[400])),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _removeContent(content['id']);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Remove'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _approveContent(String id) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Content approved'), backgroundColor: Colors.green),
    );
    setState(() => _flaggedContent.removeWhere((c) => c['id'] == id));
  }

  void _removeContent(String id) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Content removed'), backgroundColor: Colors.red),
    );
    setState(() => _flaggedContent.removeWhere((c) => c['id'] == id));
  }
}
