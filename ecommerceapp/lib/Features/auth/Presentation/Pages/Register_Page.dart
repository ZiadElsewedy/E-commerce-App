import 'package:flutter/material.dart';
import '../widgets/textfield.dart';
import '../widgets/validation.dart';
import '../widgets/custom_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[600]),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Icon(
                  Icons.person_add_alt_1,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 30),
                Text(
                  'CREATE ACCOUNT',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 50),
                CustomTextField(
                  controller: _nameController,
                  hintText: 'Full Name',
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  validator: FormValidators.validateName,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: FormValidators.validateEmail,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phoneController,
                  hintText: 'Phone Number (Optional)',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: FormValidators.validatePhone,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  textInputAction: TextInputAction.next,
                  validator: FormValidators.validatePassword,
                  obscureText: _obscurePassword,
                  showPasswordToggle: true,
                  onTogglePasswordVisibility: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  textInputAction: TextInputAction.done,
                  validator: (value) => FormValidators.validateConfirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  obscureText: _obscureConfirmPassword,
                  showPasswordToggle: true,
                  onTogglePasswordVisibility: () {
                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                  onFieldSubmitted: (_) => _handleRegister(),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'REGISTER',
                  onPressed: _handleRegister,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed('/login'),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}