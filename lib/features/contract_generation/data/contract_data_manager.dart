import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'field_registry.dart';
import 'models/contract_model.dart';
import 'models/party_model.dart';
import 'models/address_model.dart';

/// Manages contract data persistence using SharedPreferences
/// Similar to Kivy's DataManager but uses SharedPreferences instead of JSON files
class ContractDataManager {
  static const String _storageKey = 'contract_data';
  static const String _currentFieldKey = 'current_field';

  final SharedPreferences _prefs;
  Map<String, dynamic> _data = {};

  ContractDataManager(this._prefs) {
    _loadData();
  }

  /// Factory constructor to create instance with SharedPreferences
  static Future<ContractDataManager> create() async {
    final prefs = await SharedPreferences.getInstance();
    return ContractDataManager(prefs);
  }

  /// Load data from SharedPreferences
  void _loadData() {
    final jsonString = _prefs.getString(_storageKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        _data = Map<String, dynamic>.from(json.decode(jsonString));
      } catch (e) {
        _data = {};
      }
    }
  }

  /// Save data to SharedPreferences
  Future<void> _saveData() async {
    final jsonString = json.encode(_data);
    await _prefs.setString(_storageKey, jsonString);
  }

  /// Set a field value
  Future<void> setField(String key, dynamic value) async {
    _data[key] = value;
    await _saveData();
  }

  /// Get a field value
  dynamic getField(String key, {dynamic defaultValue}) {
    return _data[key] ?? defaultValue;
  }

  /// Get a field value as String
  String getFieldAsString(String key, {String defaultValue = ''}) {
    final value = _data[key];
    return value?.toString() ?? defaultValue;
  }

  /// Check if a field has a value
  bool hasField(String key) {
    return _data.containsKey(key) && _data[key] != null && _data[key].toString().isNotEmpty;
  }

  /// Clear a specific field
  Future<void> clearField(String key) async {
    _data.remove(key);
    await _saveData();
  }

  /// Clear all data
  Future<void> clearAll() async {
    _data.clear();
    await _prefs.remove(_storageKey);
    await _prefs.remove(_currentFieldKey);
  }

  /// Get all data as Map
  Map<String, dynamic> getAllData() {
    return Map<String, dynamic>.from(_data);
  }

  /// Set current field key (for resuming)
  Future<void> setCurrentField(String fieldKey) async {
    await _prefs.setString(_currentFieldKey, fieldKey);
  }

  /// Get current field key
  String? getCurrentField() {
    return _prefs.getString(_currentFieldKey);
  }

  /// Check if contract data is complete
  bool isComplete() {
    final allFields = FieldRegistry.getAllFields();

    // Check required fields (non-optional)
    for (final field in allFields) {
      // Skip optional fields (those with "(Optional)" in label)
      if (field.label.contains('(Optional)')) {
        continue;
      }

      if (!hasField(field.key)) {
        return false;
      }
    }

    return true;
  }

  /// Get completion percentage
  double getCompletionPercentage() {
    final allFields = FieldRegistry.getAllFields();
    final requiredFields = allFields.where((f) => !f.label.contains('(Optional)')).toList();

    if (requiredFields.isEmpty) return 0.0;

    int completedCount = 0;
    for (final field in requiredFields) {
      if (hasField(field.key)) {
        completedCount++;
      }
    }

    return (completedCount / requiredFields.length) * 100;
  }

  /// Get the next incomplete field
  String? getNextIncompleteField({String? afterFieldKey}) {
    final allFields = FieldRegistry.getAllFields();

    int startIndex = 0;
    if (afterFieldKey != null) {
      startIndex = FieldRegistry.getFieldIndex(afterFieldKey) + 1;
    }

    for (int i = startIndex; i < allFields.length; i++) {
      final field = allFields[i];

      // Skip optional fields if they have no value
      if (field.label.contains('(Optional)') && !hasField(field.key)) {
        continue;
      }

      if (!hasField(field.key)) {
        return field.key;
      }
    }

    return null;
  }

  /// Validate a specific field
  String? validateField(String fieldKey, String value) {
    final field = FieldRegistry.getField(fieldKey);
    if (field == null) return null;

    if (field.validator != null) {
      return field.validator!(value);
    }

    // Basic validation for required fields
    if (!field.label.contains('(Optional)') && value.trim().isEmpty) {
      return '${field.label} is required';
    }

    return null;
  }

  /// Export data as JSON string
  String exportAsJson() {
    return json.encode(_data);
  }

  /// Import data from JSON string
  Future<void> importFromJson(String jsonString) async {
    try {
      _data = Map<String, dynamic>.from(json.decode(jsonString));
      await _saveData();
    } catch (e) {
      throw Exception('Invalid JSON data');
    }
  }

  /// Get summary by section
  Map<String, Map<String, dynamic>> getSummaryBySection() {
    final summary = <String, Map<String, dynamic>>{};
    final sections = FieldRegistry.getAllSections();

    for (final section in sections) {
      final fields = FieldRegistry.getFieldsBySection(section);
      final sectionData = <String, dynamic>{};

      for (final field in fields) {
        if (hasField(field.key)) {
          sectionData[field.label] = getField(field.key);
        }
      }

      if (sectionData.isNotEmpty) {
        summary[section] = sectionData;
      }
    }

    return summary;
  }

  /// Check if a section is complete
  bool isSectionComplete(String section) {
    final fields = FieldRegistry.getFieldsBySection(section);

    for (final field in fields) {
      // Skip optional fields
      if (field.label.contains('(Optional)')) {
        continue;
      }

      if (!hasField(field.key)) {
        return false;
      }
    }

    return true;
  }

  /// Get section completion percentage
  double getSectionCompletionPercentage(String section) {
    final fields = FieldRegistry.getFieldsBySection(section);
    final requiredFields = fields.where((f) => !f.label.contains('(Optional)')).toList();

    if (requiredFields.isEmpty) return 100.0;

    int completedCount = 0;
    for (final field in requiredFields) {
      if (hasField(field.key)) {
        completedCount++;
      }
    }

    return (completedCount / requiredFields.length) * 100;
  }

  /// Get fields count by status
  Map<String, int> getFieldsCountByStatus() {
    final allFields = FieldRegistry.getAllFields();
    int total = allFields.length;
    int completed = 0;
    int required = 0;
    int optional = 0;

    for (final field in allFields) {
      if (field.label.contains('(Optional)')) {
        optional++;
      } else {
        required++;
      }

      if (hasField(field.key)) {
        completed++;
      }
    }

    return {
      'total': total,
      'completed': completed,
      'remaining': total - completed,
      'required': required,
      'optional': optional,
    };
  }

  /// Create a snapshot of current data (for undo functionality)
  Map<String, dynamic> createSnapshot() {
    return Map<String, dynamic>.from(_data);
  }

  /// Restore from a snapshot
  Future<void> restoreFromSnapshot(Map<String, dynamic> snapshot) async {
    _data = Map<String, dynamic>.from(snapshot);
    await _saveData();
  }

  /// Build ContractModel from stored data
  ContractModel toContractModel() {
    // Helper function to parse EntityType
    EntityType parseEntityType(String? value) {
      if (value == null || value.isEmpty) return EntityType.individual;
      if (value.toLowerCase().contains('company') || value.toLowerCase().contains('juridică')) {
        return EntityType.company;
      }
      return EntityType.individual;
    }

    // Build seller address
    final sellerAddress = AddressModel(
      country: getFieldAsString('seller_country', defaultValue: 'Romania'),
      county: getFieldAsString('seller_county'),
      city: getFieldAsString('seller_city'),
      postalCode: getFieldAsString('seller_postal_code'),
      street: getFieldAsString('seller_street'),
      streetNumber: getFieldAsString('seller_street_number'),
    );

    // Build seller party
    final seller = PartyModel(
      entityType: parseEntityType(getFieldAsString('seller_entity_type')),
      fullName: getFieldAsString('seller_full_name'),
      cnp: getFieldAsString('seller_cnp'),
      idSeries: getFieldAsString('seller_id_series'),
      idNumber: getFieldAsString('seller_id_number'),
      address: sellerAddress,
      phone: getFieldAsString('seller_phone'),
      email: getFieldAsString('seller_email'),
    );

    // Build buyer address
    final buyerAddress = AddressModel(
      country: getFieldAsString('buyer_country', defaultValue: 'Romania'),
      county: getFieldAsString('buyer_county'),
      city: getFieldAsString('buyer_city'),
      postalCode: getFieldAsString('buyer_postal_code'),
      street: getFieldAsString('buyer_street'),
      streetNumber: getFieldAsString('buyer_street_number'),
    );

    // Build buyer party
    final buyer = PartyModel(
      entityType: parseEntityType(getFieldAsString('buyer_entity_type')),
      fullName: getFieldAsString('buyer_full_name'),
      cnp: getFieldAsString('buyer_cnp'),
      idSeries: getFieldAsString('buyer_id_series'),
      idNumber: getFieldAsString('buyer_id_number'),
      address: buyerAddress,
      phone: getFieldAsString('buyer_phone'),
      email: getFieldAsString('buyer_email'),
    );

    // Build object details string
    final objectDetails = _buildObjectDetails();

    // Build contract details string
    final contractDetails = _buildContractDetails();

    // Parse price
    final priceString = getFieldAsString('contract_price');
    final price = double.tryParse(priceString.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;

    return ContractModel(
      seller: seller,
      buyer: buyer,
      objectDetails: objectDetails,
      contractDetails: contractDetails,
      price: price,
      createdAt: DateTime.now(),
      isComplete: isComplete(),
    );
  }

  /// Build object details string from fields
  String _buildObjectDetails() {
    final parts = <String>[];

    final category = getFieldAsString('object_category');
    if (category.isNotEmpty) parts.add('Category: $category');

    final description = getFieldAsString('object_description');
    if (description.isNotEmpty) parts.add(description);

    final brand = getFieldAsString('object_brand');
    final model = getFieldAsString('object_model');
    if (brand.isNotEmpty || model.isNotEmpty) {
      parts.add('${brand.isNotEmpty ? brand : ''} ${model.isNotEmpty ? model : ''}'.trim());
    }

    final year = getFieldAsString('object_year');
    if (year.isNotEmpty) parts.add('Year: $year');

    final vin = getFieldAsString('object_vin');
    if (vin.isNotEmpty) parts.add('VIN: $vin');

    final serialNumber = getFieldAsString('object_serial_number');
    if (serialNumber.isNotEmpty) parts.add('Serial Number: $serialNumber');

    final condition = getFieldAsString('object_condition');
    if (condition.isNotEmpty) parts.add('Condition: $condition');

    return parts.join('\n');
  }

  /// Build contract details string from fields
  String _buildContractDetails() {
    final parts = <String>[];

    final paymentMethod = getFieldAsString('contract_payment_method');
    if (paymentMethod.isNotEmpty) parts.add('Payment Method: $paymentMethod');

    final deliveryDate = getFieldAsString('contract_delivery_date');
    if (deliveryDate.isNotEmpty) parts.add('Delivery Date: $deliveryDate');

    final location = getFieldAsString('contract_location');
    if (location.isNotEmpty) parts.add('Location: $location');

    final additionalTerms = getFieldAsString('contract_additional_terms');
    if (additionalTerms.isNotEmpty) parts.add('Additional Terms: $additionalTerms');

    final warranty = getFieldAsString('contract_warranty');
    if (warranty.isNotEmpty) parts.add('Warranty: $warranty');

    return parts.join('\n');
  }
}
