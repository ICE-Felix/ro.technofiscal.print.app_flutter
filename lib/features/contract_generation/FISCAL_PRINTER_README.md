# Fiscal Printer Integration (Mock - Romanian ANAF Compliance)

## Overview

This feature implements a **mock fiscal printer service** compliant with Romanian ANAF (Agenția Națională de Administrare Fiscală) regulations for fiscal receipt generation. The mock implementation simulates all fiscal operations for development and testing.

## Romanian Fiscal Requirements

### ANAF Compliance

Romanian law requires businesses to use fiscal printers (case de marcat fiscale) that:
- ✅ Generate unique fiscal receipt numbers
- ✅ Store receipts in tamper-proof fiscal memory
- ✅ Calculate and display VAT (TVA) separately
- ✅ Generate daily Z Reports (fiscal day closing)
- ✅ Include fiscal code (CIF) on receipts
- ✅ Maintain sequential receipt numbering
- ✅ Cannot be modified or deleted after printing

## Architecture

### 1. Fiscal Printer Service (`lib/core/services/fiscal_printer_service.dart`)

**Data Models:**

**FiscalReceipt:**
- Receipt number (Nr. Bon)
- Fiscal code (CIF)
- Fiscal memory number
- Date/time
- Receipt type (sale, refund, invoice, proforma, cancelled)
- Line items with VAT calculation
- Payment method (cash, card, transfer, voucher)
- Operator information

**FiscalReceiptItem:**
- Item name
- Quantity
- Unit price
- VAT rate (standard 19%, reduced 9%, reduced 5%, exempt 0%)
- Item code

**FiscalDailyReport (Z/X Report):**
- Report number
- Date
- Number of receipts
- Total sales
- Total refunds
- Net revenue
- VAT breakdown by rate
- Payments by method

**Enums:**
```dart
enum FiscalPrinterStatus {
  ready, printing, offline, fiscalMemoryFull,
  fiscalDayOpen, fiscalDayClosed, error
}

enum ReceiptType {
  sale,        // Bon de vânzare
  refund,      // Bon de retur
  invoice,     // Factură
  proforma,    // Factură proformă
  cancelled    // Anulat
}

enum FiscalPaymentMethod {
  cash,        // Numerar
  card,        // Card bancar
  transfer,    // Transfer bancar
  voucher      // Voucher/Bon valoric
}

enum VATRate {
  standard(19.0),   // Cotă standard 19%
  reduced(9.0),     // Cotă redusă 9%
  reduced5(5.0),    // Cotă redusă 5%
  exempt(0.0)       // Scutit de TVA
}
```

**Service Interface:**
```dart
abstract class FiscalPrinterService {
  Future<FiscalPrinterStatus> getStatus();
  Future<bool> isFiscalDayOpen();
  Future<void> openFiscalDay();
  Future<FiscalDailyReport> closeFiscalDay();
  Future<String> printFiscalReceipt(FiscalReceipt receipt);
  Future<void> printReceiptCopy(String receiptNumber);
  Future<void> cancelReceipt(String receiptNumber);
  Future<FiscalDailyReport> getDailyReport();
  Future<Map<String, dynamic>> getFiscalMemoryInfo();
  Future<String> getLastReceiptNumber();
}
```

### 2. Mock Implementation (`MockFiscalPrinterService`)

**Singleton service** for development:

**Mock Configuration:**
- Fiscal Code (CIF): `RO12345678`
- Fiscal Memory Number: `FM001234567890`
- Operator: `Administrator (OP001)`
- Receipt counter starts at: `1000`

**Simulated Operations:**
- ✅ Fiscal receipt printing (~800ms + 2s processing)
- ✅ Daily Z Report generation (closes fiscal day)
- ✅ Daily X Report (intermediate report, day stays open)
- ✅ Fiscal day open/close operations
- ✅ Receipt storage in memory
- ✅ VAT calculation by rate
- ✅ Payment method tracking

### 3. UI Components

**FiscalReceiptPreview** (`lib/core/widgets/fiscal_receipt_widget.dart`):
- Professional fiscal receipt display
- Romanian legal format
- VAT breakdown by rate
- Payment method display
- Receipt footer with legal notice

**FiscalPrinterStatusWidget**:
- Printer status indicator
- Fiscal day status (open/closed)
- Open/Close day buttons
- Visual status with color coding

