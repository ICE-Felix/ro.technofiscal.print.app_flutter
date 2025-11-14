import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Represents a single field in the contract generation flow
class FieldDefinition {
  final String key;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final bool isNumeric;
  final int? maxLength;
  final List<TextInputFormatter>? formatters;
  final String? Function(String?)? validator;
  final String? nextFieldKey;
  final String? previousFieldKey;
  final String section; // For grouping fields

  const FieldDefinition({
    required this.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.isNumeric = false,
    this.maxLength,
    this.formatters,
    this.validator,
    this.nextFieldKey,
    this.previousFieldKey,
    required this.section,
  });
}

/// Centralized registry of all contract fields
class FieldRegistry {
  // Seller fields
  static const String sellerEntityType = 'seller_entity_type';
  static const String sellerFullName = 'seller_full_name';
  static const String sellerCNP = 'seller_cnp';
  static const String sellerIdSeries = 'seller_id_series';
  static const String sellerIdNumber = 'seller_id_number';
  static const String sellerCountry = 'seller_country';
  static const String sellerCounty = 'seller_county';
  static const String sellerCity = 'seller_city';
  static const String sellerPostalCode = 'seller_postal_code';
  static const String sellerStreet = 'seller_street';
  static const String sellerStreetNumber = 'seller_street_number';
  static const String sellerPhone = 'seller_phone';
  static const String sellerEmail = 'seller_email';

  // Buyer fields
  static const String buyerEntityType = 'buyer_entity_type';
  static const String buyerFullName = 'buyer_full_name';
  static const String buyerCNP = 'buyer_cnp';
  static const String buyerIdSeries = 'buyer_id_series';
  static const String buyerIdNumber = 'buyer_id_number';
  static const String buyerCountry = 'buyer_country';
  static const String buyerCounty = 'buyer_county';
  static const String buyerCity = 'buyer_city';
  static const String buyerPostalCode = 'buyer_postal_code';
  static const String buyerStreet = 'buyer_street';
  static const String buyerStreetNumber = 'buyer_street_number';
  static const String buyerPhone = 'buyer_phone';
  static const String buyerEmail = 'buyer_email';

  // Object details fields
  static const String objectCategory = 'object_category';
  static const String objectDescription = 'object_description';
  static const String objectBrand = 'object_brand';
  static const String objectModel = 'object_model';
  static const String objectSerialNumber = 'object_serial_number';
  static const String objectVIN = 'object_vin';
  static const String objectYear = 'object_year';
  static const String objectCondition = 'object_condition';

  // Contract details fields
  static const String contractPrice = 'contract_price';
  static const String contractCurrency = 'contract_currency';
  static const String contractPaymentMethod = 'contract_payment_method';
  static const String contractDeliveryDate = 'contract_delivery_date';
  static const String contractLocation = 'contract_location';
  static const String contractTerms = 'contract_terms';
  static const String contractWarranty = 'contract_warranty';

