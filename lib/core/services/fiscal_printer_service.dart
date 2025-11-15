import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Fiscal printer status
enum FiscalPrinterStatus {
  ready,
  printing,
  offline,
  fiscalMemoryFull,
  fiscalDayOpen,
  fiscalDayClosed,
  error,
}

/// Receipt types for Romanian fiscal compliance
enum ReceiptType {
  sale,           // Bon de vânzare
  refund,         // Bon de retur
  invoice,        // Factură
  proforma,       // Factură proformă
  cancelled,      // Anulat
}

/// Payment method for fiscal receipt
enum FiscalPaymentMethod {
  cash,           // Numerar
  card,           // Card bancar
  transfer,       // Transfer bancar
  voucher,        // Voucher/Bon valoric
}

/// Romanian VAT rates (TVA)
enum VATRate {
  standard(19.0),    // Cotă standard 19%
  reduced(9.0),      // Cotă redusă 9%
  reduced5(5.0),     // Cotă redusă 5%
  exempt(0.0);       // Scutit de TVA

  final double percentage;
  const VATRate(this.percentage);
}

/// Fiscal receipt item
class FiscalReceiptItem {
  final String name;
  final double quantity;
  final double unitPrice;
  final VATRate vatRate;
  final String? code;

  const FiscalReceiptItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.vatRate,
    this.code,
  });

  double get subtotal => quantity * unitPrice;

  double get vatAmount {
    final netAmount = subtotal / (1 + vatRate.percentage / 100);
    return subtotal - netAmount;
  }

  double get netAmount => subtotal - vatAmount;
}

/// Fiscal receipt model (Romanian ANAF compliant)
class FiscalReceipt {
  final String receiptNumber;      // Număr bon fiscal
  final String fiscalCode;         // Cod fiscal (CIF)
  final String fiscalMemoryNumber; // Număr memorie fiscală
  final DateTime dateTime;
  final ReceiptType type;
  final List<FiscalReceiptItem> items;
  final FiscalPaymentMethod paymentMethod;
  final String? operatorName;
  final String? operatorId;
  final String? customerId;
  final String? customerName;

  const FiscalReceipt({
    required this.receiptNumber,
    required this.fiscalCode,
    required this.fiscalMemoryNumber,
    required this.dateTime,
    required this.type,
    required this.items,
    required this.paymentMethod,
    this.operatorName,
    this.operatorId,
    this.customerId,
    this.customerName,
  });

  /// Calculate total before VAT
  double get netTotal {
    return items.fold(0.0, (sum, item) => sum + item.netAmount);
  }

  /// Calculate total VAT
  double get vatTotal {
    return items.fold(0.0, (sum, item) => sum + item.vatAmount);
  }

