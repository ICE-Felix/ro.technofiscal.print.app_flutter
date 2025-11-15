import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Payment terminal status
enum PaymentTerminalStatus {
  ready,
  processing,
  offline,
  error,
  waitingForCard,
  waitingForPin,
  waitingForCash,
}

/// Payment method type
enum PaymentMethodType {
  card,           // Card bancar (CHIP & PIN, Contactless)
  cash,           // Numerar
  mixed,          // Mixt (parțial card, parțial numerar)
}

/// Card payment type
enum CardType {
  chip,           // CHIP & PIN
  contactless,    // Contactless/NFC
  unknown,
}

/// Transaction status
enum TransactionStatus {
  pending,
  approved,
  declined,
  cancelled,
  timeout,
  error,
}

/// Payment transaction model
class PaymentTransaction {
  final String transactionId;
  final double amount;
  final PaymentMethodType paymentMethod;
  final TransactionStatus status;
  final DateTime timestamp;
  final String? cardLastFourDigits;
  final CardType? cardType;
  final String? authorizationCode;
  final String? errorMessage;
  final double? cashReceived;
  final double? cashChange;

  const PaymentTransaction({
    required this.transactionId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.timestamp,
    this.cardLastFourDigits,
    this.cardType,
    this.authorizationCode,
    this.errorMessage,
    this.cashReceived,
    this.cashChange,
  });

  String get formattedAmount {
    final formatter = NumberFormat.currency(locale: 'ro_RO', symbol: 'RON');
    return formatter.format(amount);
  }

  String get statusText {
    switch (status) {
      case TransactionStatus.pending:
        return 'În așteptare';
      case TransactionStatus.approved:
        return 'Aprobată';
      case TransactionStatus.declined:
        return 'Refuzată';
      case TransactionStatus.cancelled:
        return 'Anulată';
      case TransactionStatus.timeout:
        return 'Timeout';
      case TransactionStatus.error:
        return 'Eroare';
    }
  }

  String toReceiptText() {
    final buffer = StringBuffer();
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm:ss');

    buffer.writeln('============================================');
    buffer.writeln('          CHITANȚĂ PLATĂ');
    buffer.writeln('============================================');
    buffer.writeln('');
    buffer.writeln('ID Tranzacție: $transactionId');
    buffer.writeln('Data: ${dateFormat.format(timestamp)}');
    buffer.writeln('');

    switch (paymentMethod) {
      case PaymentMethodType.card:
        buffer.writeln('Metodă plată: CARD BANCAR');
        if (cardType != null) {
          buffer.writeln('Tip card: ${_getCardTypeText(cardType!)}');
        }
        if (cardLastFourDigits != null) {
          buffer.writeln('Card: **** **** **** $cardLastFourDigits');
        }
        if (authorizationCode != null) {
          buffer.writeln('Cod autorizare: $authorizationCode');
        }
        break;
      case PaymentMethodType.cash:
        buffer.writeln('Metodă plată: NUMERAR');
        if (cashReceived != null) {
          buffer.writeln('Primit: ${NumberFormat.currency(locale: 'ro_RO', symbol: 'RON').format(cashReceived)}');
        }
        if (cashChange != null) {
          buffer.writeln('Rest: ${NumberFormat.currency(locale: 'ro_RO', symbol: 'RON').format(cashChange)}');
        }
        break;
      case PaymentMethodType.mixed:
        buffer.writeln('Metodă plată: MIXT');
        break;
    }

    buffer.writeln('');
    buffer.writeln('SUMĂ: $formattedAmount');
    buffer.writeln('Status: $statusText');
    buffer.writeln('');
    buffer.writeln('============================================');

    return buffer.toString();
  }

  String _getCardTypeText(CardType type) {
    switch (type) {
      case CardType.chip:
        return 'CHIP & PIN';
      case CardType.contactless:
        return 'Contactless';
      case CardType.unknown:
        return 'Necunoscut';
    }
  }
}

/// Abstract payment terminal service interface
abstract class PaymentTerminalService {
  /// Get terminal status
  Future<PaymentTerminalStatus> getStatus();

