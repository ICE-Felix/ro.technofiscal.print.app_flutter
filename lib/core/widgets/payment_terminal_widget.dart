import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/payment_terminal_service.dart';
import '../style/app_colors.dart';

/// Widget to display payment terminal status
class PaymentTerminalStatusWidget extends StatelessWidget {
  final PaymentTerminalStatus status;
  final VoidCallback? onTestCard;
  final VoidCallback? onTestCash;

  const PaymentTerminalStatusWidget({
    super.key,
    required this.status,
    this.onTestCard,
    this.onTestCash,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Terminal de Plată',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStatusText(),
                        style: TextStyle(
                          fontSize: 13,
                          color: _getStatusColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (status == PaymentTerminalStatus.ready && (onTestCard != null || onTestCash != null)) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (onTestCard != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onTestCard,
                        icon: const Icon(Icons.credit_card),
                        label: const Text('Test Card'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kioskBlue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  if (onTestCard != null && onTestCash != null)
                    const SizedBox(width: 12),
                  if (onTestCash != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onTestCash,
                        icon: const Icon(Icons.payments),
                        label: const Text('Test Numerar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kioskGreen,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;

    switch (status) {
      case PaymentTerminalStatus.ready:
        icon = Icons.check_circle;
        color = AppColors.success;
        break;
      case PaymentTerminalStatus.processing:
        icon = Icons.sync;
        color = AppColors.kioskBlue;
        break;
      case PaymentTerminalStatus.waitingForCard:
        icon = Icons.credit_card;
        color = AppColors.warning;
        break;
      case PaymentTerminalStatus.waitingForPin:
        icon = Icons.pin;
        color = AppColors.warning;
        break;
      case PaymentTerminalStatus.waitingForCash:
        icon = Icons.payments;
        color = AppColors.warning;
        break;
      case PaymentTerminalStatus.offline:
        icon = Icons.cloud_off;
        color = AppColors.gray500;
        break;
      case PaymentTerminalStatus.error:
        icon = Icons.error;
        color = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _getStatusText() {
    switch (status) {
      case PaymentTerminalStatus.ready:
        return 'Pregătit';
      case PaymentTerminalStatus.processing:
        return 'Procesare...';
      case PaymentTerminalStatus.waitingForCard:
        return 'Așteptare card...';
      case PaymentTerminalStatus.waitingForPin:
        return 'Așteptare PIN...';
      case PaymentTerminalStatus.waitingForCash:
        return 'Așteptare numerar...';
      case PaymentTerminalStatus.offline:
        return 'Offline';
      case PaymentTerminalStatus.error:
        return 'Eroare';
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case PaymentTerminalStatus.ready:
        return AppColors.success;
      case PaymentTerminalStatus.processing:
      case PaymentTerminalStatus.waitingForCard:
      case PaymentTerminalStatus.waitingForPin:
      case PaymentTerminalStatus.waitingForCash:
        return AppColors.kioskBlue;
      case PaymentTerminalStatus.offline:
        return AppColors.gray500;
      case PaymentTerminalStatus.error:
        return AppColors.error;
    }
  }
}

/// Widget to display transaction list
class TransactionListWidget extends StatelessWidget {
  final List<PaymentTransaction> transactions;
  final VoidCallback? onClearHistory;

  const TransactionListWidget({
    super.key,
    required this.transactions,
    this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Istoric Tranzacții',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (transactions.isNotEmpty && onClearHistory != null)
                  TextButton.icon(
                    onPressed: onClearHistory,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Șterge'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 48,
                      color: AppColors.gray400,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Nicio tranzacție',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: transactions.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final transaction = transactions[transactions.length - 1 - index];
                  return _buildTransactionItem(transaction);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(PaymentTransaction transaction) {
    return ListTile(
      leading: _buildTransactionIcon(transaction),
      title: Text(
        transaction.transactionId,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            _getTransactionDescription(transaction),
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            DateFormat('dd.MM.yyyy HH:mm:ss').format(transaction.timestamp),
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            transaction.formattedAmount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _getAmountColor(transaction.status),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getStatusColor(transaction.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              transaction.statusText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _getStatusColor(transaction.status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionIcon(PaymentTransaction transaction) {
    IconData icon;
    Color color;

    if (transaction.status != TransactionStatus.approved) {
      icon = Icons.error_outline;
      color = AppColors.error;
    } else {
      switch (transaction.paymentMethod) {
        case PaymentMethodType.card:
          icon = transaction.cardType == CardType.contactless
              ? Icons.contactless
              : Icons.credit_card;
          color = AppColors.kioskBlue;
          break;
        case PaymentMethodType.cash:
          icon = Icons.payments;
          color = AppColors.kioskGreen;
          break;
        case PaymentMethodType.mixed:
          icon = Icons.account_balance_wallet;
          color = AppColors.kioskPurple;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _getTransactionDescription(PaymentTransaction transaction) {
    switch (transaction.paymentMethod) {
      case PaymentMethodType.card:
        final cardInfo = transaction.cardLastFourDigits != null
            ? '**** ${transaction.cardLastFourDigits}'
            : 'Card';
        final typeInfo = transaction.cardType == CardType.contactless
            ? 'Contactless'
            : 'CHIP & PIN';
        return '$cardInfo • $typeInfo';
      case PaymentMethodType.cash:
        if (transaction.cashChange != null && transaction.cashChange! > 0) {
          final formatter = NumberFormat.currency(locale: 'ro_RO', symbol: 'RON');
          return 'Numerar • Rest: ${formatter.format(transaction.cashChange)}';
        }
        return 'Numerar';
      case PaymentMethodType.mixed:
        return 'Plată mixtă';
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.approved:
        return AppColors.success;
      case TransactionStatus.declined:
      case TransactionStatus.error:
        return AppColors.error;
      case TransactionStatus.cancelled:
        return AppColors.gray500;
      case TransactionStatus.pending:
      case TransactionStatus.timeout:
        return AppColors.warning;
    }
  }

  Color _getAmountColor(TransactionStatus status) {
    return status == TransactionStatus.approved
        ? AppColors.success
        : AppColors.textSecondary;
  }
}

/// Widget for daily totals display
class DailyTotalsWidget extends StatelessWidget {
  final Map<String, dynamic> totals;

  const DailyTotalsWidget({
    super.key,
    required this.totals,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'ro_RO', symbol: 'RON');
    final totalAmount = totals['totalAmount'] as double;
    final cardTotal = totals['cardTotal'] as double;
    final cashTotal = totals['cashTotal'] as double;
    final totalTransactions = totals['totalTransactions'] as int;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Zilnic',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.kioskBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.kioskBlue, width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    'TOTAL ÎNCASĂRI',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatter.format(totalAmount),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.kioskBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalTransactions tranzacții',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTotalCard(
                    'Card',
                    cardTotal,
                    totals['cardTransactions'] as int,
                    Icons.credit_card,
                    AppColors.kioskBlue,
                    formatter,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTotalCard(
                    'Numerar',
                    cashTotal,
                    totals['cashTransactions'] as int,
                    Icons.payments,
                    AppColors.kioskGreen,
                    formatter,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(
    String label,
    double amount,
    int count,
    IconData icon,
    Color color,
    NumberFormat formatter,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatter.format(amount),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            '$count tranz.',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
