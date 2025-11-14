import 'package:flutter/material.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';
import 'field_navigation_controller.dart';

class VirtualKeyboardWrapper extends StatefulWidget {
  final Widget child;
  final FieldNavigationController? navigationController;

  const VirtualKeyboardWrapper({
    super.key,
    required this.child,
    this.navigationController,
  });

  @override
  State<VirtualKeyboardWrapper> createState() => VirtualKeyboardWrapperState();
}

class VirtualKeyboardWrapperState extends State<VirtualKeyboardWrapper> {
  bool _isKeyboardVisible = false;
  TextEditingController? _currentController;
  VirtualKeyboardType _keyboardType = VirtualKeyboardType.Alphanumeric;

  void showKeyboard(TextEditingController controller, {bool isNumeric = false}) {
    setState(() {
      _currentController = controller;
      _keyboardType = isNumeric
          ? VirtualKeyboardType.Numeric
          : VirtualKeyboardType.Alphanumeric;
      _isKeyboardVisible = true;
    });
  }

  void hideKeyboard() {
    setState(() {
      _isKeyboardVisible = false;
      _currentController = null;
    });
  }

  void _onKeyPress(VirtualKeyboardKey key) {
    if (_currentController == null) return;

    if (key.keyType == VirtualKeyboardKeyType.Action &&
        key.action == VirtualKeyboardKeyAction.Return) {
      _handleNext();
    }
  }

  void _handlePrevious() {
    if (widget.navigationController != null) {
      widget.navigationController!.previousField();
    }
  }

  void _handleNext() {
    if (widget.navigationController != null) {
      if (!widget.navigationController!.isLastField) {
        widget.navigationController!.nextField();
      } else {
        hideKeyboard();
      }
    } else {
      hideKeyboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: widget.child),
        if (_isKeyboardVisible)
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border(
                top: BorderSide(color: Colors.grey[400]!, width: 2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Keyboard header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.grey[300],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.keyboard, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            'Virtual Keyboard',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Previous field button
                          if (widget.navigationController != null)
                            IconButton(
                              onPressed: widget.navigationController!.isFirstField
                                  ? null
                                  : _handlePrevious,
                              icon: const Icon(Icons.arrow_back),
                              tooltip: 'Previous Field',
                              color: Theme.of(context).primaryColor,
                            ),
                          // Next field button
                          if (widget.navigationController != null)
                            ElevatedButton.icon(
                              onPressed: _handleNext,
                              icon: Icon(
                                widget.navigationController!.isLastField
                                    ? Icons.check
                                    : Icons.arrow_forward,
                              ),
                              label: Text(
                                widget.navigationController!.isLastField
                                    ? 'Done'
                                    : 'Next',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          const SizedBox(width: 8),
                          // Toggle keyboard type button
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _keyboardType = _keyboardType == VirtualKeyboardType.Alphanumeric
                                    ? VirtualKeyboardType.Numeric
                                    : VirtualKeyboardType.Alphanumeric;
                              });
                            },
                            icon: Icon(
                              _keyboardType == VirtualKeyboardType.Alphanumeric
                                  ? Icons.dialpad
                                  : Icons.keyboard,
                            ),
                            tooltip: _keyboardType == VirtualKeyboardType.Alphanumeric
                                ? 'Switch to Numeric'
                                : 'Switch to Alphanumeric',
                          ),
                          // Close keyboard button
                          IconButton(
                            onPressed: hideKeyboard,
                            icon: const Icon(Icons.keyboard_hide),
                            tooltip: 'Hide Keyboard',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Virtual keyboard
                Container(
                  color: Colors.grey[100],
                  padding: const EdgeInsets.all(8),
                  child: VirtualKeyboard(
                    type: _keyboardType,
                    textColor: Colors.black,
                    fontSize: 20,
                    height: 300,
                    textController: _currentController,
                    postKeyPress: _onKeyPress,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
