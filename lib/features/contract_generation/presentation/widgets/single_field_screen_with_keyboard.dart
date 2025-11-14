import 'package:flutter/material.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';
import '../../data/field_registry.dart';
import '../../data/contract_data_manager.dart';

/// Single field screen with always-on virtual keyboard and caps lock enabled
class SingleFieldScreenWithKeyboard extends StatefulWidget {
  final String fieldKey;
  final ContractDataManager dataManager;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onComplete;

  const SingleFieldScreenWithKeyboard({
    super.key,
    required this.fieldKey,
    required this.dataManager,
    this.onNext,
    this.onPrevious,
    this.onComplete,
  });

  @override
  State<SingleFieldScreenWithKeyboard> createState() => _SingleFieldScreenWithKeyboardState();
}

class _SingleFieldScreenWithKeyboardState extends State<SingleFieldScreenWithKeyboard> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  FieldDefinition? _field;
  String? _errorMessage;
  bool _hasInteracted = false;
  VirtualKeyboardType _keyboardType = VirtualKeyboardType.Alphanumeric;
  bool _isShiftEnabled = true; // Start with caps lock enabled

  @override
  void initState() {
    super.initState();

    // Get field definition
    _field = FieldRegistry.getField(widget.fieldKey);

    // Initialize controller with existing value
    final existingValue = widget.dataManager.getFieldAsString(widget.fieldKey);
    _controller = TextEditingController(text: existingValue);

    // Initialize focus node
    _focusNode = FocusNode();

    // Determine keyboard type
    if (_field != null) {
      _keyboardType = _field!.isNumeric
          ? VirtualKeyboardType.Numeric
          : VirtualKeyboardType.Alphanumeric;
    }

    // Auto-focus after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    // Add listener to mark field as interacted
    _controller.addListener(() {
      if (!_hasInteracted && _controller.text.isNotEmpty) {
        setState(() {
          _hasInteracted = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onKeyPress(VirtualKeyboardKey key) {
    // Handle special keys
    if (key.keyType == VirtualKeyboardKeyType.Action) {
      if (key.action == VirtualKeyboardKeyAction.Return) {
        _handleNext();
      } else if (key.action == VirtualKeyboardKeyAction.Shift) {
        setState(() {
          _isShiftEnabled = !_isShiftEnabled;
        });
      }
    }
  }

  void _validateAndSave() {
    final value = _controller.text.trim();

    // Validate
    final error = widget.dataManager.validateField(widget.fieldKey, value);

    setState(() {
      _errorMessage = error;
    });

    if (error == null) {
      // Save to data manager
      widget.dataManager.setField(widget.fieldKey, value);
      widget.dataManager.setCurrentField(widget.fieldKey);
    }
  }

  void _handleNext() {
    _validateAndSave();

    if (_errorMessage == null) {
      if (FieldRegistry.isLastField(widget.fieldKey)) {
        widget.onComplete?.call();
      } else {
        widget.onNext?.call();
      }
    }
  }

  void _handlePrevious() {
    // Save current value even if invalid
    final value = _controller.text.trim();
    if (value.isNotEmpty) {
      widget.dataManager.setField(widget.fieldKey, value);
    }

    widget.onPrevious?.call();
  }

  void _handleSkip() {
    // Only allow skip for optional fields
    if (_field?.label.contains('(Optional)') ?? false) {
      widget.dataManager.clearField(widget.fieldKey);
      _handleNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_field == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Field not found'),
        ),
      );
    }

    final isFirstField = FieldRegistry.isFirstField(widget.fieldKey);
    final isLastField = FieldRegistry.isLastField(widget.fieldKey);
    final isOptional = _field!.label.contains('(Optional)');
    final completionPercentage = widget.dataManager.getCompletionPercentage();
    final fieldIndex = FieldRegistry.getFieldIndex(widget.fieldKey) + 1;
    final totalFields = FieldRegistry.getAllFields().length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _field!.section,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Field $fieldIndex of $totalFields',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                '${completionPercentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: fieldIndex / totalFields,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),

          // Main content with text field
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Field icon
                  Icon(
                    _field!.icon,
                    size: 48,
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 16),

                  // Field label
                  Text(
                    _field!.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Field hint
                  Text(
                    _field!.hint,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Text field (read-only, controlled by virtual keyboard)
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    readOnly: true, // Prevent system keyboard
                    showCursor: true,
                    style: const TextStyle(fontSize: 18),
                    maxLines: _field!.keyboardType == TextInputType.multiline ? 3 : 1,
                    decoration: InputDecoration(
                      labelText: _field!.label,
                      hintText: _field!.hint,
                      prefixIcon: Icon(_field!.icon),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                      errorText: _errorMessage,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Optional field indicator
                  if (isOptional)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Optional field - you can skip if not applicable',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Navigation buttons
          _buildNavigationButtons(isFirstField, isLastField, isOptional),

          // Virtual keyboard - ALWAYS VISIBLE
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border(
                top: BorderSide(color: Colors.grey[400]!, width: 2),
              ),
            ),
            child: VirtualKeyboard(
              type: _keyboardType,
              textColor: Colors.black,
              fontSize: 20,
              height: 280,
              textController: _controller,
              defaultLayouts: _isShiftEnabled ? [VirtualKeyboardDefaultLayouts.English] : null,
              alwaysCaps: _isShiftEnabled,
              postKeyPress: _onKeyPress,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(bool isFirstField, bool isLastField, bool isOptional) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          // Previous Button
          if (!isFirstField)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _handlePrevious,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          if (!isFirstField) const SizedBox(width: 12),

          // Skip button for optional fields
          if (isOptional)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _handleSkip,
                icon: const Icon(Icons.skip_next),
                label: const Text('Skip'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: Colors.orange,
                ),
              ),
            ),
          if (isOptional) const SizedBox(width: 12),

          // Next/Complete Button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _handleNext,
              icon: Icon(isLastField ? Icons.check : Icons.arrow_forward),
              label: Text(isLastField ? 'Complete' : 'Next'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
