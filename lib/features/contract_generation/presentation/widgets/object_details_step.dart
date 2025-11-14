import 'package:flutter/material.dart';
import 'keyboard_text_field.dart';

class ObjectDetailsStep extends StatefulWidget {
  final String initialObjectDetails;
  final Function(String) onChanged;

  const ObjectDetailsStep({
    super.key,
    required this.initialObjectDetails,
    required this.onChanged,
  });

  @override
  State<ObjectDetailsStep> createState() => _ObjectDetailsStepState();
}

class _ObjectDetailsStepState extends State<ObjectDetailsStep> {
  late TextEditingController _objectDetailsController;

  @override
  void initState() {
    super.initState();
    _objectDetailsController = TextEditingController(
      text: widget.initialObjectDetails,
    );
    _objectDetailsController.addListener(_updateData);
  }

  @override
  void dispose() {
    _objectDetailsController.dispose();
    super.dispose();
  }

  void _updateData() {
    widget.onChanged(_objectDetailsController.text);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Object Details',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Provide detailed information about the object of the contract',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).primaryColor),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What to include',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Describe the item(s) or service(s) being sold/purchased. Include specifications, model numbers, serial numbers, condition, quantity, etc.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          KeyboardTextField(
            controller: _objectDetailsController,
            label: 'Object Details *',
            hint: 'Example: Used laptop, Dell Inspiron 15, Serial: ABC123456, good working condition...',
            icon: Icons.description,
            maxLines: 10,
          ),
        ],
      ),
    );
  }
}
