import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/payment_terminal_service.dart';
import '../../../../core/widgets/payment_terminal_widget.dart';
import '../../../../core/style/app_colors.dart';

/// Payment Terminal Management Page
class PaymentTerminalPage extends StatefulWidget {
  const PaymentTerminalPage({super.key});

  @override
  State<PaymentTerminalPage> createState() => _PaymentTerminalPageState();
}

class _PaymentTerminalPageState extends State<PaymentTerminalPage> {
  final _paymentService = MockPaymentTerminalService();
  PaymentTerminalStatus _status = PaymentTerminalStatus.ready;
  List<PaymentTransaction> _transactions = [];
  Map<String, dynamic> _dailyTotals = {};
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    final status = await _paymentService.getStatus();
    final transactions = _paymentService.getTransactionHistory();
    final totals = await _paymentService.getDailyTotals();

    if (mounted) {
      setState(() {
        _status = status;
        _transactions = transactions;
        _dailyTotals = totals;
      });
    }
  }

  Future<void> _testCardPayment() async {
    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _CardPaymentDialog(
          onProcess: (amount) async {
            final transaction = await _paymentService.processCardPayment(
              amount: amount,
              allowContactless: true,
            );
            return transaction;
          },
        ),
      );
      await _loadData();
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

  Future<void> _testCashPayment() async {
    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _CashPaymentDialog(
          onProcess: (amount, cashReceived) async {
            final transaction = await _paymentService.processCashPayment(
              amount: amount,
              cashReceived: cashReceived,
            );
            return transaction;
          },
        ),
      );
      await _loadData();
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

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Șterge Istoric'),
        content: const Text('Sigur doriți să ștergeți istoricul tranzacțiilor?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anulează'),
          ),
          ElevatedButton(
            onPressed: () {
              _paymentService.clearHistory();
              Navigator.pop(context);
              _loadData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Șterge'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terminal de Plată'),
        backgroundColor: AppColors.kioskBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Reîmprospătare',
          ),
        ],
      ),
      body: Row(
        children: [
          // Left panel - Status and totals
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PaymentTerminalStatusWidget(
                    status: _status,
                    onTestCard: _testCardPayment,
                    onTestCash: _testCashPayment,
                  ),
                  const SizedBox(height: 16),
                  if (_dailyTotals.isNotEmpty)
                    DailyTotalsWidget(totals: _dailyTotals),
                  const SizedBox(height: 16),
                  _buildQuickActionsCard(),
                ],
              ),
            ),
          ),

          const VerticalDivider(width: 1),

          // Right panel - Transaction history
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: TransactionListWidget(
                transactions: _transactions,
                onClearHistory: _clearHistory,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Acțiuni Rapide',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => _DailyReportDialog(totals: _dailyTotals),
                );
              },
              icon: const Icon(Icons.assessment),
              label: const Text('Raport Zilnic'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kioskPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                _paymentService.reset();
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Terminal resetat cu succes'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              icon: const Icon(Icons.restore),
              label: const Text('Resetare Terminal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gray500,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card payment dialog
class _CardPaymentDialog extends StatefulWidget {
  final Future<PaymentTransaction> Function(double amount) onProcess;

  const _CardPaymentDialog({required this.onProcess});

  @override
  State<_CardPaymentDialog> createState() => _CardPaymentDialogState();
}

class _CardPaymentDialogState extends State<_CardPaymentDialog> {
  final _amountController = TextEditingController(text: '50.00');
  bool _processing = false;
  PaymentTransaction? _result;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _process() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sumă invalidă')),
      );
      return;
    }

    setState(() => _processing = true);

    try {
      final transaction = await widget.onProcess(amount);
      setState(() {
        _result = transaction;
        _processing = false;
      });
    } catch (e) {
      setState(() => _processing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eroare: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_result != null) {
      return _buildResultDialog(_result!);
    }

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.credit_card, color: AppColors.kioskBlue),
          SizedBox(width: 8),
          Text('Plată cu Card'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Sumă (RON)',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              enabled: !_processing,
            ),
            if (_processing) ...[
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              const Text('Procesare plată...'),
              const Text(
                'Vă rugăm să introduceți cardul',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _processing ? null : () => Navigator.pop(context),
          child: const Text('Anulează'),
        ),
        ElevatedButton(
          onPressed: _processing ? null : _process,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.kioskBlue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Procesează'),
        ),
      ],
    );
  }

  Widget _buildResultDialog(PaymentTransaction transaction) {
    final isSuccess = transaction.status == TransactionStatus.approved;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 8),
          Text(isSuccess ? 'Plată Aprobată' : 'Plată Refuzată'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('ID Tranzacție:', transaction.transactionId),
            _buildInfoRow('Sumă:', transaction.formattedAmount),
            if (transaction.cardLastFourDigits != null)
              _buildInfoRow('Card:', '**** ${transaction.cardLastFourDigits}'),
            if (transaction.cardType != null)
              _buildInfoRow(
                'Tip:',
                transaction.cardType == CardType.contactless
                    ? 'Contactless'
                    : 'CHIP & PIN',
              ),
            if (transaction.authorizationCode != null)
              _buildInfoRow('Cod Autorizare:', transaction.authorizationCode!),
            if (transaction.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  transaction.errorMessage!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSuccess ? AppColors.success : AppColors.error,
            foregroundColor: Colors.white,
          ),
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

/// Cash payment dialog
class _CashPaymentDialog extends StatefulWidget {
  final Future<PaymentTransaction> Function(double amount, double cashReceived)
      onProcess;

  const _CashPaymentDialog({required this.onProcess});

  @override
  State<_CashPaymentDialog> createState() => _CashPaymentDialogState();
}

class _CashPaymentDialogState extends State<_CashPaymentDialog> {
  final _amountController = TextEditingController(text: '50.00');
  final _receivedController = TextEditingController(text: '100.00');
  bool _processing = false;
  PaymentTransaction? _result;

  @override
  void dispose() {
    _amountController.dispose();
    _receivedController.dispose();
    super.dispose();
  }

  double get _change {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final received = double.tryParse(_receivedController.text) ?? 0;
    return received - amount;
  }

  Future<void> _process() async {
    final amount = double.tryParse(_amountController.text);
    final received = double.tryParse(_receivedController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sumă invalidă')),
      );
      return;
    }

    if (received == null || received < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sumă primită insuficientă')),
      );
      return;
    }

    setState(() => _processing = true);

    try {
      final transaction = await widget.onProcess(amount, received);
      setState(() {
        _result = transaction;
        _processing = false;
      });
    } catch (e) {
      setState(() => _processing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eroare: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_result != null) {
      return _buildResultDialog(_result!);
    }

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.payments, color: AppColors.kioskGreen),
          SizedBox(width: 8),
          Text('Plată cu Numerar'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Sumă de plată (RON)',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              enabled: !_processing,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _receivedController,
              decoration: const InputDecoration(
                labelText: 'Sumă primită (RON)',
                prefixIcon: Icon(Icons.money),
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              enabled: !_processing,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _change >= 0
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _change >= 0 ? AppColors.success : AppColors.error,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rest:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${_change.toStringAsFixed(2)} RON',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _change >= 0 ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
            if (_processing) ...[
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              const Text('Procesare plată...'),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _processing ? null : () => Navigator.pop(context),
          child: const Text('Anulează'),
        ),
        ElevatedButton(
          onPressed: _processing || _change < 0 ? null : _process,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.kioskGreen,
            foregroundColor: Colors.white,
          ),
          child: const Text('Procesează'),
        ),
      ],
    );
  }

  Widget _buildResultDialog(PaymentTransaction transaction) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success),
          SizedBox(width: 8),
          Text('Plată Finalizată'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('ID Tranzacție:', transaction.transactionId),
            _buildInfoRow('Sumă:', transaction.formattedAmount),
            if (transaction.cashReceived != null)
              _buildInfoRow(
                'Primit:',
                '${transaction.cashReceived!.toStringAsFixed(2)} RON',
              ),
            if (transaction.cashChange != null)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'REST DE DAT:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${transaction.cashChange!.toStringAsFixed(2)} RON',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
          ),
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