**FiscalPrinterPage** (`lib/features/contract_generation/presentation/pages/fiscal_printer_page.dart`):
- Full fiscal printer management
- **Left Panel**: Status, memory info, actions
- **Right Panel**: Today's receipts list
- Z/X Report generation
- Test receipt printing
- Receipt details view

## Fiscal Receipt Format

### Romanian Legal Receipt Template

```
============================================
          BON FISCAL - ROMANIA
============================================

Nr. Bon: F20250115-001234
CIF: RO12345678
Nr. Mem. Fiscală: FM001234567890
Data: 15.01.2025 14:30:45
Operator: Administrator

============================================

Contract Vânzare-Cumpărare Autovehicul
  1 x 50.00 RON
  TVA 19%: 7.98 RON
  TOTAL: 50.00 RON

--------------------------------------------

SUBTOTAL (fără TVA): 42.02 RON

TVA pe cote:
  19%: 7.98 RON

TOTAL TVA: 7.98 RON

============================================
TOTAL DE PLATĂ: 50.00 RON
============================================

Metodă de plată: NUMERAR

--------------------------------------------
Vă mulțumim pentru cumpărături!
Bonul fiscal este valabil pentru garanție
============================================
```

### VAT Calculation (TVA)

Romanian VAT rates:
- **19% (Standard)**: Most goods and services
- **9% (Reduced)**: Food, medicine, hotels, restaurants
- **5% (Reduced)**: Social housing, books, newspapers
- **0% (Exempt)**: Exports, certain financial services

**Calculation Example:**
```
Unit Price (with VAT): 50.00 RON
VAT Rate: 19%

Net Amount = 50.00 / 1.19 = 42.02 RON
VAT Amount = 50.00 - 42.02 = 7.98 RON

On receipt:
  SUBTOTAL (fără TVA): 42.02 RON
  TOTAL TVA (19%):     7.98 RON
  TOTAL DE PLATĂ:     50.00 RON
```

## Daily Reports

### Z Report (Închidere Zi Fiscală)

**Purpose**: Close fiscal day, mandatory at end of business day

**Generated automatically when closing day:**
```
Raport Z - Închidere Zi Fiscală
Nr. Raport: Z20250115
Data: 15.01.2025 22:00

Nr. Bonuri: 45
Vânzări Totale: 2,250.00 RON
Returnări: 0.00 RON
Venit Net: 2,250.00 RON

TVA pe Cote:
  19%: 358.82 RON
  9%: 41.18 RON

Plăți pe Metode:
  Numerar: 1,500.00 RON
  Card: 750.00 RON
```

**After Z Report:**
- Fiscal day is closed
- Cannot print more receipts until new day opened
- Receipt counter resets for new day

### X Report (Raport Intermediar)

**Purpose**: Check current sales without closing day

**Can be generated anytime:**
```
Raport X - Situație Curentă
Nr. Raport: X20250115-143045
Data: 15.01.2025 14:30

Nr. Bonuri: 23
Vânzări Totale: 1,150.00 RON
...
```

**After X Report:**
- Fiscal day remains open
- Can continue printing receipts
- Used for shift changes, monitoring

## User Flows

### Print Fiscal Receipt (Contract Payment)

```
User completes contract
    ↓
Clicks "Pay and Generate Receipt"
    ↓
System checks fiscal day open
    ↓
Creates fiscal receipt:
  - Item: "Contract Vânzare-Cumpărare"
  - Amount: 50.00 RON
  - VAT: 19% (7.98 RON)
  - Payment: Cash/Card
    ↓
Generates unique receipt number
  Format: F{YYYYMMDD}-{NNNNNN}
  Example: F20250115-001234
    ↓
Stores in fiscal memory
    ↓
Simulates printing (2.8 seconds total)
    ↓
Returns receipt number
    ↓
User receives:
  - Contract PDF
  - Fiscal receipt
```

### Open Fiscal Day

```
Start of business day
    ↓
Navigate to Fiscal Printer page
    ↓
Click "Deschide Ziua"
    ↓
System:
  - Opens new fiscal day
  - Resets receipt counter
  - Clears previous day receipts
  - Status → Fiscal Day Open
    ↓
Ready to issue receipts
```

### Close Fiscal Day (Z Report)

```
End of business day
    ↓
Click "Închide Ziua (Z)"
    ↓
Confirmation dialog appears
    ↓
User confirms
    ↓
System generates Z Report:
  - Totals all day's receipts
  - Calculates VAT by rate
  - Groups payments by method
  - Generates report number
    ↓
Prints Z Report
    ↓
Closes fiscal day
    ↓
Status → Fiscal Day Closed
    ↓
Cannot print receipts until next day
```

