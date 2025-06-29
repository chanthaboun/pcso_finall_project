import 'package:flutter/material.dart';
import '../services/simple_storage_service.dart';
import 'home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final currentUser = await SimpleStorageService.getCurrentUser();
        if (currentUser != null) {
          final updatedUser = currentUser.copyWith(
            name: _nameController.text.trim(),
            age: int.parse(_ageController.text),
            weight: double.parse(_weightController.text),
            height: double.parse(_heightController.text),
          );

          await SimpleStorageService.updateUser(updatedUser);

          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ເກີດຂໍ້ຜິດພາດ ກະລຸນາລອງໃໝ່'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Profile avatar
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFFE91E63),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 32),

              Expanded(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Name field
                      _buildInputField(
                        controller: _nameController,
                        label: 'ຊື່:',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'ກະລຸນາປ້ອນຊື່';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Age field
                      _buildInputField(
                        controller: _ageController,
                        label: 'ອາຍຸ:',
                        icon: Icons.cake,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'ກະລຸນາປ້ອນອາຍຸ';
                          }
                          final age = int.tryParse(value);
                          if (age == null || age < 10 || age > 100) {
                            return 'ອາຍຸບໍ່ຖືກຕ້ອງ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Weight field
                      _buildInputField(
                        controller: _weightController,
                        label: 'ນ້ຳໜັກ:',
                        icon: Icons.scale,
                        keyboardType: TextInputType.number,
                        suffix: 'kg',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'ກະລຸນາປ້ອນນ້ຳໜັກ';
                          }
                          final weight = double.tryParse(value);
                          if (weight == null || weight < 30 || weight > 200) {
                            return 'ນ້ຳໜັກບໍ່ຖືກຕ້ອງ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Height field
                      _buildInputField(
                        controller: _heightController,
                        label: 'ສ່ວນສູງ:',
                        icon: Icons.height,
                        keyboardType: TextInputType.number,
                        suffix: 'cm',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'ກະລຸນາປ້ອນສ່ວນສູງ';
                          }
                          final height = double.tryParse(value);
                          if (height == null || height < 100 || height > 250) {
                            return 'ສ່ວນສູງບໍ່ຖືກຕ້ອງ';
                          }
                          return null;
                        },
                      ),
                      const Spacer(),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE91E63),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : const Text(
                                  'ເພີ່ມຂໍ້ມູນ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? suffix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFFE91E63),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: const Color(0xFFE91E63),
            ),
            suffixText: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
