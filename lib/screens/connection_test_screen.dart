import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class ConnectionTestScreen extends StatefulWidget {
  const ConnectionTestScreen({super.key});

  @override
  State<ConnectionTestScreen> createState() => _ConnectionTestScreenState();
}

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  List<Map<String, dynamic>> _testResults = [];
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  Future<void> _runTests() async {
    setState(() {
      _isTesting = true;
      _testResults.clear();
    });

    // Test main URL
    await _testUrl(ApiConfig.baseUrl, 'Main URL');
    
    // Test fallback URLs
    for (int i = 0; i < ApiConfig.fallbackUrls.length; i++) {
      await _testUrl(ApiConfig.fallbackUrls[i], 'Fallback ${i + 1}');
    }

    setState(() => _isTesting = false);
  }

  Future<void> _testUrl(String url, String label) async {
    try {
      final response = await http.get(
        Uri.parse('$url/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      setState(() {
        _testResults.add({
          'label': label,
          'url': url,
          'status': response.statusCode,
          'success': response.statusCode == 200,
          'response': response.body,
        });
      });
    } catch (e) {
      setState(() {
        _testResults.add({
          'label': label,
          'url': url,
          'status': 0,
          'success': false,
          'response': e.toString(),
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Connection Test', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _runTests,
          ),
        ],
      ),
      body: _isTesting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text('Testing connections...', style: TextStyle(color: Colors.white)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _testResults.length,
              itemBuilder: (context, index) {
                final result = _testResults[index];
                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              result['success'] ? Icons.check_circle : Icons.error,
                              color: result['success'] ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              result['label'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          result['url'],
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${result['status']}',
                          style: TextStyle(
                            color: result['success'] ? Colors.green : Colors.red,
                            fontSize: 14,
                          ),
                        ),
                        if (!result['success']) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Error: ${result['response']}',
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}