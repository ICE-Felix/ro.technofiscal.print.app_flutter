# Payment Terminal (POS) Integration (Mock Implementation)

## Overview

This feature implements a **mock payment terminal service** with support for card and cash payments, transaction tracking, and daily reporting. The mock implementation simulates all payment terminal operations for development and testing, providing a foundation for real hardware POS integration.

## Architecture

### 1. Payment Terminal Service Interface (`lib/core/services/payment_terminal_service.dart`)

**Abstract Interface (`PaymentTerminalService`):**
```dart
abstract class PaymentTerminalService {
  Future<PaymentTerminalStatus> getStatus();
  Future<bool> isReady();
  Future<PaymentTransaction> processCardPayment({...});
  Future<PaymentTransaction> processCashPayment({...});
  Future<void> cancelTransaction();
  List<PaymentTransaction> getTransactionHistory();
  PaymentTransaction? getTransaction(String transactionId);
  void clearHistory();
  Future<Map<String, dynamic>> getDailyTotals();
}
```

**Data Models:**

**PaymentTransaction:**
- transactionId (format: PAY{YYYYMMDD}-{NNNNNN} for card, CASH{YYYYMMDD}-{NNNNNN} for cash)
- amount (Romanian LEI)
- paymentMethod (card, cash, mixed)
- status (pending, approved, declined, cancelled, timeout, error)
- timestamp
- cardLastFourDigits (for card payments)
- cardType (chip, contactless)
- authorizationCode (6-character alphanumeric)
- errorMessage
- cashReceived, cashChange (for cash payments)

**Enums:**
- `PaymentTerminalStatus`: ready, processing, offline, error, waitingForCard, waitingForPin, waitingForCash
- `PaymentMethodType`: card, cash, mixed
- `CardType`: chip (CHIP & PIN), contactless (NFC), unknown
- `TransactionStatus`: pending, approved, declined, cancelled, timeout, error

### 2. Mock Payment Terminal Service (`MockPaymentTerminalService`)

**Singleton implementation** for development:

**Card Payment Flow:**
```dart
// Simulated card payment
processCardPayment(amount: 50.00, allowContactless: true)
  ↓
1. Check terminal ready
2. Generate transaction ID: PAY20250115-001234
3. Determine card type:
   - Contactless: if amount ≤ 100 RON and random
   - CHIP & PIN: otherwise
4. Simulate card presentation (1 second)
5. Simulate PIN entry if CHIP (2 seconds)
6. Process payment (1.5 seconds)
7. Random outcome:
   - 95% success → approved with auth code
   - 5% failure → declined
8. Return transaction
```

**Cash Payment Flow:**
```dart
// Simulated cash payment
processCashPayment(amount: 50.00, cashReceived: 100.00)
  ↓
1. Check terminal ready
2. Validate: cashReceived >= amount
3. Generate transaction ID: CASH20250115-001234
4. Simulate cash acceptance (1 second)
5. Calculate change: 50.00 RON
6. Process payment (0.5 seconds)
7. Return transaction (always approved for valid cash)
```

**Mock Configuration:**
- Contactless limit: 100 RON (Romanian standard)
- Success rate: 95% (5% random failures for testing)
- Transaction ID format: PAY/CASH{YYYYMMDD}-{counter}
- Authorization codes: 6 random alphanumeric characters

### 3. UI Components (`lib/core/widgets/payment_terminal_widget.dart`)

**PaymentTerminalStatusWidget:**
- Displays terminal status icon with color coding
- Shows current status text
- Test payment buttons (card/cash) when ready
- Status-specific visual feedback

**TransactionListWidget:**
- Lists all payment transactions
- Reverse chronological order (newest first)
- Icons for payment method and card type
- Status badges (approved, declined, etc.)
- Transaction details (ID, timestamp, amount)
- Clear history button

**DailyTotalsWidget:**
- Total daily revenue display
- Card vs. cash breakdown
- Transaction count by method
- Visual cards with color coding

### 4. Payment Terminal Page (`lib/features/contract_generation/presentation/pages/payment_terminal_page.dart`)

Full-featured payment management:
- **Left Panel**: Terminal status, daily totals, quick actions
- **Right Panel**: Transaction history
- **Features**:
  - Test card payments with amount input
  - Test cash payments with change calculation
  - Real-time transaction list
  - Daily report generation
  - Transaction history management
  - Terminal reset
  - Auto-refresh every 2 seconds

