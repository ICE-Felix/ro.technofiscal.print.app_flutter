# Physical Printer Integration (Mock Implementation)

## Overview

This feature implements a **mock printer service** with print queue management, providing a foundation for real hardware printer integration. The mock implementation simulates all printer operations for development and testing.

## Architecture

### 1. Printer Service Interface (`lib/core/services/printer_service.dart`)

**Abstract Interface (`PrinterService`):**
```dart
abstract class PrinterService {
  Future<List<PrinterInfo>> getAvailablePrinters();
  Future<PrinterInfo?> getDefaultPrinter();
  Future<void> setDefaultPrinter(String printerId);
  Future<PrinterStatus> getPrinterStatus(String printerId);
  Future<bool> isPrinterReady(String printerId);
  Future<String> submitPrintJob(PrintJob job);
  Future<void> cancelPrintJob(String jobId);
  List<PrintJob> getPrintQueue();
  PrintJob? getPrintJob(String jobId);
  void clearCompletedJobs();
  Future<String> printPdf({...});
  Future<void> testPrint(String printerId);
}
```

**Data Models:**

**PrinterInfo:**
- id, name, model
- status (ready, printing, offline, error, etc.)
- paperLevel (0-100%)
- inkLevel (0-100%)
- ipAddress
- isDefault flag

**PrintJob:**
- id, name, data (PDF bytes)
- copies, quality, paperSize
- status (queued, printing, completed, failed, cancelled)
- timestamps (queued, started, completed)
- errorMessage

**Enums:**
- `PrinterStatus`: ready, printing, offline, error, outOfPaper, paperJam, lowInk, unknown
- `PrintJobStatus`: queued, printing, completed, failed, cancelled
- `PrintQuality`: draft, normal, high
- `PaperSize`: a4, a5, receipt, custom

### 2. Mock Printer Service (`MockPrinterService`)

**Singleton implementation** for development:

**Mock Printers:**
```dart
PrinterInfo(
  id: 'printer_1',
  name: 'HP LaserJet Pro M404dn',
  model: 'HP LaserJet Pro',
  status: PrinterStatus.ready,
  paperLevel: 85,
  inkLevel: 60,
  ipAddress: '192.168.1.100',
  isDefault: true,
),
PrinterInfo(
  id: 'printer_2',
  name: 'Epson Receipt Printer TM-T88VI',
  model: 'Epson TM-T88VI',
  status: PrinterStatus.ready,
  paperLevel: 40,
  inkLevel: 100,
  ipAddress: '192.168.1.101',
),
```

**Simulated Operations:**
- ✅ Print job queuing (200ms delay)
- ✅ Print processing (3-6 seconds per job)
- ✅ Status updates (queued → printing → completed)
- ✅ Random errors (5% failure rate for testing)
- ✅ Test page printing
- ✅ Queue management

### 3. UI Components (`lib/core/widgets/printer_status_widget.dart`)

**PrinterStatusWidget:**
- Displays printer info card
- Shows status icon with color coding
- Paper/ink level progress bars
- Default printer badge
- Tap to view details

**PrintQueueWidget:**
- Lists all print jobs
- Shows job status with icons
- Cancel button for queued jobs
- Empty state display

### 4. Printer Settings Page (`lib/features/contract_generation/presentation/pages/printer_settings_page.dart`)

Full-featured printer management:
- **Left Panel**: Available printers list
- **Right Panel**: Print queue
- **Features**:
  - View all printers
  - Check printer status
  - Set default printer
  - Test print functionality
  - View print queue in real-time
  - Cancel queued jobs
  - Clear completed jobs
  - Auto-refresh every 2 seconds

## Integration with PDF Generation

Updated PDF action dialog to use printer service:

```dart
Future<void> _printPdf(BuildContext context) async {
  final printerService = MockPrinterService();

  // Check printer availability
  final defaultPrinter = await printerService.getDefaultPrinter();

  // Check printer status
  final isReady = await printerService.isPrinterReady(defaultPrinter.id);

  // Get PDF bytes
  final pdfBytes = await pdf.save();

  // Submit print job
  final jobId = await printerService.printPdf(
    pdfBytes: pdfBytes,
    fileName: fileName,
    copies: 1,
    quality: PrintQuality.normal,
    paperSize: PaperSize.a4,
  );
}
```

## User Flows

### Print Contract

```
User generates contract PDF
    ↓
Clicks "Tipărește" button
    ↓
System checks default printer
    ↓
System checks printer status
    ↓
PDF bytes extracted
    ↓
Print job submitted to queue
    ↓
Job ID returned
    ↓
User sees confirmation: "Document trimis la imprimantă"
    ↓
Background processing:
  - Job status: queued → printing → completed
  - Takes 3-6 seconds
    ↓
Job appears in print queue widget
    ↓
Job marked as completed
```

