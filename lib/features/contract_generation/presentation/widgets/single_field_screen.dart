import 'package:flutter/material.dart';
import '../../data/field_registry.dart';
import '../../data/contract_data_manager.dart';
import 'virtual_keyboard_wrapper.dart';
import 'keyboard_text_field.dart';

/// Single field screen template - replicates Kivy's one-field-per-screen pattern
class SingleFieldScreen extends StatefulWidget {
  final String fieldKey;
  final ContractDataManager dataManager;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onComplete;

  const SingleFieldScreen({
    super.key,
    required this.fieldKey,
    required this.dataManager,
    this.onNext,
    this.onPrevious,
    this.onComplete,
  });

  @override
  State<SingleFieldScreen> createState() => _SingleFieldScreenState();
}

class _SingleFieldScreenState extends State<SingleFieldScreen> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  FieldDefinition? _field;
  String? _errorMessage;
  bool _hasInteracted = false;

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
      body: VirtualKeyboardWrapper(
        child: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: fieldIndex / totalFields,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Field icon
                    Icon(
                      _field!.icon,
                      size: 64,
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 24),

                    // Field label
                    Text(
                      _field!.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Field hint
                    Text(
                      _field!.hint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Text field
                    KeyboardTextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      label: _field!.label,
                      hint: _field!.hint,
                      icon: _field!.icon,
                      keyboardType: _field!.keyboardType,
                      maxLines: _field!.keyboardType == TextInputType.multiline ? 3 : 1,
                      autofocus: true,
                      inputFormatters: _field!.formatters,
                    ),

                    // Error message
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

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
                                'This field is optional. You can skip it if not applicable.',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Summary of previously entered data
                    if (widget.dataManager.getFieldsCountByStatus()['completed']! > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: _buildProgressSummary(),
                      ),
                  ],
                ),
              ),
            ),

            // Navigation buttons
            _buildNavigationFooter(isFirstField, isLastField, isOptional),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSummary() {
    final stats = widget.dataManager.getFieldsCountByStatus();
    final sections = FieldRegistry.getAllSections();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Your Progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${stats['completed']} of ${stats['total']} fields completed',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            ...sections.map((section) {
              final percentage = widget.dataManager.getSectionCompletionPercentage(section);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        section,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationFooter(bool isFirstField, bool isLastField, bool isOptional) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Skip button for optional fields
            if (isOptional)
              TextButton.icon(
                onPressed: _handleSkip,
                icon: const Icon(Icons.skip_next),
                label: const Text('Skip this field'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
              ),

            const SizedBox(height: 8),

            // Main navigation buttons
            Row(
              children: [
                // Previous Button
                if (!isFirstField)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _handlePrevious,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                if (!isFirstField) const SizedBox(width: 16),

                // Next/Complete Button
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _handleNext,
                    icon: Icon(isLastField ? Icons.check : Icons.arrow_forward),
                    label: Text(isLastField ? 'Complete' : 'Next Field'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
