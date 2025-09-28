import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';
import '../../../widgets/custom_button.dart';

class BlockZenLoginScreen extends StatefulWidget {
  static const String routeName = '/blockzen/login';

  const BlockZenLoginScreen({super.key});

  @override
  State<BlockZenLoginScreen> createState() => _BlockZenLoginScreenState();
}

class _BlockZenLoginScreenState extends State<BlockZenLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'Project Developer';
  bool _isLogin = true;
  bool _isLoading = false;

  final List<String> _roles = [
    'Project Developer',
    'Credit Buyer',
    'Verifier',
    'Administrator',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1416),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // Logo and Title
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D47A1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ImageIcon(
                  AssetImage('assets/images/logo.png'),
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'BlockZen',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Carbon Credit Marketplace',
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
              const SizedBox(height: 60),

              // Role Selection (only for signup)
              if (!_isLogin) ...[
                const Text(
                  'Select Your Role',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF0D47A1)),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    dropdownColor: const Color(0xFF1E1E1E),
                    style: const TextStyle(color: Colors.white),
                    underline: Container(),
                    isExpanded: true,
                    items: _roles.map((role) {
                      return DropdownMenuItem(value: role, child: Text(role));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Login/Signup Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: _isLoading
                            ? 'Please wait...'
                            : (_isLogin ? 'Login' : 'Sign Up'),
                        onPressed: _isLoading ? () {} : _handleSubmitSync,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Toggle Login/Signup
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                  _isLogin
                      ? 'Don\'t have an account? Sign Up'
                      : 'Already have an account? Login',
                  style: const TextStyle(color: Color(0xFF0D47A1)),
                ),
              ),

              // KYC Upload Option (only for signup)
              if (!_isLogin) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Implement KYC document upload
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('KYC upload coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.upload_file, color: Color(0xFF0D47A1)),
                  label: const Text(
                    'Upload KYC Documents',
                    style: TextStyle(color: Color(0xFF0D47A1)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmitSync() {
    _handleSubmit();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (_isLogin) {
        // TODO: Implement login with Firebase/Django
        await Future.delayed(const Duration(seconds: 1)); // Simulate API call

        // Mock successful login
        final success = await userProvider.login(
          email: _emailController.text,
          password: _passwordController.text,
          role: _selectedRole,
        );

        if (success && mounted) {
          Navigator.pushReplacementNamed(context, '/blockzen/dashboard');
        }
      } else {
        // TODO: Implement signup with Firebase/Django
        await Future.delayed(const Duration(seconds: 1)); // Simulate API call

        // Mock successful signup
        final success = await userProvider.signup(
          email: _emailController.text,
          password: _passwordController.text,
          role: _selectedRole,
        );

        if (success && mounted) {
          Navigator.pushReplacementNamed(context, '/blockzen/dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
