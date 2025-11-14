import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'field_registry.dart';

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
}