  /// Get all fields in order
  static List<FieldDefinition> getAllFields() {
    return [
      // Seller Section
      FieldDefinition(
        key: sellerEntityType,
        label: 'Entity Type',
        hint: 'Individual or Company',
        icon: Icons.business_center,
        section: 'Seller Information',
        nextFieldKey: sellerFullName,
      ),
      FieldDefinition(
        key: sellerFullName,
        label: 'Full Name / Company Name',
        hint: 'Enter full legal name',
        icon: Icons.person,
        section: 'Seller Information',
        previousFieldKey: sellerEntityType,
        nextFieldKey: sellerCNP,
      ),
      FieldDefinition(
        key: sellerCNP,
        label: 'CNP / CUI',
        hint: 'Enter CNP (personal) or CUI (company)',
        icon: Icons.badge,
        keyboardType: TextInputType.number,
        isNumeric: true,
        maxLength: 13,
        section: 'Seller Information',
        previousFieldKey: sellerFullName,
        nextFieldKey: sellerIdSeries,
      ),
      FieldDefinition(
        key: sellerIdSeries,
        label: 'ID Series',
        hint: 'e.g., RX',
        icon: Icons.credit_card,
        formatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Z]')),
          LengthLimitingTextInputFormatter(2),
        ],
        section: 'Seller Information',
        previousFieldKey: sellerCNP,
        nextFieldKey: sellerIdNumber,
      ),
      FieldDefinition(
        key: sellerIdNumber,
        label: 'ID Number',
        hint: 'Enter ID card number',
        icon: Icons.numbers,
        keyboardType: TextInputType.number,
        isNumeric: true,
        maxLength: 6,
        section: 'Seller Information',
        previousFieldKey: sellerIdSeries,
        nextFieldKey: sellerCountry,
      ),
      FieldDefinition(
        key: sellerCountry,
        label: 'Country',
        hint: 'e.g., Romania',
        icon: Icons.flag,
        section: 'Seller Information',
        previousFieldKey: sellerIdNumber,
        nextFieldKey: sellerCounty,
      ),
      FieldDefinition(
        key: sellerCounty,
        label: 'County',
        hint: 'e.g., Cluj',
        icon: Icons.location_city,
        section: 'Seller Information',
        previousFieldKey: sellerCountry,
        nextFieldKey: sellerCity,
      ),
      FieldDefinition(
        key: sellerCity,
        label: 'City',
        hint: 'e.g., Cluj-Napoca',
        icon: Icons.location_on,
        section: 'Seller Information',
        previousFieldKey: sellerCounty,
        nextFieldKey: sellerPostalCode,
      ),
      FieldDefinition(
        key: sellerPostalCode,
        label: 'Postal Code',
        hint: 'e.g., 400001',
        icon: Icons.markunread_mailbox,
        keyboardType: TextInputType.number,
        isNumeric: true,
        maxLength: 6,
        section: 'Seller Information',
        previousFieldKey: sellerCity,
        nextFieldKey: sellerStreet,
      ),
      FieldDefinition(
        key: sellerStreet,
        label: 'Street',
        hint: 'Enter street name',
        icon: Icons.route,
        section: 'Seller Information',
        previousFieldKey: sellerPostalCode,
        nextFieldKey: sellerStreetNumber,
      ),
      FieldDefinition(
        key: sellerStreetNumber,
        label: 'Street Number',
        hint: 'e.g., 123',
        icon: Icons.home,
        section: 'Seller Information',
        previousFieldKey: sellerStreet,
        nextFieldKey: sellerPhone,
      ),
      FieldDefinition(
        key: sellerPhone,
        label: 'Phone Number',
        hint: '+40 123 456 789',
        icon: Icons.phone,
        keyboardType: TextInputType.phone,
        isNumeric: true,
        section: 'Seller Information',
        previousFieldKey: sellerStreetNumber,
        nextFieldKey: sellerEmail,
      ),
      FieldDefinition(
        key: sellerEmail,
        label: 'Email (Optional)',
        hint: 'email@example.com',
        icon: Icons.email,
        keyboardType: TextInputType.emailAddress,
        section: 'Seller Information',
        previousFieldKey: sellerPhone,
        nextFieldKey: buyerEntityType,
      ),

