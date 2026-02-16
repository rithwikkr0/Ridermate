class ValidationUtils {
  // Email validation
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Password validation
  static bool isValidPassword(String password) {
    // Minimum 8 characters
    if (password.length < 8) return false;
    
    // Must contain uppercase
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    
    // Must contain lowercase
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    
    // Must contain number
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    
    return true;
  }

  // Get password strength level (0-4)
  static int getPasswordStrength(String password) {
    int strength = 0;
    
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (password.contains(RegExp(r'[A-Z]')) && password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    return strength > 4 ? 4 : strength;
  }

  // Get password strength label
  static String getPasswordStrengthLabel(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return 'Weak';
    }
  }

  // Phone number validation (basic international format)
  static bool isValidPhoneNumber(String phoneNumber) {
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    return phoneRegex.hasMatch(phoneNumber);
  }

  // Name validation
  static bool isValidName(String name) {
    return name.trim().isNotEmpty && name.trim().length >= 2;
  }

  // Bio validation
  static bool isValidBio(String bio) {
    return bio.length <= 500;
  }

  // Validate URL
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // Sanitize input (remove potentially dangerous characters)
  static String sanitizeInput(String input) {
    return input
        .replaceAll(RegExp(r'[<>]'), '')
        .trim();
  }

  // Get error message for email validation
  static String? validateEmailField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Get error message for password validation
  static String? validatePasswordField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!isValidPassword(value)) {
      return 'Password must contain uppercase, lowercase, and number';
    }
    return null;
  }

  // Get error message for name validation
  static String? validateNameField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (!isValidName(value)) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  // Get error message for phone validation
  static String? validatePhoneField(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    if (!isValidPhoneNumber(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  // Confirm password match validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
