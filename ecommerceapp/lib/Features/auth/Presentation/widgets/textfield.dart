import 'package:flutter/material.dart';

/// CustomTextField - A reusable text input field widget.
/// 
/// This widget provides a consistent styling and behavior for all text fields
/// in the application. It supports various input types, validation, and optional
/// password visibility toggle.
class CustomTextField extends StatelessWidget {
  /// Controller for the text field
  final TextEditingController controller;
  
  /// Label text displayed above the field
  final String labelText;
  
  /// Hint text displayed inside the field when empty
  final String hintText;
  
  /// Icon displayed at the start of the field
  final IconData prefixIcon;
  
  /// Keyboard type (e.g., email, phone, text)
  final TextInputType keyboardType;
  
  /// Action button on the keyboard (e.g., next, done)
  final TextInputAction textInputAction;
  
  /// Validation function that returns error message or null
  final String? Function(String?)? validator;
  
  /// Callback when field is submitted (usually when "done" is pressed)
  final void Function(String)? onFieldSubmitted;
  
  /// Whether the text should be obscured (for passwords)
  final bool obscureText;
  
  /// Whether to show password visibility toggle button
  final bool showPasswordToggle;
  
  /// Callback to toggle password visibility (only used if showPasswordToggle is true)
  final VoidCallback? onTogglePasswordVisibility;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onFieldSubmitted,
    this.obscureText = false,
    this.showPasswordToggle = false,
    this.onTogglePasswordVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // Text controller to manage the field's value
      controller: controller,
      
      // Keyboard configuration
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      
      // Validation
      validator: validator,
      
      // Password visibility
      obscureText: obscureText,
      
      // Submit callback
      onFieldSubmitted: onFieldSubmitted,
      
      // Field decoration with consistent styling
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        
        // Icon at the start of the field
        prefixIcon: Icon(prefixIcon),
        
        // Password visibility toggle button (if enabled)
        suffixIcon: showPasswordToggle && onTogglePasswordVisibility != null
            ? IconButton(
                icon: Icon(
                  obscureText 
                      ? Icons.visibility_outlined 
                      : Icons.visibility_off_outlined,
                ),
                onPressed: onTogglePasswordVisibility,
              )
            : null,
        
        // Border styling with rounded corners
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        
        // Filled background for better visual appearance
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

