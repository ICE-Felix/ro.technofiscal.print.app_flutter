import 'package:flutter/material.dart';
import '../../data/field_registry.dart';
import '../../data/contract_data_manager.dart';
import '../widgets/single_field_screen_with_keyboard.dart';
import '../widgets/entity_type_selection_screen.dart';
import 'package:go_router/go_router.dart';

/// Main page that orchestrates the single-field-per-screen flow
/// Similar to Kivy's ScreenManager
class SingleFieldFlowPage extends StatefulWidget {
  const SingleFieldFlowPage({super.key});

  @override
  State<SingleFieldFlowPage> createState() => _SingleFieldFlowPageState();
}

class _SingleFieldFlowPageState extends State<SingleFieldFlowPage> {
  ContractDataManager? _dataManager;
  String? _currentFieldKey;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeDataManager();
  }

  Future<void> _initializeDataManager() async {
    final dataManager = await ContractDataManager.create();

    setState(() {
      _dataManager = dataManager;
      _isLoading = false;

      // Resume from last field or start from beginning
      _currentFieldKey = dataManager.getCurrentField();

      if (_currentFieldKey == null) {
        // Start from first field
        _currentFieldKey = FieldRegistry.getFirstField().key;
      } else {
        // Check if the current field is actually incomplete
        final nextIncomplete = dataManager.getNextIncompleteField();
        if (nextIncomplete != null) {
          _currentFieldKey = nextIncomplete;
        }
      }
    });
  }

  void _handleNext() {
    if (_dataManager == null || _currentFieldKey == null) return;

    final currentField = FieldRegistry.getField(_currentFieldKey!);
    if (currentField == null) return;

    setState(() {
      _currentFieldKey = currentField.nextFieldKey;
    });
  }

  void _handlePrevious() {
    if (_dataManager == null || _currentFieldKey == null) return;

    final currentField = FieldRegistry.getField(_currentFieldKey!);
    if (currentField == null) return;

    setState(() {
      _currentFieldKey = currentField.previousFieldKey;
    });
  }

  void _handleComplete() {
    if (_dataManager == null) return;

    // Check if all required fields are filled
    if (!_dataManager!.isComplete()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.orange,
        ),
      );

      // Navigate to first incomplete field
      final nextIncomplete = _dataManager!.getNextIncompleteField();
      if (nextIncomplete != null) {
        setState(() {
          _currentFieldKey = nextIncomplete;
        });
      }
      return;
    }

    // Show summary dialog
    _showSummaryDialog();
  }

  void _showSummaryDialog() {
    final summaryBySection = _dataManager!.getSummaryBySection();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Contract Summary'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Please review the information before generating the contract:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...summaryBySection.entries.map((section) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.key,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...section.value.entries.map((field) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${field.key}:',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  field.value.toString(),
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Review Data'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _generateContract();
            },
            icon: const Icon(Icons.description),
            label: const Text('Generate Contract'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _generateContract() {
    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle,
          color: Colors.green[600],
          size: 64,
        ),
        title: const Text(
          'Contract Generated Successfully!',
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Your contract has been generated. You can now print it or save it for your records.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Clear data and return to home
              _dataManager?.clearAll();
              Navigator.of(context).pop();
              context.go('/');
            },
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement print functionality
              Navigator.of(context).pop();
              context.go('/');
            },
            icon: const Icon(Icons.print),
            label: const Text('Print Contract'),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldScreen() {
    // Check if this is an entity type field - use button selection screen
    if (_currentFieldKey == 'seller_entity_type' || _currentFieldKey == 'buyer_entity_type') {
      return EntityTypeSelectionScreen(
        key: ValueKey(_currentFieldKey),
        fieldKey: _currentFieldKey!,
        dataManager: _dataManager!,
        onNext: _handleNext,
        onPrevious: _handlePrevious,
      );
    }

    // For all other fields - use keyboard-enabled screen
    return SingleFieldScreenWithKeyboard(
      key: ValueKey(_currentFieldKey),
      fieldKey: _currentFieldKey!,
      dataManager: _dataManager!,
      onNext: _handleNext,
      onPrevious: _handlePrevious,
      onComplete: _handleComplete,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_dataManager == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Failed to initialize data manager'),
        ),
      );
    }

    if (_currentFieldKey == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('No current field'),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Show confirmation dialog before leaving
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Contract Generation?'),
            content: const Text(
              'Your progress has been saved. You can continue later from where you left off.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Continue'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );

        if (shouldPop == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: _buildFieldScreen(),
    );
  }
}