  /// Calculate total with VAT
  double get grossTotal {
    return items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  /// Get VAT breakdown by rate
  Map<VATRate, double> get vatBreakdown {
    final breakdown = <VATRate, double>{};
    for (final item in items) {
      breakdown[item.vatRate] = (breakdown[item.vatRate] ?? 0.0) + item.vatAmount;
    }
    return breakdown;
  }

  /// Format receipt as Romanian fiscal receipt text
  String toReceiptText() {
    final buffer = StringBuffer();
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm:ss');
    final currencyFormat = NumberFormat.currency(locale: 'ro_RO', symbol: 'RON');

    // Header
    buffer.writeln('============================================');
    buffer.writeln('          BON FISCAL - ROMANIA');
    buffer.writeln('============================================');
    buffer.writeln('');
    buffer.writeln('Nr. Bon: $receiptNumber');
    buffer.writeln('CIF: $fiscalCode');
    buffer.writeln('Nr. Mem. Fiscală: $fiscalMemoryNumber');
    buffer.writeln('Data: ${dateFormat.format(dateTime)}');
    if (operatorName != null) {
      buffer.writeln('Operator: $operatorName');
    }
    buffer.writeln('');
    buffer.writeln('============================================');
    buffer.writeln('');

    // Items
    for (final item in items) {
      buffer.writeln(item.name);
      buffer.writeln('  ${item.quantity} x ${currencyFormat.format(item.unitPrice)}');
      buffer.writeln('  TVA ${item.vatRate.percentage.toStringAsFixed(0)}%: ${currencyFormat.format(item.vatAmount)}');
      buffer.writeln('  TOTAL: ${currencyFormat.format(item.subtotal)}');
      buffer.writeln('');
    }

    buffer.writeln('--------------------------------------------');
    buffer.writeln('');

    // Totals
    buffer.writeln('SUBTOTAL (fără TVA): ${currencyFormat.format(netTotal)}');
    buffer.writeln('');

    // VAT breakdown
    buffer.writeln('TVA pe cote:');
    vatBreakdown.forEach((rate, amount) {
      buffer.writeln('  ${rate.percentage.toStringAsFixed(0)}%: ${currencyFormat.format(amount)}');
    });
    buffer.writeln('');

    buffer.writeln('TOTAL TVA: ${currencyFormat.format(vatTotal)}');
    buffer.writeln('');
    buffer.writeln('============================================');
    buffer.writeln('TOTAL DE PLATĂ: ${currencyFormat.format(grossTotal)}');
    buffer.writeln('============================================');
    buffer.writeln('');

    // Payment method
    final paymentText = _getPaymentMethodText(paymentMethod);
    buffer.writeln('Metodă de plată: $paymentText');
    buffer.writeln('');

    // Footer
    buffer.writeln('--------------------------------------------');
    buffer.writeln('Vă mulțumim pentru cumpărături!');
    buffer.writeln('Bonul fiscal este valabil pentru garanție');
    buffer.writeln('============================================');

    return buffer.toString();
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

/// Daily fiscal report (Z Report)
class FiscalDailyReport {
  final String reportNumber;
  final DateTime date;
  final int numberOfReceipts;
  final double totalSales;
  final double totalRefunds;
  final double netRevenue;
  final Map<VATRate, double> vatByRate;
  final Map<FiscalPaymentMethod, double> paymentsByMethod;

  const FiscalDailyReport({
    required this.reportNumber,
    required this.date,
    required this.numberOfReceipts,
    required this.totalSales,
    required this.totalRefunds,
    required this.netRevenue,
    required this.vatByRate,
    required this.paymentsByMethod,
  });
}

/// Abstract fiscal printer service interface
abstract class FiscalPrinterService {
  /// Get fiscal printer status
  Future<FiscalPrinterStatus> getStatus();

  /// Check if fiscal day is open
  Future<bool> isFiscalDayOpen();

  /// Open fiscal day (Z Report previous day, start new day)
  Future<void> openFiscalDay();

  /// Close fiscal day (generate Z Report)
  Future<FiscalDailyReport> closeFiscalDay();

  /// Print fiscal receipt
  Future<String> printFiscalReceipt(FiscalReceipt receipt);

  /// Print receipt copy (duplicate)
  Future<void> printReceiptCopy(String receiptNumber);

  /// Cancel receipt
  Future<void> cancelReceipt(String receiptNumber);

  /// Get daily report (X Report - intermediate)
  Future<FiscalDailyReport> getDailyReport();

  /// Get fiscal memory info
  Future<Map<String, dynamic>> getFiscalMemoryInfo();

  /// Get last receipt number
  Future<String> getLastReceiptNumber();
}

/// Mock fiscal printer service for development
class MockFiscalPrinterService implements FiscalPrinterService {
  static final MockFiscalPrinterService _instance = MockFiscalPrinterService._internal();
  factory MockFiscalPrinterService() => _instance;
  MockFiscalPrinterService._internal();

  // Mock state
  bool _fiscalDayOpen = true;
  int _receiptCounter = 1000;
  final List<FiscalReceipt> _todayReceipts = [];
  FiscalPrinterStatus _status = FiscalPrinterStatus.ready;

  // Mock configuration
  final String _fiscalCode = 'RO12345678'; // CIF example
  final String _fiscalMemoryNumber = 'FM001234567890';
  final String _operatorName = 'Administrator';
  final String _operatorId = 'OP001';

  @override
  Future<FiscalPrinterStatus> getStatus() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _status;
  }

  @override
  Future<bool> isFiscalDayOpen() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _fiscalDayOpen;
  }

  @override
  Future<void> openFiscalDay() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_fiscalDayOpen) {
      throw Exception('Fiscal day already open');
    }

