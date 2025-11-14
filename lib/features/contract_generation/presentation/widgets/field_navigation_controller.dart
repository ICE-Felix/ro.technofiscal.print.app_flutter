import 'package:flutter/material.dart';

/// Controller to manage field-by-field navigation in forms
class FieldNavigationController {
  final List<FocusNode> _focusNodes = [];
  final List<TextEditingController> _controllers = [];
  int _currentFieldIndex = 0;

  int get currentFieldIndex => _currentFieldIndex;
  int get totalFields => _focusNodes.length;
  bool get isFirstField => _currentFieldIndex == 0;
  bool get isLastField => _currentFieldIndex >= _focusNodes.length - 1;

  /// Register a field with its focus node and controller
  void registerField(FocusNode focusNode, TextEditingController controller) {
    _focusNodes.add(focusNode);
    _controllers.add(controller);
  }

  /// Focus the first field
  void focusFirstField() {
    if (_focusNodes.isNotEmpty) {
      _currentFieldIndex = 0;
      _focusNodes[0].requestFocus();
    }
  }

  /// Move to the next field
  void nextField() {
    if (_currentFieldIndex < _focusNodes.length - 1) {
      _currentFieldIndex++;
      _focusNodes[_currentFieldIndex].requestFocus();
    }
  }

  /// Move to the previous field
  void previousField() {
    if (_currentFieldIndex > 0) {
      _currentFieldIndex--;
      _focusNodes[_currentFieldIndex].requestFocus();
    }
  }

  /// Focus a specific field by index
  void focusField(int index) {
    if (index >= 0 && index < _focusNodes.length) {
      _currentFieldIndex = index;
      _focusNodes[index].requestFocus();
    }
  }

  /// Get the current field's controller
  TextEditingController? get currentController {
    if (_currentFieldIndex >= 0 && _currentFieldIndex < _controllers.length) {
      return _controllers[_currentFieldIndex];
    }
    return null;
  }

  /// Clear all fields
  void clearAll() {
    for (var controller in _controllers) {
      controller.clear();
    }
  }

  /// Unfocus all fields
  void unfocusAll() {
    for (var node in _focusNodes) {
      node.unfocus();
    }
  }

  /// Get field index from focus node
  int getFieldIndex(FocusNode node) {
    return _focusNodes.indexOf(node);
  }

  /// Add listener to track current focused field
  void addFocusListeners(Function(int index) onFieldFocused) {
    for (int i = 0; i < _focusNodes.length; i++) {
      final index = i;
      _focusNodes[i].addListener(() {
        if (_focusNodes[index].hasFocus) {
          _currentFieldIndex = index;
          onFieldFocused(index);
        }
      });
    }
  }

  /// Dispose all resources
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    _focusNodes.clear();
    _controllers.clear();
  }
}