## Payment Flows

### Card Payment Flow

```
User clicks "Test Card"
    ↓
Dialog opens with amount input (default: 50 RON)
    ↓
User enters amount and clicks "Procesează"
    ↓
Terminal status: Waiting for card (1 second)
    ↓
Card type determined:
  - Amount ≤ 100 RON + random → Contactless
  - Otherwise → CHIP & PIN
    ↓
If CHIP & PIN:
  Terminal status: Waiting for PIN (2 seconds)
    ↓
Terminal status: Processing (1.5 seconds)
    ↓
Random outcome (95% success):
  Success:
    - Status: Approved
    - Generate auth code (e.g., "A3K7M9")
    - Card last 4 digits (e.g., "4523")
  Failure:
    - Status: Declined
    - Error: "Card refuzat de bancă"
    ↓
Result dialog shows:
  - Transaction ID
  - Amount
  - Card details
  - Authorization code (if approved)
    ↓
Transaction added to history
    ↓
User clicks "OK" to close
```

### Cash Payment Flow

```
User clicks "Test Numerar"
    ↓
Dialog opens with:
  - Amount to pay (default: 50 RON)
  - Cash received (default: 100 RON)
  - Change calculation (auto-updates)
    ↓
User adjusts amounts
    ↓
Change preview shows:
  - Green if cashReceived >= amount
  - Red if cashReceived < amount
    ↓
User clicks "Procesează"
    ↓
Terminal status: Waiting for cash (1 second)
    ↓
Terminal status: Processing (0.5 seconds)
    ↓
Calculate change: cashReceived - amount
    ↓
Result dialog shows:
  - Transaction ID
  - Amount
  - Cash received
  - Change to give (highlighted)
    ↓
Transaction added to history
    ↓
User clicks "OK" to close
```

### Daily Report

```
User clicks "Raport Zilnic"
    ↓
System calculates today's totals:
  - Total transactions count
  - Card transactions + total
  - Cash transactions + total
  - Approved count
  - Declined count
  - Grand total
    ↓
Dialog displays report with:
  - Date
  - Breakdown by payment method
  - Success/failure statistics
  - Grand total (highlighted)
```

## Mock Behavior

### Card Payment Simulation

**Contactless Payment:**
- Triggers when: amount ≤ 100 RON AND random decision
- Process time: 1 second (card) + 1.5 seconds (processing) = 2.5 seconds
- No PIN required
- Card type: contactless

**CHIP & PIN Payment:**
- Triggers when: amount > 100 RON OR random decision
- Process time: 1 second (card) + 2 seconds (PIN) + 1.5 seconds (processing) = 4.5 seconds
- PIN entry required
- Card type: chip

**Success/Failure:**
- 95% chance: Approved with 6-character auth code
- 5% chance: Declined with error message

### Cash Payment Simulation

**Always Successful:**
- If cashReceived >= amount
- Process time: 1 second (acceptance) + 0.5 seconds (processing) = 1.5 seconds
- Automatic change calculation
- No failures (validated upfront)

### Transaction IDs

**Format:**
- Card: `PAY{YYYYMMDD}-{NNNNNN}` (e.g., PAY20250115-001234)
- Cash: `CASH{YYYYMMDD}-{NNNNNN}` (e.g., CASH20250115-001234)
- Counter increments for each transaction

### Daily Totals

**Calculated per day:**
```dart
{
  'date': DateTime,
  'totalTransactions': int,
  'totalAmount': double,
  'cardTransactions': int,
  'cardTotal': double,
  'cashTransactions': int,
  'cashTotal': double,
  'approvedCount': int,
  'declinedCount': int,
}
```

## UI Design

### Payment Terminal Status

```
┌────────────────────────────────────────┐
│ ✓  Terminal de Plată                  │
│    Pregătit                            │
│                                        │
│    [Test Card]    [Test Numerar]      │
└────────────────────────────────────────┘
```

### Transaction List

```
┌────────────────────────────────────────┐
│ 💳 PAY20250115-001234     50.00 RON   │
│    **** 4523 • Contactless  [Aprobată]│
│    15.01.2025 14:32:15                │
├────────────────────────────────────────┤
│ 💵 CASH20250115-001235   100.00 RON   │
│    Numerar • Rest: 50.00   [Aprobată] │
│    15.01.2025 14:35:22                │
└────────────────────────────────────────┘
```

