/// Validation functions for contract fields
/// Similar to Kivy's validation system but adapted for Flutter
class ContractValidators {
  /// Validate CNP (Cod Numeric Personal - Romanian Personal ID)
  /// CNP format: 13 digits
  static String? validateCNP(String? value) {
    if (value == null || value.isEmpty) {
      return 'CNP is required';
    }

    // Remove any spaces or dashes
    final cleanValue = value.replaceAll(RegExp(r'[\s-]'), '');

    // Check if it's 13 digits
    if (cleanValue.length != 13) {
      return 'CNP must be 13 digits';
    }

    // Check if all characters are digits
    if (!RegExp(r'^\d{13}$').hasMatch(cleanValue)) {
      return 'CNP must contain only digits';
    }

    // Basic validation: first digit must be 1-8
    final firstDigit = int.parse(cleanValue[0]);
    if (firstDigit < 1 || firstDigit > 8) {
      return 'Invalid CNP format';
    }

    // Validate checksum (last digit)
    const weights = [2, 7, 9, 1, 4, 6, 3, 5, 8, 2, 7, 9];
    int sum = 0;

    for (int i = 0; i < 12; i++) {
      sum += int.parse(cleanValue[i]) * weights[i];
    }

    final checksum = sum % 11 == 10 ? 1 : sum % 11;
    final providedChecksum = int.parse(cleanValue[12]);

    if (checksum != providedChecksum) {
      return 'Invalid CNP checksum';
    }

    return null;
  }

  /// Validate CUI (Cod Unic de Identificare - Romanian Company ID)
  /// CUI format: 2-10 digits
  static String? validateCUI(String? value) {
    if (value == null || value.isEmpty) {
      return 'CUI is required';
    }

    // Remove any spaces, dashes, or "RO" prefix
    final cleanValue = value
        .replaceAll(RegExp(r'[\s-]'), '')
        .replaceAll(RegExp(r'^RO', caseSensitive: false), '');

    // Check if it's 2-10 digits
    if (cleanValue.length < 2 || cleanValue.length > 10) {
      return 'CUI must be between 2 and 10 digits';
    }

    // Check if all characters are digits
    if (!RegExp(r'^\d+$').hasMatch(cleanValue)) {
      return 'CUI must contain only digits';
    }

    return null;
  }

  /// Validate VIN (Vehicle Identification Number)
  /// VIN format: 17 characters (alphanumeric, excluding I, O, Q)
  static String? validateVIN(String? value) {
    if (value == null || value.isEmpty) {
      return null; // VIN is optional
    }

    // Convert to uppercase and remove spaces
    final cleanValue = value.toUpperCase().replaceAll(' ', '');

    // Check length
    if (cleanValue.length != 17) {
      return 'VIN must be exactly 17 characters';
    }

    // Check for invalid characters (I, O, Q are not allowed in VIN)
    if (RegExp(r'[IOQ]').hasMatch(cleanValue)) {
      return 'VIN cannot contain I, O, or Q';
    }

    // Check if it's alphanumeric
    if (!RegExp(r'^[A-HJ-NPR-Z0-9]{17}$').hasMatch(cleanValue)) {
      return 'VIN must be alphanumeric (excluding I, O, Q)';
    }

    return null;
  }

  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email is optional
    }

    // Basic email regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate Romanian phone number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove spaces, dashes, and parentheses
    final cleanValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Check for Romanian phone number formats
    // +40XXXXXXXXX or 0XXXXXXXXX (10 digits after 0 or 12 digits with +40)
    if (cleanValue.startsWith('+40')) {
      if (cleanValue.length != 12) {
        return 'Phone number with +40 must have 12 digits';
      }
      if (!RegExp(r'^\+40\d{9}$').hasMatch(cleanValue)) {
        return 'Invalid phone number format';
      }
    } else if (cleanValue.startsWith('0')) {
      if (cleanValue.length != 10) {
        return 'Phone number starting with 0 must have 10 digits';
      }
      if (!RegExp(r'^0\d{9}$').hasMatch(cleanValue)) {
        return 'Invalid phone number format';
      }
    } else {
      return 'Phone number must start with +40 or 0';
    }

    return null;
  }

  /// Validate postal code (Romanian format)
  static String? validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Postal code is required';
    }

    // Romanian postal code: 6 digits
    if (value.length != 6) {
      return 'Postal code must be 6 digits';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Postal code must contain only digits';
    }

    return null;
  }

  /// Validate ID series (Romanian format)
  static String? validateIdSeries(String? value) {
    if (value == null || value.isEmpty) {
      return 'ID series is required';
    }

    // ID series: 2 uppercase letters
    if (value.length != 2) {
      return 'ID series must be 2 letters';
    }

    if (!RegExp(r'^[A-Z]{2}$').hasMatch(value.toUpperCase())) {
      return 'ID series must be 2 uppercase letters';
    }

    return null;
  }

  /// Validate ID number (Romanian format)
  static String? validateIdNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'ID number is required';
    }

    // ID number: 6 digits
    if (value.length != 6) {
      return 'ID number must be 6 digits';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'ID number must contain only digits';
    }

    return null;
  }

  /// Validate year
  static String? validateYear(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Year is optional
    }

    if (value.length != 4) {
      return 'Year must be 4 digits';
    }

    final year = int.tryParse(value);
    if (year == null) {
      return 'Invalid year';
    }

    final currentYear = DateTime.now().year;
    if (year < 1900 || year > currentYear + 1) {
      return 'Year must be between 1900 and ${currentYear + 1}';
    }

    return null;
  }

  /// Validate price
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }

    final price = double.tryParse(value.replaceAll(',', '.'));
    if (price == null) {
      return 'Invalid price format';
    }

    if (price <= 0) {
      return 'Price must be greater than 0';
    }

    if (price > 999999999) {
      return 'Price is too large';
    }

    return null;
  }

  /// Validate required text field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length > maxLength) {
      return '$fieldName must be at most $maxLength characters';
    }

    return null;
  }

  /// Validate alphanumeric
  static String? validateAlphanumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (!RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(value)) {
      return '$fieldName must contain only letters and numbers';
    }

    return null;
  }

  /// Validate alphabetic (letters only)
  static String? validateAlphabetic(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return '$fieldName must contain only letters';
    }

    return null;
  }

  /// Validate numeric
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return '$fieldName must contain only numbers';
    }

    return null;
  }

  /// Combine multiple validators
  static String? Function(String?) combineValidators(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) {
          return error;
        }
      }
      return null;
    };
  }
}
