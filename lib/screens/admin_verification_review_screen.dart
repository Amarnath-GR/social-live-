import 'package:flutter/material.dart';
import '../services/verification_service.dart';

class AdminVerificationReviewScreen extends StatefulWidget {
  const AdminVerificationReviewScreen({super.key});

  @override
  State<AdminVerificationReviewScreen> createState() => _AdminVerificationReviewScreenState();
}

class _AdminVerificationReviewScreenState extends State<AdminVerificationReviewScreen> {
  List<Map<String, dynamic>> _verifications = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadVerificationQueue();
  }

  Future<void> _loadVerificationQueue() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // This would call admin API endpoint
      // For now, showing mock data structure
      setState(() {
        _verifications = [
          {
            'id': '1',
            'type': 'KYB',
            'status': 'IN_REVIEW',
            'user': {
              'name': 'John Doe',
              'email': 'john@example.com',
            },
            'submittedAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
            'documents': [
              {'type': 'BUSINESS_REGISTRATION', 'status': 'uploaded'},
              {'type': 'TAX_CERTIFICATE', 'status': 'uploaded'},
            ],
          },
          {
            'id': '2',
            'type': 'KYC',
            'status': 'REQUIRES_ACTION',
            'user': {
              'name': 'Jane Smith',
              'email': 'jane@example.com',
            },
            'submittedAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
            'documents': [
              {'type': 'PASSPORT', 'status': 'uploaded'},
              {'type': 'UTILITY_BILL', 'status': 'uploaded'},
            ],
          },
        ];
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading verification queue: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _reviewVerification(String verificationId, VerificationStatus decision) async {
    final notesController = TextEditingController();
    
    final notes = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${decision.name} Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please provide notes for this ${decision.name.toLowerCase()} decision:'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                hintText: 'Review notes...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, notesController.text),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (notes != null) {
      // TODO: Call admin review API
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification ${decision.name.toLowerCase()}d successfully'),
          backgroundColor: decision == VerificationStatus.APPROVED ? Colors.green : Colors.red,
        ),
      );
      _loadVerificationQueue();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Review'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<VerificationStatus?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (status) {
              _loadVerificationQueue();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All Statuses'),
              ),
              PopupMenuItem(
                value: VerificationStatus.IN_REVIEW,
                child: Text(VerificationService.getVerificationStatusText(VerificationStatus.IN_REVIEW)),
              ),
              PopupMenuItem(
                value: VerificationStatus.REQUIRES_ACTION,
                child: Text(VerificationService.getVerificationStatusText(VerificationStatus.REQUIRES_ACTION)),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVerificationQueue,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                      const SizedBox(height: 16),
                      Text(_errorMessage, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadVerificationQueue,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _verifications.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified_user_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No verifications to review',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _verifications.length,
                      itemBuilder: (context, index) {
                        final verification = _verifications[index];
                        final status = VerificationService.parseVerificationStatus(verification['status']);
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${verification['type']} Verification',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          verification['user']['name'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          verification['user']['email'],
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: VerificationService.getVerificationStatusColor(status).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        VerificationService.getVerificationStatusText(status),
                                        style: TextStyle(
                                          color: VerificationService.getVerificationStatusColor(status),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                // Documents
                                const Text(
                                  'Documents:',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                ...verification['documents'].map<Widget>((doc) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.description, size: 16, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(VerificationService.getDocumentTypeText(
                                        VerificationService.parseDocumentType(doc['type'])
                                      )),
                                      const Spacer(),
                                      Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: Colors.green,
                                      ),
                                    ],
                                  ),
                                )),
                                
                                const SizedBox(height: 16),
                                Text(
                                  'Submitted: ${DateTime.parse(verification['submittedAt']).toLocal().toString()}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          // TODO: Show verification details
                                        },
                                        child: const Text('View Details'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => _reviewVerification(
                                          verification['id'],
                                          VerificationStatus.REJECTED,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Reject'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => _reviewVerification(
                                          verification['id'],
                                          VerificationStatus.APPROVED,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Approve'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
