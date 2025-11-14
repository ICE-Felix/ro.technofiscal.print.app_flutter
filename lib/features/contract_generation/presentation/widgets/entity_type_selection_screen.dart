import 'package:flutter/material.dart';
import '../../data/contract_data_manager.dart';

/// Special screen for entity type selection (first step)
/// Uses large buttons instead of text input
class EntityTypeSelectionScreen extends StatelessWidget {
  final String fieldKey; // 'seller_entity_type' or 'buyer_entity_type'
  final ContractDataManager dataManager;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const EntityTypeSelectionScreen({
    super.key,
    required this.fieldKey,
    required this.dataManager,
    this.onNext,
    this.onPrevious,
  });

  String get _title {
    return fieldKey.startsWith('seller') ? 'Seller Information' : 'Buyer Information';
  }

  String get _subtitle {
    return 'Please select the entity type';
  }

  void _handleSelection(BuildContext context, String entityType) {
    // Save selection
    dataManager.setField(fieldKey, entityType);
    dataManager.setCurrentField(fieldKey);

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          entityType == 'individual'
              ? 'Selected: Individual Person'
              : 'Selected: Company/Legal Entity',
        ),
        duration: const Duration(milliseconds: 800),
        backgroundColor: Colors.green,
      ),
    );

    // Move to next field after short delay
    Future.delayed(const Duration(milliseconds: 900), () {
      onNext?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFirstField = fieldKey == 'seller_entity_type';
    final completionPercentage = dataManager.getCompletionPercentage();
    final existingValue = dataManager.getFieldAsString(fieldKey);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Entity Type Selection',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
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
            value: completionPercentage / 100,
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
                  // Icon
                  Icon(
                    Icons.business_center,
                    size: 80,
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    _subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Choose whether this is an individual person or a company/legal entity',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Individual Button
                  _EntityTypeButton(
                    icon: Icons.person,
                    title: 'Individual Person',
                    subtitle: 'For personal transactions',
                    isSelected: existingValue == 'individual',
                    color: Colors.blue,
                    onTap: () => _handleSelection(context, 'individual'),
                  ),

                  const SizedBox(height: 24),

                  // Company Button
                  _EntityTypeButton(
                    icon: Icons.business,
                    title: 'Company / Legal Entity',
                    subtitle: 'For business transactions',
                    isSelected: existingValue == 'company',
                    color: Colors.green,
                    onTap: () => _handleSelection(context, 'company'),
                  ),

                  const SizedBox(height: 32),

                  // Info box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This selection will determine which documents and information are required',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 14,
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

          // Navigation buttons (only show if coming back)
          if (!isFirstField || existingValue.isNotEmpty)
            Container(
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
                child: Row(
                  children: [
                    if (!isFirstField)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onPrevious,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Previous'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EntityTypeButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _EntityTypeButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : Colors.grey[300]!,
              width: isSelected ? 3 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? color : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: color,
                  size: 32,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