### View Print Queue

```
User opens Printer Settings
    ↓
Left panel shows available printers:
  - HP LaserJet Pro (Default, Ready, 85% paper, 60% ink)
  - Epson Receipt Printer (Ready, 40% paper, 100% ink)
    ↓
Right panel shows print queue:
  - Active jobs (queued/printing)
  - Completed jobs
  - Failed jobs
    ↓
Auto-refreshes every 2 seconds
```

### Set Default Printer

```
User clicks printer card
    ↓
Details dialog opens
    ↓
User clicks "Set Default"
    ↓
Default printer updated
    ↓
Badge updates on printer card
```

### Test Print

```
User opens printer details
    ↓
Clicks "Test Print"
    ↓
Test page job submitted
    ↓
Job appears in queue
    ↓
Processes like normal print job
```

## Mock Behavior

### Print Job Processing

```dart
1. Job submitted → status: queued
   ↓ (500ms delay)
2. Status: printing, startedAt: now
   ↓ (3-6 second simulated print time)
3. Random outcome:
   - 95% success → status: completed
   - 5% failure → status: failed, error: "paper jam"
   ↓
4. completedAt: now
```

### Paper/Ink Levels

Currently static, future enhancement:
- Decrease levels with each print job
- Trigger low paper/ink warnings
- Block printing when out of supplies

## UI Design

### Printer Status Card

```
┌────────────────────────────────────────┐
│ ✓  HP LaserJet Pro M404dn    [DEFAULT] │
│    HP LaserJet Pro                     │
│    192.168.1.100                       │
│                                        │
│    📄 Paper: 85%  ▓▓▓▓▓▓▓▓░░ 85%      │
│    💧 Ink:   60%  ▓▓▓▓▓▓░░░░ 60%      │
└────────────────────────────────────────┘
```

### Print Queue

```
┌────────────────────────────────────┐
│ 🔷 Contract_CNT-20250115.pdf      │
│    Printing...                     │
├────────────────────────────────────┤
│ ⏰ Test Page                       │
│    Queued - 1 copy            [X]  │
├────────────────────────────────────┤
│ ✓  Contract_CNT-20250114.pdf      │
│    Completed                       │
└────────────────────────────────────┘
```

### Printer Details Dialog

```
┌─────────────────────────────────────┐
│ 🖨️  HP LaserJet Pro M404dn    [X]  │ ← Blue header
├─────────────────────────────────────┤
│ Status:        Ready                │
│ Paper Level:   85%                  │
│ Ink Level:     60%                  │
│ IP Address:    192.168.1.100        │
│                                     │
│ [Test Print]  [Set Default]         │ ← Buttons
└─────────────────────────────────────┘
```

## Features

### ✅ Implemented

**Printer Management:**
- ✅ Multiple printer support
- ✅ Default printer selection
- ✅ Printer status monitoring
- ✅ Paper/ink level display
- ✅ IP address tracking

**Print Queue:**
- ✅ Job queuing system
- ✅ Job status tracking
- ✅ Job cancellation
- ✅ Queue clearing
- ✅ Real-time updates

**Print Operations:**
- ✅ PDF printing
- ✅ Multiple copies support
- ✅ Quality settings
- ✅ Paper size selection
- ✅ Test printing

**UI Components:**
- ✅ Printer status cards
- ✅ Print queue widget
- ✅ Printer settings page
- ✅ Details dialog
- ✅ Visual status indicators

### 🔄 Mock Limitations

**What's Simulated:**
- ⚠️ Printer discovery (hardcoded printers)
- ⚠️ Print processing (delayed completion)
- ⚠️ Random failures (5% error rate)
- ⚠️ Static paper/ink levels

**Not Implemented:**
- ❌ Real printer hardware connection
- ❌ Actual print output
- ❌ Network printer discovery
- ❌ Dynamic paper/ink consumption
- ❌ Real error detection

## Real Hardware Integration

To replace mock with real printers:

### Option 1: Platform Channels (Native Code)

```dart
class NativePrinterService implements PrinterService {
  static const platform = MethodChannel('printer_channel');

  @override
  Future<List<PrinterInfo>> getAvailablePrinters() async {
    final result = await platform.invokeMethod('getprinters');
    return // parse native printer list
  }

  @override
  Future<String> printPdf({...}) async {
    return await platform.invokeMethod('print', {
      'data': pdfBytes,
      'printer': printerId,
      'copies': copies,
    });
  }
}
```

