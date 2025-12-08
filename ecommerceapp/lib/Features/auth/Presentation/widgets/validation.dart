/// Validation utility class for form field validation.
/// 
/// This class contains all validation functions used in authentication forms.
/// All validators return a String error message if validation fails, or null if valid.
class FormValidators {
  /// Validates the full name input field.
  /// 
  /// Validation rules:
  /// - Field cannot be empty
  /// - Name must be at least 3 characters long
  /// 
  /// Returns an error message if validation fails, null if valid.
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  /// Validates the email input field.
  /// 
  /// Validation rules:
  /// - Field cannot be empty
  /// - Must match standard email format (e.g., user@example.com)
  /// 
  /// Returns an error message if validation fails, null if valid.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    // Regular expression to validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validates the phone number input field.
  /// 
  /// Note: Phone number is optional, but if provided, must be at least 10 digits.
  /// 
  /// Returns an error message if validation fails, null if valid.
  static String? validatePhone(String? value) {
    // Phone is optional, but if provided, validate it
    if (value != null && value.isNotEmpty) {
      if (value.length < 10) {
        return 'Please enter a valid phone number';
      }
    }
    return null;
  }

  /// Validates the password input field.
  /// 
  /// Validation rules:
  /// - Field cannot be empty
  /// - Password must be at least 6 characters long
  /// 
  /// Returns an error message if validation fails, null if valid.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validates the confirm password input field.
  /// 
  /// Validation rules:
  /// - Field cannot be empty
  /// - Must match the password entered in the password field
  /// 
  /// Parameters:
  /// - [value] - The confirm password value to validate
  /// - [originalPassword] - The original password to compare against
  /// 
  /// Returns an error message if validation fails, null if valid.
  static String? validateConfirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    // Check if confirm password matches the original password
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}

