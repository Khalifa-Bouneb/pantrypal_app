import 'package:flutter/material.dart';
import 'dart:developer' show log;
import '../services/auth_service.dart';

// reuse colors from login_screen
const Color kPrimaryGreen = Color(0xFF4CAF50);
const Color kLightGreen = Color(0xFFE8F5E9);
const Color kDarkGreen = Color(0xFF1B5E20);

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _onCreateAccount() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    setState(() => _loading = true);

    try {
      log('Starting account creation for: $email');

      // Create account with Firebase
      final created = await AuthService.createAccount(
        name: name,
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (created) {
        log('Account created successfully for: $email');

        // Return true to indicate success
        Navigator.of(context).pop(true);
      } else {
        log('Account creation returned false');
        _showErrorSnackBar('Account creation failed. Please try again.');
      }
    } catch (e, st) {
      log('Create account error: $e\n$st');

      if (!mounted) return;

      // Extract user-friendly error message
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      _showErrorSnackBar(errorMessage);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Account',
          style: TextStyle(color: kDarkGreen),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: kDarkGreen),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildInputField(
                        controller: _nameCtrl,
                        label: 'Full Name',
                        hint: 'Enter your name',
                        icon: Icons.person_outline,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Name is required';
                          }
                          if (v.trim().length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        controller: _emailCtrl,
                        label: 'Email',
                        hint: 'Enter your email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!v.contains('@') || !v.contains('.')) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildPasswordField(
                        controller: _passwordCtrl,
                        label: 'Password',
                        hint: 'Enter your password',
                        obscure: _obscurePassword,
                        onToggle: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Password is required';
                          }
                          if (v.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          if (!v.contains(RegExp(r'[A-Za-z]'))) {
                            return 'Password must contain at least one letter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildPasswordField(
                        controller: _confirmCtrl,
                        label: 'Confirm Password',
                        hint: 'Confirm your password',
                        obscure: _obscureConfirm,
                        onToggle: () {
                          setState(() {
                            _obscureConfirm = !_obscureConfirm;
                          });
                        },
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (v != _passwordCtrl.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _loading
                    ? const SizedBox(
                        height: 56,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              kPrimaryGreen,
                            ),
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _onCreateAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('Create Account'),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                const SizedBox(height: 20),

                // Password requirements info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kLightGreen,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kPrimaryGreen.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.info_outline, color: kDarkGreen, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Password Requirements:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: kDarkGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildRequirement('At least 6 characters'),
                      _buildRequirement('Contains letters'),
                      _buildRequirement('Passwords must match'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, top: 4),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 16,
            color: kPrimaryGreen,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: kLightGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: kPrimaryGreen,
            child: Icon(Icons.person_add, size: 48, color: Colors.white),
          ),
          SizedBox(height: 16),
          Text(
            'Join PantryPal',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kDarkGreen,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Create an account to get started',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.lock_outline, color: kPrimaryGreen),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: kPrimaryGreen,
              ),
              onPressed: onToggle,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kPrimaryGreen, width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 10.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: kPrimaryGreen),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kPrimaryGreen, width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 10.0,
            ),
          ),
        ),
      ],
    );
  }
}
