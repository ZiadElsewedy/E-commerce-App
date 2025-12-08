import 'package:flutter/material.dart';
import 'widgets/textfield.dart';
import 'widgets/validation.dart';

/// RegisterPage - A stateful widget that displays the user registration form.
/// This page allows users to create a new account by entering their personal
/// information including name, email, phone, and password.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

/// Private state class for RegisterPage that manages form state and validation.
class _RegisterPageState extends State<RegisterPage> {
  // Form key to access form state and trigger validation
  final _formKey = GlobalKey<FormState>();
  
  // Text editing controllers for each input field
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Boolean flags to control password visibility
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // Loading state to show progress indicator during registration
  bool _isLoading = false;

  /// Dispose method to clean up text controllers and prevent memory leaks.
  /// This is called when the widget is removed from the widget tree.
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Validation functions are now imported from FormValidators class
  // All validation logic is centralized in the validation.dart file

  /// Handles the registration process when the register button is pressed.
  /// 
  /// Steps:
  /// 1. Validates all form fields
  /// 2. Shows loading indicator
  /// 3. Performs registration (currently simulated with delay)
  /// 4. Shows success message
  /// 5. Navigates to appropriate page (implementation needed)
  Future<void> _handleRegister() async {
    // Validate all form fields before proceeding
    if (_formKey.currentState!.validate()) {
      // Set loading state to show progress indicator
      setState(() {
        _isLoading = true;
      });

      // TODO: Replace with actual API call to your authentication service
      // Example: await authRepository.register(...);
      // Simulate API call with delay
      await Future.delayed(const Duration(seconds: 2));

      // Check if widget is still mounted before updating state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show success message to user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: Colors.green,
          ),
        );

        // TODO: Navigate to home or login page after successful registration
        // Example: Navigator.of(context).pushReplacement(MaterialPageRoute(...));
      }
    }
  }

  /// Builds the UI for the registration page.
  /// Returns a Scaffold with form fields, validation, and registration button.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Light grey background for better visual contrast
      backgroundColor: Colors.grey[50],
      
      // App bar with back button (to navigate back to login page)
      appBar: AppBar(
        elevation: 0, // Remove shadow for modern look
        backgroundColor: Colors.transparent, // Transparent background
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => Navigator.of(context).pop(), // Navigate back to login
        ),
      ),
      
      // Main body content
      body: SafeArea(
        child: SingleChildScrollView(
          // Horizontal padding for consistent margins
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey, // Form key for validation
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Page title
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  'Sign up to get started',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),
                
                // Full Name input field
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  validator: FormValidators.validateName,
                ),
                const SizedBox(height: 20),
                
                // Email input field
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: FormValidators.validateEmail,
                ),
                const SizedBox(height: 20),
                
                // Phone number input field (optional)
                CustomTextField(
                  controller: _phoneController,
                  labelText: 'Phone Number (Optional)',
                  hintText: 'Enter your phone number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: FormValidators.validatePhone,
                ),
                const SizedBox(height: 20),
                
                // Password input field with visibility toggle
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icons.lock_outline,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: FormValidators.validatePassword,
                  obscureText: _obscurePassword,
                  showPasswordToggle: true,
                  onTogglePasswordVisibility: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                const SizedBox(height: 20),
                
                // Confirm password input field with visibility toggle
                CustomTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm Password',
                  hintText: 'Confirm your password',
                  prefixIcon: Icons.lock_outline,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  validator: (value) => FormValidators.validateConfirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  obscureText: _obscureConfirmPassword,
                  showPasswordToggle: true,
                  onTogglePasswordVisibility: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  onFieldSubmitted: (_) => _handleRegister(),
                ),
                const SizedBox(height: 32),
                
                // Register button - triggers form validation and registration
                SizedBox(
                  height: 56, // Fixed height for consistent button size
                  child: ElevatedButton(
                    // Disable button during loading to prevent multiple submissions
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Rounded corners
                      ),
                      elevation: 2, // Subtle shadow
                    ),
                    // Show loading indicator or button text based on state
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Link to login page for existing users
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to login page
                        Navigator.of(context).pushNamed('/login');
                      },
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}