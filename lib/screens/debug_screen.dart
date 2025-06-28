import 'package:flutter/material.dart';
import '../services/simple_storage_service.dart';
import '../models/user.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  String _debugInfo = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    try {
      final info = await SimpleStorageService.getDebugInfo();
      
      setState(() {
        _debugInfo = '''
🔍 Debug Information:

📱 Storage Available: ${info['storage_available']}
👥 Memory Users: ${info['memory_users']}
💾 Storage Users: ${info['storage_users'] ?? 'N/A'}
👤 Current User: ${info['current_user']}
🔐 Is Logged In: ${info['is_logged_in']}

📋 Storage Keys: ${info['storage_keys']?.join(', ') ?? 'N/A'}

${info['error'] != null ? '❌ Error: ${info['error']}' : '✅ No Errors'}

📝 Instructions:
1. Try "Test Registration" button
2. If successful, try normal registration
3. If failed, storage may not be available
4. Use "Clear All Data" to reset
''';
      });
    } catch (e) {
      setState(() {
        _debugInfo = '❌ Error loading debug info: $e';
      });
    }
  }

  Future<void> _testRegistration() async {
    try {
      setState(() {
        _debugInfo += '\n🧪 Testing registration...';
      });
      
      await SimpleStorageService.clearAllData();
      
      final testUser = User(
        username: 'Test User',
        email: 'test@test.com',
        password: '123456'
      );
      
      await SimpleStorageService.registerUser(testUser);
      
      setState(() {
        _debugInfo += '\n✅ Test registration SUCCESS!';
      });
      
      await _loadDebugInfo();
    } catch (e) {
      setState(() {
        _debugInfo += '\n❌ Test registration FAILED: $e';
      });
    }
  }

  Future<void> _testLogin() async {
    try {
      setState(() {
        _debugInfo += '\n🔐 Testing login...';
      });
      
      final user = await SimpleStorageService.login('test@test.com', '123456');
      
      if (user != null) {
        setState(() {
          _debugInfo += '\n✅ Test login SUCCESS! Welcome ${user.username}';
        });
      } else {
        setState(() {
          _debugInfo += '\n❌ Test login FAILED: No user returned';
        });
      }
      
      await _loadDebugInfo();
    } catch (e) {
      setState(() {
        _debugInfo += '\n❌ Test login FAILED: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Debug Tools',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadDebugInfo,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Debug info display
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _debugInfo,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Action buttons
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _testRegistration,
                        icon: const Icon(Icons.person_add),
                        label: const Text('Test Registration'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _testLogin,
                        icon: const Icon(Icons.login),
                        label: const Text('Test Login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await SimpleStorageService.clearAllData();
                          await _loadDebugInfo();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🗑️ All data cleared!'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('Clear All Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _loadDebugInfo,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