### Card Payment Dialog

```
┌─────────────────────────────────────────┐
│ 💳  Plată cu Card              [X]     │
├─────────────────────────────────────────┤
│ Sumă (RON): [    50.00    ]            │
│                                         │
│ ⏳ Procesare plată...                   │
│    Vă rugăm să introduceți cardul      │
│                                         │
│         [Anulează]  [Procesează]       │
└─────────────────────────────────────────┘
```

### Cash Payment Dialog

```
┌─────────────────────────────────────────┐
│ 💵  Plată cu Numerar           [X]     │
├─────────────────────────────────────────┤
│ Sumă de plată (RON): [  50.00  ]       │
│ Sumă primită (RON):  [ 100.00  ]       │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ Rest:              50.00 RON        │ │ ← Green highlight
│ └─────────────────────────────────────┘ │
│                                         │
│         [Anulează]  [Procesează]       │
└─────────────────────────────────────────┘
```

### Result Dialog (Success)

```
┌─────────────────────────────────────────┐
│ ✓  Plată Aprobată              [X]     │
├─────────────────────────────────────────┤
│ ID Tranzacție:    PAY20250115-001234   │
│ Sumă:             50.00 RON            │
│ Card:             **** 4523            │
│ Tip:              Contactless          │
│ Cod Autorizare:   A3K7M9               │
│                                         │
│                    [OK]                 │
└─────────────────────────────────────────┘
```

### Daily Report Dialog

```
┌─────────────────────────────────────────┐
│ 📊  Raport Zilnic              [X]     │
├─────────────────────────────────────────┤
│ Data: 15.01.2025                       │
│                                         │
│ Total Tranzacții:               25     │
│ ────────────────────────────────────   │
│ Tranzacții Card:                15     │
│ Total Card:             750.00 RON     │
│ ────────────────────────────────────   │
│ Tranzacții Numerar:             10     │
│ Total Numerar:          500.00 RON     │
│ ────────────────────────────────────   │
│ Aprobate:                       24     │
│ Refuzate:                        1     │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ TOTAL GENERAL:    1,250.00 RON     │ │ ← Purple highlight
│ └─────────────────────────────────────┘ │
│                                         │
│                  [Închide]              │
└─────────────────────────────────────────┘
```

## Features

### ✅ Implemented

**Payment Processing:**
- ✅ Card payments (CHIP & PIN, Contactless)
- ✅ Cash payments with change calculation
- ✅ Transaction ID generation
- ✅ Authorization codes
- ✅ Success/failure simulation

**Transaction Management:**
- ✅ Transaction history tracking
- ✅ Transaction search by ID
- ✅ History clearing
- ✅ Daily totals calculation
- ✅ Real-time updates

**Card Payment Features:**
- ✅ Contactless detection (≤100 RON limit)
- ✅ CHIP & PIN flow
- ✅ PIN entry simulation
- ✅ Card last 4 digits
- ✅ Random approval/decline (95%/5%)

**Cash Payment Features:**
- ✅ Change calculation
- ✅ Validation (received >= amount)
- ✅ Always approved for valid amounts
- ✅ Real-time change preview

**UI Components:**
- ✅ Terminal status widget
- ✅ Transaction list widget
- ✅ Daily totals widget
- ✅ Payment dialogs (card/cash)
- ✅ Result dialogs
- ✅ Daily report dialog

### 🔄 Mock Limitations

**What's Simulated:**
- ⚠️ Card reader interaction (delays)
- ⚠️ PIN entry (2-second delay)
- ⚠️ Payment processing (1.5-second delay)
- ⚠️ Random card declines (5% error rate)
- ⚠️ Authorization code generation

**Not Implemented:**
- ❌ Real POS hardware connection
- ❌ Actual card processing
- ❌ Bank communication
- ❌ Real authorization
- ❌ EMV chip reading
- ❌ NFC contactless reading
- ❌ Receipt printer integration (see fiscal printer for receipts)

## Real Hardware Integration

To replace mock with real POS terminals:

### Option 1: Platform Channels (Native SDK)

**Common POS SDKs:**
- **Ingenico** (Telium TETRA SDK)
- **Verifone** (VeriShield SDK)
- **PAX Technology** (PAXSTORE SDK)
- **SumUp** (SumUp SDK)

