import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'keyboard_text_field.dart';

class ContractDetailsStep extends StatefulWidget {
  final String initialContractDetails;
  final double initialPrice;
  final Function(String contractDetails, double price) onChanged;

  const ContractDetailsStep({
    super.key,
    required this.initialContractDetails,
    required this.initialPrice,
    required this.onChanged,
  });

  @override
  State<ContractDetailsStep> createState() => _ContractDetailsStepState();
}

class _ContractDetailsStepState extends State<ContractDetailsStep> {
  late TextEditingController _contractDetailsController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _contractDetailsController = TextEditingController(
      text: widget.initialContractDetails,
    );
    _priceController = TextEditingController(
      text: widget.initialPrice > 0 ? widget.initialPrice.toStringAsFixed(2) : '',
    );
    _contractDetailsController.addListener(_updateData);
    _priceController.addListener(_updateData);
  }

  @override
  void dispose() {
    _contractDetailsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _updateData() {
    final price = double.tryParse(_priceController.text) ?? 0.0;
    widget.onChanged(_contractDetailsController.text, price);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contract Details',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Specify the terms and conditions of the contract',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 32),
          KeyboardTextField(
            controller: _priceController,
            label: 'Sale Price (RON) *',
            hint: 'Enter price',
            icon: Icons.attach_money,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
          const SizedBox(height: 24),
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
                        'Additional Terms',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Include payment terms, delivery conditions, warranties, or any other specific agreements between parties.',
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
            controller: _contractDetailsController,
            label: 'Contract Terms & Conditions *',
            hint: 'Example: Payment in full upon delivery. Buyer has 7 days for inspection...',
            icon: Icons.article,
            maxLines: 8,
          ),
        ],
      ),
    );
  }
}