### View Daily Report (X Report)

```
During business day
    ↓
Click "Raport X (Situație)"
    ↓
System generates X Report:
  - Current totals
  - Receipts so far
  - VAT and payments
    ↓
Displays in dialog
    ↓
Option to print
    ↓
Day remains open
```

## Integration with Contract Flow

### Contract Payment + Fiscal Receipt

```dart
// After contract PDF generation
Future<void> _generateFiscalReceipt({
  required ContractModel contract,
  required FiscalPaymentMethod paymentMethod,
}) async {
  final fiscalService = MockFiscalPrinterService();

  // Check fiscal day open
  if (!await fiscalService.isFiscalDayOpen()) {
    throw Exception('Fiscal day closed');
  }

  // Create receipt
  final receipt = FiscalReceipt(
    receiptNumber: '', // Generated by service
    fiscalCode: '',
    fiscalMemoryNumber: '',
    dateTime: DateTime.now(),
    type: ReceiptType.sale,
    items: [
      FiscalReceiptItem(
        name: 'Contract Vânzare-Cumpărare Autovehicul',
        quantity: 1,
        unitPrice: 50.0, // Service price
        vatRate: VATRate.standard,
        code: 'SRV001',
      ),
    ],
    paymentMethod: paymentMethod,
  );

  // Print fiscal receipt
  final receiptNumber = await fiscalService.printFiscalReceipt(receipt);

  return receiptNumber;
}
```

## Mock Behavior

### Receipt Numbering

Format: `F{YYYYMMDD}-{NNNNNN}`

Examples:
- `F20250115-001001` (First receipt of day)
- `F20250115-001002` (Second receipt)
- `F20250116-001001` (Next day, counter resets)

### Fiscal Memory

**Simulated Storage:**
- Capacity: 100,000 receipts
- Current: Based on counter
- Percentage: Displayed in UI
- Warning at 90% full

### Status Transitions

```
App Start → Ready / Fiscal Day Open
    ↓
Print Receipt → Printing (2s) → Ready
    ↓
Close Day → Fiscal Day Closed
    ↓
Open Day → Fiscal Day Open → Ready
```

## Features

### ✅ Implemented

**Fiscal Compliance:**
- ✅ ANAF-compliant receipt format
- ✅ Romanian VAT calculation (19%, 9%, 5%, 0%)
- ✅ Unique fiscal receipt numbers
- ✅ Fiscal memory storage
- ✅ Sequential numbering
- ✅ Fiscal code (CIF) display
- ✅ Z Report (daily closing)
- ✅ X Report (intermediate)

**Operations:**
- ✅ Print fiscal receipts
- ✅ Open/close fiscal day
- ✅ Generate reports
- ✅ Receipt storage
- ✅ VAT breakdown
- ✅ Payment tracking
- ✅ Operator information

**UI:**
- ✅ Fiscal receipt preview
- ✅ Printer status widget
- ✅ Fiscal printer management page
- ✅ Z/X report dialogs
- ✅ Today's receipts list
- ✅ Fiscal memory info
- ✅ Test receipt printing

### 🔄 Mock Limitations

**What's Simulated:**
- ⚠️ Receipt printing (delayed completion)
- ⚠️ Fiscal memory (in-memory storage)
- ⚠️ Day open/close (state management)
- ⚠️ Reports (calculated from stored receipts)

**Not Implemented:**
- ❌ Real fiscal printer hardware
- ❌ Actual fiscal memory chip
- ❌ Physical receipt printing
- ❌ Government reporting
- ❌ ANAF server integration

## Real Hardware Integration

### Option 1: Romanian Fiscal Printer Manufacturers

**Datecs:**
```dart
import 'package:datecs_printer/datecs_printer.dart';

class DatecsFiscalService implements FiscalPrinterService {
  final DatecsPrinter _printer;

  @override
  Future<String> printFiscalReceipt(FiscalReceipt receipt) async {
    await _printer.openFiscalReceipt();

    for (final item in receipt.items) {
      await _printer.sellItem(
        description: item.name,
        quantity: item.quantity,
        price: item.unitPrice,
        vatGroup: _mapVatRate(item.vatRate),
      );
    }

    return await _printer.closeFiscalReceipt(
      paymentType: _mapPaymentMethod(receipt.paymentMethod),
    );
  }
}
```