**Android Integration:**
```kotlin
// android/app/src/main/kotlin/.../PaymentChannel.kt
class PaymentChannel : MethodCallHandler {
  private val posTerminal: POSTerminal

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "processCardPayment" -> {
        val amount = call.argument<Double>("amount")!!
        val transaction = posTerminal.startTransaction(amount)
        result.success(mapOf(
          "transactionId" to transaction.id,
          "status" to transaction.status,
          "authCode" to transaction.authCode,
          "cardLastFour" to transaction.cardMasked
        ))
      }
    }
  }
}
```

**Flutter Service:**
```dart
class NativePaymentTerminalService implements PaymentTerminalService {
  static const platform = MethodChannel('payment_terminal');

  @override
  Future<PaymentTransaction> processCardPayment({
    required double amount,
    bool allowContactless = true,
  }) async {
    final result = await platform.invokeMethod('processCardPayment', {
      'amount': amount,
      'allowContactless': allowContactless,
    });

    return PaymentTransaction(
      transactionId: result['transactionId'],
      amount: amount,
      status: _parseStatus(result['status']),
      // ...
    );
  }
}
```

### Option 2: Network/IP POS Terminals

**For standalone POS devices:**

```dart
import 'dart:io';
import 'dart:convert';

class NetworkPOSService implements PaymentTerminalService {
  final String _terminalIp = '192.168.1.100';
  final int _terminalPort = 8080;

  @override
  Future<PaymentTransaction> processCardPayment({
    required double amount,
    bool allowContactless = true,
  }) async {
    // Connect to POS terminal
    final socket = await Socket.connect(_terminalIp, _terminalPort);

    // Send payment request
    final request = jsonEncode({
      'command': 'PAYMENT',
      'amount': (amount * 100).toInt(), // Cents
      'currency': 'RON',
      'allowContactless': allowContactless,
    });

    socket.write(request);

    // Wait for response
    final response = await socket.first;
    final data = jsonDecode(utf8.decode(response));

    socket.close();

    return PaymentTransaction(
      transactionId: data['transactionId'],
      amount: amount,
      status: _parseStatus(data['status']),
      cardLastFourDigits: data['cardMasked'],
      authorizationCode: data['authCode'],
      // ...
    );
  }
}
```

### Option 3: USB/Serial POS Terminals

**Using serial communication:**

```yaml
dependencies:
  flutter_libserialport: ^0.4.0
```

```dart
import 'package:flutter_libserialport/flutter_libserialport.dart';

class SerialPOSService implements PaymentTerminalService {
  late SerialPort _port;

  Future<void> initialize() async {
    // Find POS terminal on serial port
    final availablePorts = SerialPort.availablePorts;
    _port = SerialPort(availablePorts.first);

    _port.openReadWrite();
    _port.config = SerialPortConfig()
      ..baudRate = 9600
      ..bits = 8
      ..parity = SerialPortParity.none;
  }

  @override
  Future<PaymentTransaction> processCardPayment({...}) async {
    // Send command to POS terminal
    final command = _buildPaymentCommand(amount);
    _port.write(Uint8List.fromList(command));

    // Read response
    final reader = SerialPortReader(_port);
    final response = await reader.stream.first;

    return _parseResponse(response);
  }
}
```

### Option 4: SumUp SDK (Romanian Market)

**Popular in Romania for mobile POS:**

```yaml
dependencies:
  sumup_flutter_sdk: ^1.0.0
```

```dart
import 'package:sumup_flutter_sdk/sumup_flutter_sdk.dart';

class SumUpPaymentService implements PaymentTerminalService {
  final SumupFlutterSdk _sumup = SumupFlutterSdk();

  Future<void> initialize() async {
    await _sumup.login('YOUR_API_KEY');
  }

  @override
  Future<PaymentTransaction> processCardPayment({
    required double amount,
    bool allowContactless = true,
  }) async {
    final checkout = SumupPayment(
      total: amount,
      currency: 'RON',
      title: 'Contract Payment',
    );

    final response = await _sumup.checkout(checkout);

    return PaymentTransaction(
      transactionId: response.transactionCode,
      amount: amount,
      status: response.success
        ? TransactionStatus.approved
        : TransactionStatus.declined,
      cardLastFourDigits: response.card.last4,
      cardType: response.card.type == 'contactless'
        ? CardType.contactless
        : CardType.chip,
      authorizationCode: response.transactionCode,
      timestamp: DateTime.now(),
      paymentMethod: PaymentMethodType.card,
    );
  }
}
```

