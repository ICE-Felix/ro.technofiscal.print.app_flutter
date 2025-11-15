import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/fiscal_printer_service.dart';
import '../../../../core/widgets/fiscal_receipt_widget.dart';
import '../../../../core/style/app_colors.dart';

/// Fiscal printer management page
class FiscalPrinterPage extends StatefulWidget {
  const FiscalPrinterPage({super.key});

  @override
  State<FiscalPrinterPage> createState() => _FiscalPrinterPageState();
}

class _FiscalPrinterPageState extends State<FiscalPrinterPage> {
  final _fiscalService = MockFiscalPrinterService();
  FiscalPrinterStatus _status = FiscalPrinterStatus.ready;
  bool _fiscalDayOpen = true;
  List<FiscalReceipt> _todayReceipts = [];
  Map<String, dynamic>? _fiscalMemoryInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final status = await _fiscalService.getStatus();
      final dayOpen = await _fiscalService.isFiscalDayOpen();
      final memoryInfo = await _fiscalService.getFiscalMemoryInfo();
      final receipts = _fiscalService.getTodayReceipts();

      setState(() {
        _status = status;
        _fiscalDayOpen = dayOpen;
        _fiscalMemoryInfo = memoryInfo;
        _todayReceipts = receipts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _openFiscalDay() async {
    try {
      await _fiscalService.openFiscalDay();
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ziua fiscală deschisă'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _closeFiscalDay() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Închide Ziua Fiscală?'),
        content: const Text(
          'Această acțiune va genera Raportul Z și va închide ziua fiscală. '
          'Nu mai puteți emite bonuri fiscale până când nu deschideți o nouă zi fiscală.\n\n'
          'Continuați?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Anulează'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kioskRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Închide Ziua'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final report = await _fiscalService.closeFiscalDay();
      await _loadData();

      if (mounted) {
        _showZReport(report);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _printTestReceipt() async {
    if (!_fiscalDayOpen) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ziua fiscală este închisă'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    try {
      final testReceipt = FiscalReceipt(
        receiptNumber: '', // Will be generated
        fiscalCode: '',
        fiscalMemoryNumber: '',
        dateTime: DateTime.now(),
        type: ReceiptType.sale,
        items: const [
          FiscalReceiptItem(
            name: 'Contract Vânzare-Cumpărare Autovehicul',
            quantity: 1,
            unitPrice: 50.0,
            vatRate: VATRate.standard,
            code: 'SRV001',
          ),
        ],
        paymentMethod: FiscalPaymentMethod.cash,
      );

      final receiptNumber = await _fiscalService.printFiscalReceipt(testReceipt);
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bon fiscal test tipărit: $receiptNumber'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _getDailyReport() async {
    try {
      final report = await _fiscalService.getDailyReport();

      if (mounted) {
        _showXReport(report);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showZReport(FiscalDailyReport report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.summarize, color: AppColors.kioskRed),
            const SizedBox(width: 12),
            const Text('Raport Z - Închidere Zi Fiscală'),
          ],
        ),
        content: _buildReportContent(report, isZReport: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Închide'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              // In real implementation, would print the report
            },
            icon: const Icon(Icons.print),
            label: const Text('Tipărește'),
          ),
        ],
      ),
    );
  }

  void _showXReport(FiscalDailyReport report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.summarize, color: AppColors.kioskBlue),
            const SizedBox(width: 12),
            const Text('Raport X - Situație Curentă'),
          ],
        ),
        content: _buildReportContent(report, isZReport: false),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Închide'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              // In real implementation, would print the report
            },
            icon: const Icon(Icons.print),
            label: const Text('Tipărește'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(FiscalDailyReport report, {required bool isZReport}) {
    final currencyFormat = NumberFormat.currency(locale: 'ro_RO', symbol: 'RON');

    return SizedBox(
      width: 500,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildReportRow('Nr. Raport:', report.reportNumber),
            _buildReportRow(
              'Data:',
              DateFormat('dd.MM.yyyy HH:mm').format(report.date),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildReportRow('Nr. Bonuri:', report.numberOfReceipts.toString()),
            _buildReportRow('Vânzări Totale:', currencyFormat.format(report.totalSales)),
            _buildReportRow('Returnări:', currencyFormat.format(report.totalRefunds)),
            _buildReportRow(
              'Venit Net:',
              currencyFormat.format(report.netRevenue),
              valueColor: AppColors.success,
            ),
            const SizedBox(height: 16),
            const Text(
              'TVA pe Cote:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...report.vatByRate.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: _buildReportRow(
                  '${entry.key.percentage.toStringAsFixed(0)}%:',
                  currencyFormat.format(entry.value),
                ),
              );
            }),
            const SizedBox(height: 16),
            const Text(
              'Plăți pe Metode:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...report.paymentsByMethod.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: _buildReportRow(
                  _getPaymentMethodName(entry.key),
                  currencyFormat.format(entry.value),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildReportRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodName(FiscalPaymentMethod method) {
    switch (method) {
      case FiscalPaymentMethod.cash:
        return 'Numerar:';
      case FiscalPaymentMethod.card:
        return 'Card:';
      case FiscalPaymentMethod.transfer:
        return 'Transfer:';
      case FiscalPaymentMethod.voucher:
        return 'Voucher:';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Imprimantă Fiscală'),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reîmprospătează',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // Left panel - Status and controls
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Printer status
                  FiscalPrinterStatusWidget(
                    status: _status,
                    fiscalDayOpen: _fiscalDayOpen,
                    onOpenDay: _openFiscalDay,
                    onCloseDay: _closeFiscalDay,
                  ),
                  const SizedBox(height: 24),

                  // Fiscal memory info
                  _buildFiscalMemoryCard(),
                  const SizedBox(height: 24),

                  // Actions
                  _buildActionsCard(),
                ],
              ),
            ),
          ),

          // Divider
          Container(
            width: 1,
            color: AppColors.border,
          ),

          // Right panel - Today's receipts
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  color: AppColors.gray50,
                  child: const Row(
                    children: [
                      Icon(Icons.receipt_long, color: AppColors.kioskBlue),
                      SizedBox(width: 12),
                      Text(
                        'Bonuri Fiscale Astăzi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _todayReceipts.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.receipt_outlined,
                                size: 64,
                                color: AppColors.gray400,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Niciun bon fiscal astăzi',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _todayReceipts.length,
                          itemBuilder: (context, index) {
                            final receipt = _todayReceipts[index];
                            return _buildReceiptListItem(receipt);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiscalMemoryCard() {
    if (_fiscalMemoryInfo == null) {
      return const SizedBox.shrink();
    }

    final percentage = double.tryParse(
          _fiscalMemoryInfo!['fiscalMemoryPercentage'].toString(),
        ) ??
        0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.storage, color: AppColors.kioskBlue),
                SizedBox(width: 12),
                Text(
                  'Memorie Fiscală',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Nr. Mem. Fiscală:', _fiscalMemoryInfo!['fiscalMemoryNumber']),
            _buildInfoRow('CIF:', _fiscalMemoryInfo!['fiscalCode']),
            _buildInfoRow('Total Bonuri:', _fiscalMemoryInfo!['totalReceipts'].toString()),
            const SizedBox(height: 12),
            Text(
              'Utilizare: ${percentage.toStringAsFixed(2)}%',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.gray200,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 90 ? AppColors.error : AppColors.success,
              ),
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.settings, color: AppColors.kioskBlue),
                SizedBox(width: 12),
                Text(
                  'Acțiuni',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _printTestReceipt,
                icon: const Icon(Icons.receipt),
                label: const Text('Bon Fiscal Test'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _getDailyReport,
                icon: const Icon(Icons.summarize),
                label: const Text('Raport X (Situație)'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptListItem(FiscalReceipt receipt) {
    final currencyFormat = NumberFormat.currency(locale: 'ro_RO', symbol: 'RON');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.receipt, color: AppColors.kioskBlue),
        title: Text(
          receipt.receiptNumber,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
        subtitle: Text(
          DateFormat('HH:mm:ss').format(receipt.dateTime),
        ),
        trailing: Text(
          currencyFormat.format(receipt.grossTotal),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.success,
          ),
        ),
        onTap: () => _showReceiptDetails(receipt),
      ),
    );
  }

  void _showReceiptDetails(FiscalReceipt receipt) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                    const Icon(Icons.receipt, color: Colors.white, size: 28),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Bon Fiscal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: FiscalReceiptPreview(receipt: receipt),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
