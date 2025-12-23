import 'package:flutter/material.dart';
import '../services/verification_service.dart';
import 'kyb_verification_screen.dart';

class VerificationStatusScreen extends StatefulWidget {
  const VerificationStatusScreen({super.key});

  @override
  State<VerificationStatusScreen> createState() => _VerificationStatusScreenState();
}

class _VerificationStatusScreenState extends State<VerificationStatusScreen> {
  List<Map<String, dynamic>> _verifications = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadVerificationStatus();
  }

  Future<void> _loadVerificationStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await VerificationService.getVerificationStatus();
      
      if (result['success'] == true) {
        setState(() {
          _verifications = List<Map<String, dynamic>>.from(result['verifications']);
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load verification status';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading verification status: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startKYBVerification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const KYBVerificationScreen(),
      ),
    ).then((_) => _loadVerificationStatus());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Status'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVerificationStatus,
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
                        onPressed: _loadVerificationStatus,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const Text(
                        'Account Verification',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Complete your verification to unlock all features and increase transaction limits.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),

                      // Verification Cards
                      _buildVerificationCard(
                        title: 'KYC Verification',
                        description: 'Verify your identity with government-issued documents',
                        type: VerificationType.KYC,
                        icon: Icons.person_outline,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),

                      _buildVerificationCard(
                        title: 'KYB Verification',
                        description: 'Verify your business with official business documents',
                        type: VerificationType.KYB,
                        icon: Icons.business_outlined,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 16),

                      _buildVerificationCard(
                        title: 'AML Verification',
                        description: 'Anti-Money Laundering compliance verification',
                        type: VerificationType.AML,
                        icon: Icons.security_outlined,
                        color: Colors.orange,
                      ),

                      if (_verifications.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        const Text(
                          'Verification History',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        ..._verifications.map((verification) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      verification['type'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: VerificationService.getVerificationStatusColor(
                                          VerificationService.parseVerificationStatus(verification['status'])
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        VerificationService.getVerificationStatusText(
                                          VerificationService.parseVerificationStatus(verification['status'])
                                        ),
                                        style: TextStyle(
                                          color: VerificationService.getVerificationStatusColor(
                                            VerificationService.parseVerificationStatus(verification['status'])
                                          ),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Submitted: ${DateTime.parse(verification['createdAt']).toLocal().toString().split(' ')[0]}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                if (verification['documents'] != null && verification['documents'].isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Documents: ${verification['documents'].length} uploaded',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                                if (verification['lastReview'] != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Last Review: ${verification['lastReview']['notes'] ?? 'No notes'}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildVerificationCard({
    required String title,
    required String description,
    required VerificationType type,
    required IconData icon,
    required Color color,
  }) {
    final existingVerification = _verifications.firstWhere(
      (v) => v['type'] == type.name,
      orElse: () => {},
    );

    final isCompleted = existingVerification.isNotEmpty;
    final status = isCompleted 
        ? VerificationService.parseVerificationStatus(existingVerification['status'])
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (isCompleted && status != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: VerificationService.getVerificationStatusColor(status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      VerificationService.getVerificationStatusText(status),
                      style: TextStyle(
                        color: VerificationService.getVerificationStatusColor(status),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCompleted && status == VerificationStatus.APPROVED
                    ? null
                    : () {
                        if (type == VerificationType.KYB) {
                          _startKYBVerification();
                        } else {
                          // TODO: Implement KYC and AML verification screens
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$title coming soon')),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted && status == VerificationStatus.APPROVED
                      ? Colors.grey
                      : color,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  isCompleted && status == VerificationStatus.APPROVED
                      ? 'Verified'
                      : isCompleted
                          ? 'Update Verification'
                          : 'Start Verification',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