  /// Check if terminal is ready for payment
  Future<bool> isReady();

  /// Process card payment
  Future<PaymentTransaction> processCardPayment({
    required double amount,
    bool allowContactless = true,
  });

  /// Process cash payment
  Future<PaymentTransaction> processCashPayment({
    required double amount,
    required double cashReceived,
  });

  /// Cancel current transaction
  Future<void> cancelTransaction();

  /// Get transaction history
  List<PaymentTransaction> getTransactionHistory();

  /// Get transaction by ID
  PaymentTransaction? getTransaction(String transactionId);

  /// Clear transaction history
  void clearHistory();

  /// Get daily totals
  Future<Map<String, dynamic>> getDailyTotals();
}

/// Mock payment terminal service for development
class MockPaymentTerminalService implements PaymentTerminalService {
  static final MockPaymentTerminalService _instance =
      MockPaymentTerminalService._internal();
  factory MockPaymentTerminalService() => _instance;
  MockPaymentTerminalService._internal();

  // Mock state
  PaymentTerminalStatus _status = PaymentTerminalStatus.ready;
  final List<PaymentTransaction> _transactionHistory = [];
  int _transactionCounter = 1000;
  final Random _random = Random();

  // Mock configuration
  static const double contactlessLimit = 100.0; // RON limit for contactless