    // In real implementation, this would generate Z Report for previous day
    _fiscalDayOpen = true;
    _todayReceipts.clear();
    _status = FiscalPrinterStatus.fiscalDayOpen;

    debugPrint('✅ Fiscal day opened');
  }

  @override
  Future<FiscalDailyReport> closeFiscalDay() async {
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!_fiscalDayOpen) {
      throw Exception('Fiscal day already closed');
    }

    // Calculate daily totals
    double totalSales = 0.0;
    double totalRefunds = 0.0;
    final vatByRate = <VATRate, double>{};
    final paymentsByMethod = <FiscalPaymentMethod, double>{};

    for (final receipt in _todayReceipts) {
      if (receipt.type == ReceiptType.sale) {
        totalSales += receipt.grossTotal;
      } else if (receipt.type == ReceiptType.refund) {
        totalRefunds += receipt.grossTotal;
      }

      // Accumulate VAT by rate
      receipt.vatBreakdown.forEach((rate, amount) {
        vatByRate[rate] = (vatByRate[rate] ?? 0.0) + amount;
      });

      // Accumulate payments by method
      final amount = paymentsByMethod[receipt.paymentMethod] ?? 0.0;
      paymentsByMethod[receipt.paymentMethod] = amount + receipt.grossTotal;
    }

    final report = FiscalDailyReport(
      reportNumber: 'Z${DateFormat('yyyyMMdd').format(DateTime.now())}',
      date: DateTime.now(),
      numberOfReceipts: _todayReceipts.length,
      totalSales: totalSales,
      totalRefunds: totalRefunds,
      netRevenue: totalSales - totalRefunds,
      vatByRate: vatByRate,
      paymentsByMethod: paymentsByMethod,
    );

    _fiscalDayOpen = false;
    _status = FiscalPrinterStatus.fiscalDayClosed;

    debugPrint('✅ Fiscal day closed. Z Report generated.');
    debugPrint('   Receipts: ${report.numberOfReceipts}');
    debugPrint('   Revenue: ${report.netRevenue} RON');

    return report;
  }

  @override
  Future<String> printFiscalReceipt(FiscalReceipt receipt) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (!_fiscalDayOpen) {
      throw Exception('Fiscal day is closed. Please open fiscal day first.');
    }

    if (_status != FiscalPrinterStatus.ready &&
        _status != FiscalPrinterStatus.fiscalDayOpen) {
      throw Exception('Fiscal printer not ready. Status: $_status');
    }

    // Generate receipt number
    _receiptCounter++;
    final receiptNumber = 'F${DateFormat('yyyyMMdd').format(DateTime.now())}-${_receiptCounter.toString().padLeft(6, '0')}';

    // Create fiscal receipt with generated number
    final fiscalReceipt = FiscalReceipt(
      receiptNumber: receiptNumber,
      fiscalCode: _fiscalCode,
      fiscalMemoryNumber: _fiscalMemoryNumber,
      dateTime: DateTime.now(),
      type: receipt.type,
      items: receipt.items,
      paymentMethod: receipt.paymentMethod,
      operatorName: _operatorName,
      operatorId: _operatorId,
      customerId: receipt.customerId,
      customerName: receipt.customerName,
    );

    // Store receipt
    _todayReceipts.add(fiscalReceipt);

    // Simulate printing
    _status = FiscalPrinterStatus.printing;
    await Future.delayed(const Duration(milliseconds: 2000));
    _status = FiscalPrinterStatus.ready;

    debugPrint('🧾 Fiscal receipt printed: $receiptNumber');
    debugPrint('   Total: ${fiscalReceipt.grossTotal} RON');
    debugPrint('   Method: ${fiscalReceipt.paymentMethod}');

    return receiptNumber;
  }

  @override
  Future<void> printReceiptCopy(String receiptNumber) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final receipt = _todayReceipts.firstWhere(
      (r) => r.receiptNumber == receiptNumber,
      orElse: () => throw Exception('Receipt not found: $receiptNumber'),
    );

    debugPrint('🧾 Fiscal receipt copy printed: $receiptNumber');
  }

  @override
  Future<void> cancelReceipt(String receiptNumber) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _todayReceipts.indexWhere(
      (r) => r.receiptNumber == receiptNumber,
    );

    if (index == -1) {
      throw Exception('Receipt not found: $receiptNumber');
    }

    // In real implementation, would print cancellation receipt
    debugPrint('❌ Fiscal receipt cancelled: $receiptNumber');
  }

  @override
  Future<FiscalDailyReport> getDailyReport() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Same logic as close fiscal day, but doesn't close the day (X Report)
    double totalSales = 0.0;
    double totalRefunds = 0.0;
    final vatByRate = <VATRate, double>{};
    final paymentsByMethod = <FiscalPaymentMethod, double>{};

    for (final receipt in _todayReceipts) {
      if (receipt.type == ReceiptType.sale) {
        totalSales += receipt.grossTotal;
      } else if (receipt.type == ReceiptType.refund) {
        totalRefunds += receipt.grossTotal;
      }

      receipt.vatBreakdown.forEach((rate, amount) {
        vatByRate[rate] = (vatByRate[rate] ?? 0.0) + amount;
      });

      final amount = paymentsByMethod[receipt.paymentMethod] ?? 0.0;
      paymentsByMethod[receipt.paymentMethod] = amount + receipt.grossTotal;
    }

    return FiscalDailyReport(
      reportNumber: 'X${DateFormat('yyyyMMdd-HHmmss').format(DateTime.now())}',
      date: DateTime.now(),
      numberOfReceipts: _todayReceipts.length,
      totalSales: totalSales,
      totalRefunds: totalRefunds,
      netRevenue: totalSales - totalRefunds,
      vatByRate: vatByRate,
      paymentsByMethod: paymentsByMethod,
    );
  }

  @override
  Future<Map<String, dynamic>> getFiscalMemoryInfo() async {
    await Future.delayed(const Duration(milliseconds: 200));

    return {
      'fiscalMemoryNumber': _fiscalMemoryNumber,
      'fiscalCode': _fiscalCode,
      'firstReceiptDate': DateTime(2024, 1, 1),
      'lastReceiptDate': DateTime.now(),
      'totalReceipts': _receiptCounter,
      'fiscalMemoryCapacity': 100000, // Max receipts
      'fiscalMemoryUsed': _receiptCounter,
      'fiscalMemoryPercentage': (_receiptCounter / 100000 * 100).toStringAsFixed(2),
    };
  }

  @override
  Future<String> getLastReceiptNumber() async {
    await Future.delayed(const Duration(milliseconds: 50));

    if (_todayReceipts.isEmpty) {
      return 'F${DateFormat('yyyyMMdd').format(DateTime.now())}-${_receiptCounter.toString().padLeft(6, '0')}';
    }

    return _todayReceipts.last.receiptNumber;
  }

  /// Helper: Get today's receipts
  List<FiscalReceipt> getTodayReceipts() {
    return List.unmodifiable(_todayReceipts);
  }

  /// Helper: Reset for testing
  void reset() {
    _fiscalDayOpen = true;
    _receiptCounter = 1000;
    _todayReceipts.clear();
    _status = FiscalPrinterStatus.ready;
    debugPrint('🔄 Fiscal printer reset');
  }
}