/// Daily report dialog
class _DailyReportDialog extends StatelessWidget {
  final Map<String, dynamic> totals;

  const _DailyReportDialog({required this.totals});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'ro_RO', symbol: 'RON');
    final dateFormat = DateFormat('dd.MM.yyyy');

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.assessment, color: AppColors.kioskPurple),
          SizedBox(width: 8),
          Text('Raport Zilnic'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data: ${dateFormat.format(totals['date'] as DateTime)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildReportRow(
              'Total Tranzacții:',
              '${totals['totalTransactions']}',
            ),
            const Divider(),
            _buildReportRow(
              'Tranzacții Card:',
              '${totals['cardTransactions']}',
            ),
            _buildReportRow(
              'Total Card:',
              formatter.format(totals['cardTotal']),
              valueColor: AppColors.kioskBlue,
            ),
            const Divider(),
            _buildReportRow(
              'Tranzacții Numerar:',
              '${totals['cashTransactions']}',
            ),
            _buildReportRow(
              'Total Numerar:',
              formatter.format(totals['cashTotal']),
              valueColor: AppColors.kioskGreen,
            ),
            const Divider(),
            _buildReportRow(
              'Aprobate:',
              '${totals['approvedCount']}',
              valueColor: AppColors.success,
            ),
            _buildReportRow(
              'Refuzate:',
              '${totals['declinedCount']}',
              valueColor: AppColors.error,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.kioskPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.kioskPurple, width: 2),
              ),
              child: _buildReportRow(
                'TOTAL GENERAL:',
                formatter.format(totals['totalAmount']),
                valueColor: AppColors.kioskPurple,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.kioskPurple,
            foregroundColor: Colors.white,
          ),
          child: const Text('Închide'),
        ),
      ],
    );
  }

  Widget _buildReportRow(
    String label,
    String value, {
    Color? valueColor,
    double fontSize = 14,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.gray900,
            ),
          ),
        ],
      ),
    );
  }
}