  @override
  Future<PaymentTerminalStatus> getStatus() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _status;
  }

  @override
  Future<bool> isReady() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _status == PaymentTerminalStatus.ready;
  }

  @override
  Future<PaymentTransaction> processCardPayment({
    required double amount,
    bool allowContactless = true,
  }) async {
    if (_status != PaymentTerminalStatus.ready) {
      throw Exception('Payment terminal not ready. Status: $_status');
    }

    // Generate transaction ID
    _transactionCounter++;
    final transactionId = 'PAY${DateFormat('yyyyMMdd').format(DateTime.now())}-${_transactionCounter.toString().padLeft(6, '0')}';

    debugPrint('💳 Processing card payment: $transactionId');
    debugPrint('   Amount: $amount RON');

    // Determine card type
    final isContactless = allowContactless && amount <= contactlessLimit && _random.nextBool();
    final cardType = isContactless ? CardType.contactless : CardType.chip;

    // Simulate card presentation
    _status = PaymentTerminalStatus.waitingForCard;
    await Future.delayed(const Duration(seconds: 1));

    // Simulate PIN entry (only for CHIP)
    if (cardType == CardType.chip) {
      _status = PaymentTerminalStatus.waitingForPin;
      debugPrint('   Waiting for PIN...');
      await Future.delayed(const Duration(seconds: 2));
    }

    // Process payment
    _status = PaymentTerminalStatus.processing;
    debugPrint('   Processing...');
    await Future.delayed(const Duration(milliseconds: 1500));

    // Random outcome (95% success rate)
    final isApproved = _random.nextDouble() > 0.05;
    final status = isApproved ? TransactionStatus.approved : TransactionStatus.declined;

    // Generate card details
    final lastFourDigits = (1000 + _random.nextInt(9000)).toString();
    final authCode = isApproved ? _generateAuthCode() : null;

    final transaction = PaymentTransaction(
      transactionId: transactionId,
      amount: amount,
      paymentMethod: PaymentMethodType.card,
      status: status,
      timestamp: DateTime.now(),
      cardLastFourDigits: lastFourDigits,
      cardType: cardType,
      authorizationCode: authCode,
      errorMessage: isApproved ? null : 'Card refuzat de bancă',
    );

    _transactionHistory.add(transaction);
    _status = PaymentTerminalStatus.ready;

    debugPrint('   Status: ${transaction.statusText}');
    if (authCode != null) {
      debugPrint('   Auth Code: $authCode');
    }

    return transaction;
  }

  @override
  Future<PaymentTransaction> processCashPayment({
    required double amount,
    required double cashReceived,
  }) async {
    if (_status != PaymentTerminalStatus.ready) {
      throw Exception('Payment terminal not ready. Status: $_status');
    }

    if (cashReceived < amount) {
      throw Exception('Sumă insuficientă. Necesar: $amount RON, Primit: $cashReceived RON');
    }

    // Generate transaction ID
    _transactionCounter++;
    final transactionId = 'CASH${DateFormat('yyyyMMdd').format(DateTime.now())}-${_transactionCounter.toString().padLeft(6, '0')}';

    debugPrint('💵 Processing cash payment: $transactionId');
    debugPrint('   Amount: $amount RON');
    debugPrint('   Received: $cashReceived RON');

    _status = PaymentTerminalStatus.waitingForCash;
    await Future.delayed(const Duration(seconds: 1));

    _status = PaymentTerminalStatus.processing;
    await Future.delayed(const Duration(milliseconds: 500));

    final change = cashReceived - amount;

    final transaction = PaymentTransaction(
      transactionId: transactionId,
      amount: amount,
      paymentMethod: PaymentMethodType.cash,
      status: TransactionStatus.approved,
      timestamp: DateTime.now(),
      cashReceived: cashReceived,
      cashChange: change,
    );

    _transactionHistory.add(transaction);
    _status = PaymentTerminalStatus.ready;

    debugPrint('   Change: $change RON');
    debugPrint('   Status: Approved');

    return transaction;
  }

  @override
  Future<void> cancelTransaction() async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (_status == PaymentTerminalStatus.ready) {
      throw Exception('No active transaction to cancel');
    }

    debugPrint('❌ Transaction cancelled');
    _status = PaymentTerminalStatus.ready;
  }

  @override
  List<PaymentTransaction> getTransactionHistory() {
    return List.unmodifiable(_transactionHistory);
  }

  @override
  PaymentTransaction? getTransaction(String transactionId) {
    try {
      return _transactionHistory.firstWhere((t) => t.transactionId == transactionId);
    } catch (e) {
      return null;
    }
  }

  @override
  void clearHistory() {
    _transactionHistory.clear();
    debugPrint('🗑️ Transaction history cleared');
  }

  @override
  Future<Map<String, dynamic>> getDailyTotals() async {
    await Future.delayed(const Duration(milliseconds: 100));

    final today = DateTime.now();
    final todayTransactions = _transactionHistory.where((t) {
      return t.timestamp.year == today.year &&
          t.timestamp.month == today.month &&
          t.timestamp.day == today.day &&
          t.status == TransactionStatus.approved;
    }).toList();

    double totalCard = 0.0;
    double totalCash = 0.0;
    int countCard = 0;
    int countCash = 0;

    for (final transaction in todayTransactions) {
      if (transaction.paymentMethod == PaymentMethodType.card) {
        totalCard += transaction.amount;
        countCard++;
      } else if (transaction.paymentMethod == PaymentMethodType.cash) {
        totalCash += transaction.amount;
        countCash++;
      }
    }

    return {
      'date': today,
      'totalTransactions': todayTransactions.length,
      'totalAmount': totalCard + totalCash,
      'cardTransactions': countCard,
      'cardTotal': totalCard,
      'cashTransactions': countCash,
      'cashTotal': totalCash,
      'approvedCount': todayTransactions.length,
      'declinedCount': _transactionHistory.where((t) =>
        t.timestamp.year == today.year &&
        t.timestamp.month == today.month &&
        t.timestamp.day == today.day &&
        t.status == TransactionStatus.declined
      ).length,
    };
  }

  /// Helper: Generate authorization code
  String _generateAuthCode() {
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(_random.nextInt(chars.length)),
      ),
    );
  }

  /// Helper: Reset for testing
  void reset() {
    _status = PaymentTerminalStatus.ready;
    _transactionCounter = 1000;
    _transactionHistory.clear();
    debugPrint('🔄 Payment terminal reset');
  }

  /// Helper: Get today's approved transactions
  List<PaymentTransaction> getTodayApprovedTransactions() {
    final today = DateTime.now();
    return _transactionHistory.where((t) {
      return t.timestamp.year == today.year &&
          t.timestamp.month == today.month &&
          t.timestamp.day == today.day &&
          t.status == TransactionStatus.approved;
    }).toList();
  }
}
