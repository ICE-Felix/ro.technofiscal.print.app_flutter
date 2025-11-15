import 'package:flutter/material.dart';
import '../../../../core/services/printer_service.dart';
import '../../../../core/widgets/printer_status_widget.dart';
import '../../../../core/style/app_colors.dart';

/// Printer settings and management page
class PrinterSettingsPage extends StatefulWidget {
  const PrinterSettingsPage({super.key});

  @override
  State<PrinterSettingsPage> createState() => _PrinterSettingsPageState();
}

class _PrinterSettingsPageState extends State<PrinterSettingsPage> {
  final _printerService = MockPrinterService();
  List<PrinterInfo> _printers = [];
  List<PrintJob> _printQueue = [];
  PrinterInfo? _defaultPrinter;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrinters();
    _loadPrintQueue();
  }

  Future<void> _loadPrinters() async {
    setState(() => _isLoading = true);

    try {
      final printers = await _printerService.getAvailablePrinters();
      final defaultPrinter = await _printerService.getDefaultPrinter();

      setState(() {
        _printers = printers;
        _defaultPrinter = defaultPrinter;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading printers: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _loadPrintQueue() {
    setState(() {
      _printQueue = _printerService.getPrintQueue();
    });

    // Auto-refresh every 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _loadPrintQueue();
      }
    });
  }

  Future<void> _setDefaultPrinter(String printerId) async {
    await _printerService.setDefaultPrinter(printerId);
    await _loadPrinters();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Default printer updated'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _testPrint(String printerId) async {
    try {
      await _printerService.testPrint(printerId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test print submitted'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test print failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _cancelJob(String jobId) {
    _printerService.cancelPrintJob(jobId);
    _loadPrintQueue();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Print job cancelled'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  void _clearCompleted() {
    _printerService.clearCompletedJobs();
    _loadPrintQueue();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Completed jobs cleared'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Printer Settings'),
        actions: [
          IconButton(
            onPressed: _loadPrinters,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Left panel - Printers
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        color: AppColors.gray50,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.print,
                              size: 32,
                              color: AppColors.kioskBlue,
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Available Printers',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${_printers.length} printer${_printers.length == 1 ? '' : 's'} found',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          itemCount: _printers.length,
                          itemBuilder: (context, index) {
                            final printer = _printers[index];
                            return PrinterStatusWidget(
                              printer: printer,
                              onTap: () => _showPrinterDetails(printer),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(
                  width: 1,
                  color: AppColors.border,
                ),

                // Right panel - Print queue
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        color: AppColors.gray50,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.queue,
                              size: 28,
                              color: AppColors.kioskBlue,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Print Queue',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            if (_printQueue.isNotEmpty)
                              TextButton.icon(
                                onPressed: _clearCompleted,
                                icon: const Icon(Icons.clear_all, size: 18),
                                label: const Text('Clear'),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: PrintQueueWidget(
                          queue: _printQueue,
                          onCancelJob: _cancelJob,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _showPrinterDetails(PrinterInfo printer) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.kioskBlue,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.print,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            printer.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            printer.model,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Status', _getStatusText(printer.status)),
                    _buildDetailRow('Paper Level', '${printer.paperLevel}%'),
                    _buildDetailRow('Ink Level', '${printer.inkLevel}%'),
                    if (printer.ipAddress != null)
                      _buildDetailRow('IP Address', printer.ipAddress!),
                    const SizedBox(height: 24),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _testPrint(printer.id);
                            },
                            icon: const Icon(Icons.print),
                            label: const Text('Test Print'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: printer.isDefault
                                ? null
                                : () {
                                    Navigator.of(context).pop();
                                    _setDefaultPrinter(printer.id);
                                  },
                            icon: const Icon(Icons.check_circle),
                            label: Text(
                              printer.isDefault
                                  ? 'Default'
                                  : 'Set Default',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.kioskBlue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(PrinterStatus status) {
    switch (status) {
      case PrinterStatus.ready:
        return 'Ready';
      case PrinterStatus.printing:
        return 'Printing...';
      case PrinterStatus.offline:
        return 'Offline';
      case PrinterStatus.error:
        return 'Error';
      case PrinterStatus.outOfPaper:
        return 'Out of Paper';
      case PrinterStatus.paperJam:
        return 'Paper Jam';
      case PrinterStatus.lowInk:
        return 'Low Ink';
      default:
        return 'Unknown';
    }
  }
}