**Tremol:**
```dart
import 'package:tremol_fiscal/tremol_fiscal.dart';

class TremolFiscalService implements FiscalPrinterService {
  // Similar implementation for Tremol printers
}
```

### Option 2: ESC/POS with Fiscal Module

```dart
import 'package:esc_pos_printer/esc_pos_printer.dart';

class ESCPOSFiscalService implements FiscalPrinterService {
  final NetworkPrinter _printer;

  Future<void> _printFiscalReceipt(FiscalReceipt receipt) async {
    // Custom ESC/POS commands for fiscal format
    _printer.text('BON FISCAL - ROMANIA');
    _printer.feed(1);
    _printer.text('Nr. Bon: ${receipt.receiptNumber}');
    // ... etc
  }
}
```

### Option 3: Platform Channels (Native Integration)

**Android (Kotlin):**
```kotlin
class FiscalPrinterChannel {
  fun connectFiscalPrinter(): Boolean {
    // Use manufacturer's Android SDK
    val printer = DatecsFiscalDevice()
    return printer.connect()
  }

  fun printReceipt(receiptData: Map<String, Any>): String {
    // Print using native SDK
    return receiptNumber
  }
}
```

**Integration:**
```dart
class NativeFiscalService implements FiscalPrinterService {
  static const platform = MethodChannel('fiscal_printer');

  @override
  Future<String> printFiscalReceipt(FiscalReceipt receipt) async {
    return await platform.invokeMethod('printReceipt', {
      'items': receipt.items.map((i) => {...}),
      'payment': receipt.paymentMethod.name,
    });
  }
}
```

## Testing

### Test Fiscal Receipt

1. **Run app**: `flutter run`
2. **Navigate**: Fiscal Printer page (`/fiscal-printer`)
3. **Check status**: Day should be open
4. **Click**: "Bon Fiscal Test"
5. **Verify**: Receipt appears in list
6. **Click receipt**: View details

### Test Z Report

1. **Print some receipts**: Use test button
2. **Click**: "Închide Ziua (Z)"
3. **Confirm**: Close fiscal day
4. **View report**: See totals, VAT, payments
5. **Verify**: Day is now closed
6. **Try print**: Should fail (day closed)

### Test X Report

1. **Print some receipts**
2. **Click**: "Raport X (Situație)"
3. **View report**: Current totals
4. **Verify**: Day still open
5. **Can print**: More receipts

## File Structure

```
lib/
├── core/
│   ├── services/
│   │   └── fiscal_printer_service.dart    # Interface + Mock
│   └── widgets/
│       └── fiscal_receipt_widget.dart     # UI components
└── features/
    └── contract_generation/
        ├── presentation/
        │   └── pages/
        │       └── fiscal_printer_page.dart
        └── FISCAL_PRINTER_README.md        # This file
```

## Legal Compliance

### Romanian Fiscal Printer Laws

According to Romanian fiscal legislation (Codul Fiscal):

**Requirements:**
- ✅ Use certified fiscal printers (case de marcat fiscale omologate ANAF)
- ✅ Generate sequential receipt numbers
- ✅ Store receipts in fiscal memory (cannot be deleted)
- ✅ Display VAT separately on receipts
- ✅ Include fiscal code (CIF) on receipts
- ✅ Generate daily Z Reports
- ✅ Keep receipts for 10 years

**Penalties for Non-Compliance:**
- Using non-certified printers: 5,000 - 10,000 RON fine
- Not issuing receipts: 10,000 - 20,000 RON fine
- Tampering with fiscal memory: Criminal offense

### Certification

For production use, printers must be:
- ANAF certified (homologated)
- Registered with tax authority
- Serviced by authorized technicians
- Subject to periodic inspections

## Next Steps

### Short Term (Mock Enhancements)
- [ ] Receipt copy printing
- [ ] Receipt cancellation
- [ ] Refund receipt support
- [ ] Invoice generation
- [ ] Receipt templates

### Long Term (Real Hardware)
- [ ] Datecs fiscal printer integration
- [ ] Tremol fiscal printer support
- [ ] ANAF online reporting
- [ ] Electronic invoice (eFactură)
- [ ] Receipt QR codes for verification
- [ ] Cloud backup of fiscal memory

---

**Status**: ✅ Mock implementation complete (ANAF compliant format)
**Production Ready**: ⚠️ Requires certified fiscal printer hardware
**Version**: 1.0 (Mock)
**Last Updated**: January 2025
