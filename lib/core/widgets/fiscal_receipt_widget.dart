import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/fiscal_printer_service.dart';
import '../style/app_colors.dart';

/// Widget to display fiscal receipt preview
class FiscalReceiptPreview extends StatelessWidget {
  final FiscalReceipt receipt;

  const FiscalReceiptPreview({
    super.key,
    required this.receipt,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  const Text(
                    'BON FISCAL - ROMANIA',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 200,
                    height: 2,
                    color: AppColors.gray900,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Receipt info
            _buildInfoRow('Nr. Bon:', receipt.receiptNumber),
            _buildInfoRow('CIF:', receipt.fiscalCode),
            _buildInfoRow('Nr. Mem. Fiscală:', receipt.fiscalMemoryNumber),
            _buildInfoRow(
              'Data:',
              DateFormat('dd.MM.yyyy HH:mm:ss').format(receipt.dateTime),
            ),
            if (receipt.operatorName != null)
              _buildInfoRow('Operator:', receipt.operatorName!),

            const SizedBox(height: 16),
            const Divider(thickness: 2),
            const SizedBox(height: 16),

            // Items
            ...receipt.items.map((item) => _buildItemRow(item)),

            const SizedBox(height: 16),
            const Divider(thickness: 1),
            const SizedBox(height: 16),

            // Totals
            _buildTotalRow('SUBTOTAL (fără TVA):', receipt.netTotal, bold: false),
            const SizedBox(height: 12),

            // VAT breakdown
            const Text(
              'TVA pe cote:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            ...receipt.vatBreakdown.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: _buildTotalRow(
                  '${entry.key.percentage.toStringAsFixed(0)}%:',
                  entry.value,
                  bold: false,
                  fontSize: 13,
                ),
              );
            }),

            const SizedBox(height: 12),
            _buildTotalRow('TOTAL TVA:', receipt.vatTotal, bold: false),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.kioskBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.kioskBlue, width: 2),
              ),
              child: _buildTotalRow(
                'TOTAL DE PLATĂ:',
                receipt.grossTotal,
                bold: true,
                fontSize: 18,
                color: AppColors.kioskBlue,
              ),
            ),

            const SizedBox(height: 16),

            // Payment method
            _buildInfoRow(
              'Metodă de plată:',
              _getPaymentMethodText(receipt.paymentMethod),
              valueStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),

            const SizedBox(height: 16),
            const Divider(thickness: 1),
            const SizedBox(height: 12),

            // Footer
            const Center(
              child: Column(
                children: [
                  Text(
                    'Vă mulțumim pentru cumpărături!',
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Bonul fiscal este valabil pentru garanție',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ??
                  const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(FiscalReceiptItem item) {
    final currencyFormat = NumberFormat.currency(locale: 'ro_RO', symbol: 'RON');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.quantity} x ${currencyFormat.format(item.unitPrice)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'TVA ${item.vatRate.percentage.toStringAsFixed(0)}%: ${currencyFormat.format(item.vatAmount)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'TOTAL: ${currencyFormat.format(item.subtotal)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    double amount, {
    bool bold = true,
    double fontSize = 14,
    Color? color,
  }) {
    final currencyFormat = NumberFormat.currency(locale: 'ro_RO', symbol: 'RON');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
        Text(
          currencyFormat.format(amount),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getPaymentMethodText(FiscalPaymentMethod method) {
    switch (method) {
      case FiscalPaymentMethod.cash:
        return 'NUMERAR';
      case FiscalPaymentMethod.card:
        return 'CARD BANCAR';
      case FiscalPaymentMethod.transfer:
        return 'TRANSFER BANCAR';
      case FiscalPaymentMethod.voucher:
        return 'VOUCHER';
    }
  }
}

/// Widget for fiscal printer status display
class FiscalPrinterStatusWidget extends StatelessWidget {
  final FiscalPrinterStatus status;
  final bool fiscalDayOpen;
  final VoidCallback? onOpenDay;
  final VoidCallback? onCloseDay;

  const FiscalPrinterStatusWidget({
    super.key,
    required this.status,
    required this.fiscalDayOpen,
    this.onOpenDay,
    this.onCloseDay,
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
                        'Imprimantă Fiscală',
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDayStatusCard(),
                ),
                const SizedBox(width: 12),
                if (!fiscalDayOpen && onOpenDay != null)
                  ElevatedButton.icon(
                    onPressed: onOpenDay,
                    icon: const Icon(Icons.wb_sunny_outlined),
                    label: const Text('Deschide Ziua'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kioskGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (fiscalDayOpen && onCloseDay != null)
                  ElevatedButton.icon(
                    onPressed: onCloseDay,
                    icon: const Icon(Icons.nightlight_outlined),
                    label: const Text('Închide Ziua (Z)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kioskRed,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;

    switch (status) {
      case FiscalPrinterStatus.ready:
      case FiscalPrinterStatus.fiscalDayOpen:
        icon = Icons.check_circle;
        color = AppColors.success;
        break;
      case FiscalPrinterStatus.printing:
        icon = Icons.print;
        color = AppColors.kioskBlue;
        break;
      case FiscalPrinterStatus.offline:
        icon = Icons.cloud_off;
        color = AppColors.gray500;
        break;
      case FiscalPrinterStatus.fiscalMemoryFull:
        icon = Icons.storage;
        color = AppColors.error;
        break;
      case FiscalPrinterStatus.fiscalDayClosed:
        icon = Icons.event_busy;
        color = AppColors.warning;
        break;
      case FiscalPrinterStatus.error:
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

  Widget _buildDayStatusCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fiscalDayOpen
            ? AppColors.success.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: fiscalDayOpen ? AppColors.success : AppColors.warning,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            fiscalDayOpen ? Icons.wb_sunny : Icons.nightlight,
            color: fiscalDayOpen ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 8),
          Text(
            fiscalDayOpen ? 'Ziua Fiscală Deschisă' : 'Ziua Fiscală Închisă',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: fiscalDayOpen ? AppColors.success : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    switch (status) {
      case FiscalPrinterStatus.ready:
        return 'Pregătită';
      case FiscalPrinterStatus.printing:
        return 'Tipărire...';
      case FiscalPrinterStatus.offline:
        return 'Offline';
      case FiscalPrinterStatus.fiscalMemoryFull:
        return 'Memorie fiscală plină';
      case FiscalPrinterStatus.fiscalDayOpen:
        return 'Ziua fiscală deschisă';
      case FiscalPrinterStatus.fiscalDayClosed:
        return 'Ziua fiscală închisă';
      case FiscalPrinterStatus.error:
        return 'Eroare';
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case FiscalPrinterStatus.ready:
      case FiscalPrinterStatus.fiscalDayOpen:
        return AppColors.success;
      case FiscalPrinterStatus.printing:
        return AppColors.kioskBlue;
      case FiscalPrinterStatus.offline:
        return AppColors.gray500;
      case FiscalPrinterStatus.fiscalMemoryFull:
      case FiscalPrinterStatus.error:
        return AppColors.error;
      case FiscalPrinterStatus.fiscalDayClosed:
        return AppColors.warning;
    }
  }
}
