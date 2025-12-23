import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../services/verification_service.dart';

class KYBVerificationScreen extends StatefulWidget {
  const KYBVerificationScreen({super.key});

  @override
  State<KYBVerificationScreen> createState() => _KYBVerificationScreenState();
}

class _KYBVerificationScreenState extends State<KYBVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _countryController = TextEditingController();
  final _addressController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _websiteController = TextEditingController();

  String? _verificationId;
  bool _isLoading = false;
  List<Map<String, dynamic>> _uploadedDocuments = [];
  List<DocumentType> _requiredDocuments = [
    DocumentType.BUSINESS_REGISTRATION,
    DocumentType.TAX_CERTIFICATE,
    DocumentType.ARTICLES_OF_INCORPORATION,
    DocumentType.BENEFICIAL_OWNERSHIP,
  ];

  @override
  void dispose() {
    _companyNameController.dispose();
    _registrationNumberController.dispose();
    _countryController.dispose();
    _addressController.dispose();
    _businessTypeController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _initiateVerification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final businessInfo = {
        'companyName': _companyNameController.text,
        'registrationNumber': _registrationNumberController.text,
        'country': _countryController.text,
        'legalAddress': _addressController.text,
        'businessType': _businessTypeController.text,
        'website': _websiteController.text,
      };

      final result = await VerificationService.initiateVerification(
        type: VerificationType.KYB,
        businessInfo: businessInfo,
      );

      if (result['success'] == true) {
        setState(() {
          _verificationId = result['verificationId'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('KYB verification initiated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showErrorDialog(result['message']);
      }
    } catch (e) {
      _showErrorDialog('Error initiating verification: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadDocument(DocumentType documentType) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _isLoading = true);

        final file = File(result.files.single.path!);
        final uploadResult = await VerificationService.uploadDocument(
          verificationId: _verificationId!,
          documentType: documentType,
          file: file,
        );

        if (uploadResult['success'] == true) {
          setState(() {
            _uploadedDocuments.add({
              'type': documentType,
              'filename': result.files.single.name,
              'status': 'uploaded',
            });
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${VerificationService.getDocumentTypeText(documentType)} uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _showErrorDialog(uploadResult['message']);
        }
      }
    } catch (e) {
      _showErrorDialog('Error uploading document: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForReview() async {
    if (_verificationId == null) return;

    setState(() => _isLoading = true);

    try {
      final result = await VerificationService.submitForReview(_verificationId!);

      if (result['success'] == true) {
        _showSuccessDialog();
      } else {
        _showErrorDialog(result['message']);
      }
    } catch (e) {
      _showErrorDialog('Error submitting for review: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Verification Submitted'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 16),
            Text('Your KYB verification has been submitted for review.'),
            SizedBox(height: 8),
            Text('You will be notified once the review is complete.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYB Verification'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Business Verification',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please provide your business information and upload required documents.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Business Information Form
              if (_verificationId == null) ...[
                const Text(
                  'Business Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _companyNameController,
                  decoration: const InputDecoration(
                    labelText: 'Company Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter company name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _registrationNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Registration Number *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter registration number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Country *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter country';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Legal Address *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter legal address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _businessTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Business Type *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter business type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _websiteController,
                  decoration: const InputDecoration(
                    labelText: 'Website (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _initiateVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Continue to Document Upload'),
                  ),
                ),
              ],

              // Document Upload Section
              if (_verificationId != null) ...[
                const Text(
                  'Required Documents',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                ..._requiredDocuments.map((docType) {
                  final isUploaded = _uploadedDocuments.any((doc) => doc['type'] == docType);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        isUploaded ? Icons.check_circle : Icons.upload_file,
                        color: isUploaded ? Colors.green : Colors.grey,
                      ),
                      title: Text(VerificationService.getDocumentTypeText(docType)),
                      subtitle: isUploaded 
                          ? const Text('Uploaded', style: TextStyle(color: Colors.green))
                          : const Text('Required'),
                      trailing: isUploaded
                          ? const Icon(Icons.done, color: Colors.green)
                          : IconButton(
                              icon: const Icon(Icons.upload),
                              onPressed: _isLoading ? null : () => _uploadDocument(docType),
                            ),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                if (_uploadedDocuments.length == _requiredDocuments.length)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Submit for Review'),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