**Android (Kotlin):**
```kotlin
// android/app/src/main/kotlin/...
class PrinterChannel : MethodCallHandler {
  fun getPrinters(): List<Printer> {
    val printManager = context.getSystemService(Context.PRINT_SERVICE)
    // Use Android Print Framework
  }

  fun print(pdfBytes: ByteArray, printer: String) {
    // Submit print job to Android print service
  }
}
```

**iOS (Swift):**
```swift
// ios/Runner/PrinterChannel.swift
class PrinterChannel {
  func getPrinters() -> [UIPrinter] {
    // Use UIPrinterPickerController
  }

  func print(pdfData: Data, printer: UIPrinter) {
    // Use UIPrintInteractionController
  }
}
```

### Option 2: Flutter Plugins

**Recommended packages:**

```yaml
dependencies:
  # Cross-platform printing
  printing: ^5.13.2  # Already installed for PDF preview

  # Network printers
  pdf_printer: ^1.0.0  # ESC/POS thermal printers
  esc_pos_printer: ^4.1.0  # Receipt printers

  # Platform-specific
  flutter_pos_printer_platform: ^1.0.0
```

**Implementation:**
```dart
import 'package:printing/printing.dart';

class FlutterPrinterService implements PrinterService {
  @override
  Future<List<PrinterInfo>> getAvailablePrinters() async {
    // Use printing package's printer discovery
    final printers = await Printing.listPrinters();
    return printers.map((p) => PrinterInfo(...)).toList();
  }

  @override
  Future<String> printPdf({...}) async {
    await Printing.directPrintPdf(
      printer: await Printing.pickPrinter(),
      onLayout: (format) => pdfBytes,
    );
  }
}
```

### Option 3: Network/IP Printers

For ESC/POS thermal printers (receipts):

```dart
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

class NetworkPrinterService implements PrinterService {
  Future<void> printReceipt() async {
    final printer = NetworkPrinter(PaperSize.mm80, CapabilityProfile.load());

    final res = await printer.connect('192.168.1.100', port: 9100);

    if (res == PosPrintResult.success) {
      // Print commands
      printer.text('Contract Receipt');
      printer.feed(2);
      printer.cut();
      printer.disconnect();
    }
  }
}
```

## Replacing Mock with Real Implementation

```dart
// Current: lib/core/service_locator.dart
sl.registerLazySingleton<PrinterService>(() => MockPrinterService());

// Future: Switch to real implementation
sl.registerLazySingleton<PrinterService>(() => NativePrinterService());
// or
sl.registerLazySingleton<PrinterService>(() => FlutterPrinterService());
// or
sl.registerLazySingleton<PrinterService>(() => NetworkPrinterService());
```

## Testing

### Test Mock Printer

1. **Run app**: `flutter run`
2. **Navigate**: Home → Printer Settings
3. **View printers**: See 2 mock printers
4. **Print test**: Click printer → Test Print
5. **Watch queue**: Job appears, processes, completes
6. **Try errors**: Print multiple times to see occasional failures

### Test with PDF

1. **Generate contract**: Complete contract form
2. **Click "Tipărește"**
3. **Verify**: Print job submitted
4. **Check queue**: See job in printer settings
5. **Wait**: Job completes after 3-6 seconds

## Performance

**Mock Service:**
- Printer discovery: ~300ms
- Print job submission: ~200ms
- Print processing: 3-6 seconds
- Queue refresh: Instant
- Memory usage: Minimal (~1MB for queue)

## File Structure

```
lib/
├── core/
│   ├── services/
│   │   └── printer_service.dart           # Interface + Mock
│   └── widgets/
│       └── printer_status_widget.dart     # UI components
└── features/
    └── contract_generation/
        ├── presentation/
        │   ├── pages/
        │   │   └── printer_settings_page.dart
        │   └── widgets/
        │       └── pdf_action_dialog.dart  # Updated with printer
        └── PRINTER_INTEGRATION_README.md   # This file
```

## Next Steps

### Short Term (Mock Enhancements)
- [ ] Dynamic paper/ink consumption per print
- [ ] Paper/ink refill simulation
- [ ] More realistic error scenarios
- [ ] Print job history persistence

### Long Term (Real Hardware)
- [ ] Implement platform channels (Android/iOS)
- [ ] Network printer discovery
- [ ] ESC/POS thermal printer support
- [ ] Receipt printer integration
- [ ] Fiscal printer integration (Romania ANAF)
- [ ] Multi-printer job distribution
- [ ] Print job retrying on failure

---

**Status**: ✅ Mock implementation complete
**Production Ready**: ⚠️ Requires real hardware integration
**Version**: 1.0 (Mock)
**Last Updated**: January 2025
