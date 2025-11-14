import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'virtual_keyboard_wrapper.dart';

class KeyboardTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool readOnly;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;

  const KeyboardTextField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
    this.autofocus = false,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final keyboardWrapper = context.findAncestorStateOfType<VirtualKeyboardWrapperState>();
    final isNumeric = keyboardType == TextInputType.number ||
        keyboardType == const TextInputType.numberWithOptions(decimal: true) ||
        keyboardType == TextInputType.phone;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      autofocus: autofocus,
      inputFormatters: inputFormatters,
      onTap: () {
        // Show virtual keyboard when field is tapped
        if (keyboardWrapper != null) {
          keyboardWrapper.showKeyboard(controller, isNumeric: isNumeric);
        }
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
      ),
    );
  }
}
