import 'package:flutter/material.dart';
import 'widgets/textfield.dart';
import 'widgets/validation.dart';

/// LoginPage - A stateful widget that displays the user login form.
/// This page allows users to sign in to their account by entering their
/// email and password.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// Private state class for LoginPage that manages form state and validation.
class _LoginPageState extends State<LoginPage> {
  // Form key to access form state and trigger validation
  final _formKey = GlobalKey<FormState>();
  
  // Text editing controllers for each input field
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Boolean flag to control password visibility
  bool _obscurePassword = true;
  
  // Loading state to show progress indicator during login
  bool _isLoading = false;

  /// Dispose method to clean up text controllers and prevent memory leaks.
  /// This is called when the widget is removed from the widget tree.
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validation functions are imported from FormValidators class
  // All validation logic is centralized in the validation.dart file

  /// Handles the login process when the login button is pressed.
  /// 
  /// Steps:
  /// 1. Validates all form fields
  /// 2. Shows loading indicator
  /// 3. Performs login (currently simulated with delay)
  /// 4. Shows success message
  /// 5. Navigates to appropriate page (implementation needed)
  Future<void> _handleLogin() async {
    // Validate all form fields before proceeding
    if (_formKey.currentState!.validate()) {
      // Set loading state to show progress indicator
      setState(() {
        _isLoading = true;
      });

      // TODO: Replace with actual API call to your authentication service
      // Example: await authRepository.login(...);
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
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
          ),
        );

        // TODO: Navigate to home page after successful login
        // Example: Navigator.of(context).pushReplacement(MaterialPageRoute(...));
      }
    }
  }

  /// Builds the UI for the login page.
  /// Returns a Scaffold with form fields, validation, and login button.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Light grey background for better visual contrast
      backgroundColor: Colors.grey[50],
      
      // App bar without back button (Login is the initial route)
      appBar: AppBar(
        elevation: 0, // Remove shadow for modern look
        backgroundColor: Colors.transparent, // Transparent background
        automaticallyImplyLeading: false, // Hide back button on initial route
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
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  'Sign in to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),
                
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
                
                // Password input field with visibility toggle
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icons.lock_outline,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  validator: FormValidators.validatePassword,
                  obscureText: _obscurePassword,
                  showPasswordToggle: true,
                  onTogglePasswordVisibility: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  onFieldSubmitted: (_) => _handleLogin(),
                ),
                const SizedBox(height: 12),
                
                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navigate to forgot password page
                      // Example: Navigator.of(context).push(MaterialPageRoute(...));
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Login button - triggers form validation and login
                SizedBox(
                  height: 56, // Fixed height for consistent button size
                  child: ElevatedButton(
                    // Disable button during loading to prevent multiple submissions
                    onPressed: _isLoading ? null : _handleLogin,
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
                            'Sign In',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Link to register page for new users
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to register page
                        Navigator.of(context).pushNamed('/register');
                      },
                      child: Text(
                        'Sign Up',
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