      // Buyer Section
      FieldDefinition(
        key: buyerEntityType,
        label: 'Entity Type',
        hint: 'Individual or Company',
        icon: Icons.business_center,
        section: 'Buyer Information',
        previousFieldKey: sellerEmail,
        nextFieldKey: buyerFullName,
      ),
      FieldDefinition(
        key: buyerFullName,
        label: 'Full Name / Company Name',
        hint: 'Enter full legal name',
        icon: Icons.person,
        section: 'Buyer Information',
        previousFieldKey: buyerEntityType,
        nextFieldKey: buyerCNP,
      ),
      FieldDefinition(
        key: buyerCNP,
        label: 'CNP / CUI',
        hint: 'Enter CNP (personal) or CUI (company)',
        icon: Icons.badge,
        keyboardType: TextInputType.number,
        isNumeric: true,
        maxLength: 13,
        section: 'Buyer Information',
        previousFieldKey: buyerFullName,
        nextFieldKey: buyerIdSeries,
      ),
      FieldDefinition(
        key: buyerIdSeries,
        label: 'ID Series',
        hint: 'e.g., RX',
        icon: Icons.credit_card,
        formatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Z]')),
          LengthLimitingTextInputFormatter(2),
        ],
        section: 'Buyer Information',
        previousFieldKey: buyerCNP,
        nextFieldKey: buyerIdNumber,
      ),
      FieldDefinition(
        key: buyerIdNumber,
        label: 'ID Number',
        hint: 'Enter ID card number',
        icon: Icons.numbers,
        keyboardType: TextInputType.number,
        isNumeric: true,
        maxLength: 6,
        section: 'Buyer Information',
        previousFieldKey: buyerIdSeries,
        nextFieldKey: buyerCountry,
      ),
      FieldDefinition(
        key: buyerCountry,
        label: 'Country',
        hint: 'e.g., Romania',
        icon: Icons.flag,
        section: 'Buyer Information',
        previousFieldKey: buyerIdNumber,
        nextFieldKey: buyerCounty,
      ),
      FieldDefinition(
        key: buyerCounty,
        label: 'County',
        hint: 'e.g., Cluj',
        icon: Icons.location_city,
        section: 'Buyer Information',
        previousFieldKey: buyerCountry,
        nextFieldKey: buyerCity,
      ),
      FieldDefinition(
        key: buyerCity,
        label: 'City',
        hint: 'e.g., Cluj-Napoca',
        icon: Icons.location_on,
        section: 'Buyer Information',
        previousFieldKey: buyerCounty,
        nextFieldKey: buyerPostalCode,
      ),
      FieldDefinition(
        key: buyerPostalCode,
        label: 'Postal Code',
        hint: 'e.g., 400001',
        icon: Icons.markunread_mailbox,
        keyboardType: TextInputType.number,
        isNumeric: true,
        maxLength: 6,
        section: 'Buyer Information',
        previousFieldKey: buyerCity,
        nextFieldKey: buyerStreet,
      ),
      FieldDefinition(
        key: buyerStreet,
        label: 'Street',
        hint: 'Enter street name',
        icon: Icons.route,
        section: 'Buyer Information',
        previousFieldKey: buyerPostalCode,
        nextFieldKey: buyerStreetNumber,
      ),
      FieldDefinition(
        key: buyerStreetNumber,
        label: 'Street Number',
        hint: 'e.g., 123',
        icon: Icons.home,
        section: 'Buyer Information',
        previousFieldKey: buyerStreet,
        nextFieldKey: buyerPhone,
      ),
      FieldDefinition(
        key: buyerPhone,
        label: 'Phone Number',
        hint: '+40 123 456 789',
        icon: Icons.phone,
        keyboardType: TextInputType.phone,
        isNumeric: true,
        section: 'Buyer Information',
        previousFieldKey: buyerStreetNumber,
        nextFieldKey: buyerEmail,
      ),
      FieldDefinition(
        key: buyerEmail,
        label: 'Email (Optional)',
        hint: 'email@example.com',
        icon: Icons.email,
        keyboardType: TextInputType.emailAddress,
        section: 'Buyer Information',
        previousFieldKey: buyerPhone,
        nextFieldKey: objectCategory,
      ),

      // Object Details Section
      FieldDefinition(
        key: objectCategory,
        label: 'Object Category',
        hint: 'e.g., Vehicle, Electronics, Real Estate',
        icon: Icons.category,
        section: 'Object Details',
        previousFieldKey: buyerEmail,
        nextFieldKey: objectDescription,
      ),
      FieldDefinition(
        key: objectDescription,
        label: 'Object Description',
        hint: 'Detailed description of the object',
        icon: Icons.description,
        section: 'Object Details',
        previousFieldKey: objectCategory,
        nextFieldKey: objectBrand,
      ),
      FieldDefinition(
        key: objectBrand,
        label: 'Brand (Optional)',
        hint: 'e.g., BMW, Samsung',
        icon: Icons.branding_watermark,
        section: 'Object Details',
        previousFieldKey: objectDescription,
        nextFieldKey: objectModel,
      ),
      FieldDefinition(
        key: objectModel,
        label: 'Model (Optional)',
        hint: 'e.g., X5, Galaxy S23',
        icon: Icons.inventory,
        section: 'Object Details',
        previousFieldKey: objectBrand,
        nextFieldKey: objectSerialNumber,
      ),
      FieldDefinition(
        key: objectSerialNumber,
        label: 'Serial Number (Optional)',
        hint: 'Enter serial number if applicable',
        icon: Icons.qr_code,
        section: 'Object Details',
        previousFieldKey: objectModel,
        nextFieldKey: objectVIN,
      ),
      FieldDefinition(
        key: objectVIN,
        label: 'VIN (Optional)',
        hint: 'Vehicle Identification Number',
        icon: Icons.directions_car,
        maxLength: 17,
        section: 'Object Details',
        previousFieldKey: objectSerialNumber,
        nextFieldKey: objectYear,
      ),
      FieldDefinition(
        key: objectYear,
        label: 'Year (Optional)',
        hint: 'e.g., 2023',
        icon: Icons.calendar_today,
        keyboardType: TextInputType.number,
        isNumeric: true,
        maxLength: 4,
        section: 'Object Details',
        previousFieldKey: objectVIN,
        nextFieldKey: objectCondition,
      ),
      FieldDefinition(
        key: objectCondition,
        label: 'Condition',
        hint: 'e.g., New, Used, Refurbished',
        icon: Icons.check_circle,
        section: 'Object Details',
        previousFieldKey: objectYear,
        nextFieldKey: contractPrice,
      ),

      // Contract Details Section
      FieldDefinition(
        key: contractPrice,
        label: 'Contract Price',
        hint: 'Enter total price',
        icon: Icons.attach_money,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        isNumeric: true,
        section: 'Contract Details',
        previousFieldKey: objectCondition,
        nextFieldKey: contractCurrency,
      ),
      FieldDefinition(
        key: contractCurrency,
        label: 'Currency',
        hint: 'e.g., RON, EUR, USD',
        icon: Icons.currency_exchange,
        section: 'Contract Details',
        previousFieldKey: contractPrice,
        nextFieldKey: contractPaymentMethod,
      ),
      FieldDefinition(
        key: contractPaymentMethod,
        label: 'Payment Method',
        hint: 'e.g., Cash, Bank Transfer, Card',
        icon: Icons.payment,
        section: 'Contract Details',
        previousFieldKey: contractCurrency,
        nextFieldKey: contractDeliveryDate,
      ),
      FieldDefinition(
        key: contractDeliveryDate,
        label: 'Delivery Date',
        hint: 'When will delivery occur?',
        icon: Icons.date_range,
        section: 'Contract Details',
        previousFieldKey: contractPaymentMethod,
        nextFieldKey: contractLocation,
      ),
      FieldDefinition(
        key: contractLocation,
        label: 'Contract Location',
        hint: 'Where is the contract signed?',
        icon: Icons.place,
        section: 'Contract Details',
        previousFieldKey: contractDeliveryDate,
        nextFieldKey: contractTerms,
      ),
      FieldDefinition(
        key: contractTerms,
        label: 'Additional Terms (Optional)',
        hint: 'Any special terms or conditions',
        icon: Icons.article,
        section: 'Contract Details',
        previousFieldKey: contractLocation,
        nextFieldKey: contractWarranty,
      ),
      FieldDefinition(
        key: contractWarranty,
        label: 'Warranty (Optional)',
        hint: 'Warranty information',
        icon: Icons.verified_user,
        section: 'Contract Details',
        previousFieldKey: contractTerms,
      ),
    ];
  }

  /// Get a specific field by key
  static FieldDefinition? getField(String key) {
    try {
      return getAllFields().firstWhere((field) => field.key == key);
    } catch (e) {
      return null;
    }
  }

  /// Get the index of a field
  static int getFieldIndex(String key) {
    return getAllFields().indexWhere((field) => field.key == key);
  }

  /// Get the first field
  static FieldDefinition getFirstField() {
    return getAllFields().first;
  }

  /// Get the last field
  static FieldDefinition getLastField() {
    return getAllFields().last;
  }

  /// Check if a field is the first field
  static bool isFirstField(String key) {
    return key == getFirstField().key;
  }

  /// Check if a field is the last field
  static bool isLastField(String key) {
    return key == getLastField().key;
  }

  /// Get all fields in a section
  static List<FieldDefinition> getFieldsBySection(String section) {
    return getAllFields().where((field) => field.section == section).toList();
  }

  /// Get all unique sections
  static List<String> getAllSections() {
    return getAllFields()
        .map((field) => field.section)
        .toSet()
        .toList();
  }
}