## Integration with Contract Flow

**Payment after contract generation:**

```dart
// In single_field_flow_page.dart or checkout page

Future<void> _processPayment(double amount) async {
  final paymentService = MockPaymentTerminalService();

  // Show payment method selection
  final method = await showDialog<PaymentMethodType>(
    context: context,
    builder: (context) => PaymentMethodDialog(),
  );

  if (method == null) return;

  try {
    PaymentTransaction transaction;

    if (method == PaymentMethodType.card) {
      transaction = await paymentService.processCardPayment(
        amount: amount,
        allowContactless: true,
      );
    } else {
      // Show cash input dialog
      final cashReceived = await _getCashAmount(amount);
      transaction = await paymentService.processCashPayment(
        amount: amount,
        cashReceived: cashReceived,
      );
    }

    if (transaction.status == TransactionStatus.approved) {
      // Payment successful
      // Generate fiscal receipt
      // Print contract
      // Show success
    } else {
      // Payment failed
      // Show error and retry
    }
  } catch (e) {
    // Handle error
  }
}
```

## Testing

### Test Card Payments

1. **Run app**: `flutter run`
2. **Navigate**: Home → Payment Terminal
3. **Test contactless**: Amount ≤ 100 RON → might get contactless
4. **Test CHIP & PIN**: Amount > 100 RON → always CHIP & PIN
5. **Watch status**: Ready → Waiting for card → Waiting for PIN (if CHIP) → Processing → Ready
6. **Check result**: 95% approved, 5% declined

### Test Cash Payments

1. **Click "Test Numerar"**
2. **Enter amount**: e.g., 50.00 RON
3. **Enter received**: e.g., 100.00 RON
4. **Check change**: Should show 50.00 RON
5. **Process**: Always successful if received >= amount

### Test Daily Report

1. **Process several transactions** (mix of card/cash)
2. **Click "Raport Zilnic"**
3. **Verify totals**: Card + Cash = Total
4. **Check counts**: Transaction counts match

## Romanian Compliance

**Currency:**
- All amounts in Romanian LEI (RON)
- Format: `NumberFormat.currency(locale: 'ro_RO', symbol: 'RON')`

**Contactless Limit:**
- 100 RON standard limit (as per Romanian banking regulations)
- Above this limit requires PIN

**Transaction Records:**
- Sequential IDs per day
- Timestamp in Romanian format (dd.MM.yyyy HH:mm:ss)
- Full audit trail

**Integration:**
- Works with FiscalPrinterService for compliant receipts
- Transaction data can be exported for accounting

## Performance

**Mock Service:**
- Card payment processing: 2.5-4.5 seconds
- Cash payment processing: 1.5 seconds
- Transaction lookup: Instant
- Daily totals calculation: ~100ms
- Memory usage: ~1-2MB for transaction history

## File Structure

```
lib/
├── core/
│   ├── services/
│   │   └── payment_terminal_service.dart    # Interface + Mock
│   └── widgets/
│       └── payment_terminal_widget.dart     # UI components
└── features/
    └── contract_generation/
        ├── presentation/
        │   └── pages/
        │       └── payment_terminal_page.dart
        └── PAYMENT_TERMINAL_README.md        # This file
```

## Next Steps

### Short Term (Mock Enhancements)
- [ ] Add partial payments (mixed card/cash)
- [ ] Implement refund transactions
- [ ] Add tip functionality
- [ ] Transaction receipt printing (integrate with fiscal printer)
- [ ] Persistent transaction storage

### Long Term (Real Hardware)
- [ ] Implement platform channels for native POS SDKs
- [ ] Ingenico terminal integration
- [ ] Verifone terminal integration
- [ ] SumUp mobile POS integration
- [ ] Network POS terminal support
- [ ] EMV certification
- [ ] PCI DSS compliance
- [ ] Bank integration for settlement

---

**Status**: ✅ Mock implementation complete
**Production Ready**: ⚠️ Requires real POS hardware integration
**Version**: 1.0 (Mock)
**Last Updated**: January 2025
