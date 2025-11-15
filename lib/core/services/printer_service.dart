import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// Printer status enumeration
enum PrinterStatus {
  ready,
  printing,
  offline,
  error,
  outOfPaper,
  paperJam,
  lowInk,
  unknown,
}

/// Print job status
enum PrintJobStatus {
  queued,
  printing,
  completed,
  failed,
  cancelled,
}

/// Print quality settings
enum PrintQuality {
  draft,
  normal,
  high,
}

/// Paper size options
enum PaperSize {
  a4,
  a5,
  receipt,
  custom,
}

/// Print job model
class PrintJob {
  final String id;
  final String name;
  final Uint8List data;
  final int copies;
  final PrintQuality quality;
  final PaperSize paperSize;
  final DateTime queuedAt;
  PrintJobStatus status;
  String? errorMessage;
  DateTime? startedAt;
  DateTime? completedAt;

  PrintJob({
    required this.id,
    required this.name,
    required this.data,
    this.copies = 1,
    this.quality = PrintQuality.normal,
    this.paperSize = PaperSize.a4,
    DateTime? queuedAt,
    this.status = PrintJobStatus.queued,
    this.errorMessage,
    this.startedAt,
    this.completedAt,
  }) : queuedAt = queuedAt ?? DateTime.now();

  /// Create a copy with updated fields
  PrintJob copyWith({
    PrintJobStatus? status,
    String? errorMessage,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return PrintJob(
      id: id,
      name: name,
      data: data,
      copies: copies,
      quality: quality,
      paperSize: paperSize,
      queuedAt: queuedAt,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Printer information model
class PrinterInfo {
  final String id;
  final String name;
  final String model;
  final PrinterStatus status;
  final int paperLevel; // 0-100
  final int inkLevel; // 0-100
  final String? ipAddress;
  final bool isDefault;

  const PrinterInfo({
    required this.id,
    required this.name,
    required this.model,
    required this.status,
    this.paperLevel = 100,
    this.inkLevel = 100,
    this.ipAddress,
    this.isDefault = false,
  });

  PrinterInfo copyWith({
    PrinterStatus? status,
    int? paperLevel,
    int? inkLevel,
  }) {
    return PrinterInfo(
      id: id,
      name: name,
      model: model,
      status: status ?? this.status,
      paperLevel: paperLevel ?? this.paperLevel,
      inkLevel: inkLevel ?? this.inkLevel,
      ipAddress: ipAddress,
      isDefault: isDefault,
    );
  }
}

/// Abstract printer service interface
/// Implement this for actual hardware integration
abstract class PrinterService {
  /// Get list of available printers
  Future<List<PrinterInfo>> getAvailablePrinters();

  /// Get default/selected printer
  Future<PrinterInfo?> getDefaultPrinter();

  /// Set default printer
  Future<void> setDefaultPrinter(String printerId);

  /// Get printer status
  Future<PrinterStatus> getPrinterStatus(String printerId);

  /// Check if printer is ready to print
  Future<bool> isPrinterReady(String printerId);

  /// Submit print job to queue
  Future<String> submitPrintJob(PrintJob job);

  /// Cancel print job
  Future<void> cancelPrintJob(String jobId);

  /// Get all print jobs
  List<PrintJob> getPrintQueue();

  /// Get specific print job
  PrintJob? getPrintJob(String jobId);

  /// Clear completed jobs from queue
  void clearCompletedJobs();

  /// Print PDF bytes directly
  Future<String> printPdf({
    required Uint8List pdfBytes,
    required String fileName,
    int copies = 1,
    PrintQuality quality = PrintQuality.normal,
    PaperSize paperSize = PaperSize.a4,
  });

  /// Test print (print test page)
  Future<void> testPrint(String printerId);
}

/// Mock printer service implementation for development/testing
class MockPrinterService implements PrinterService {
  static final MockPrinterService _instance = MockPrinterService._internal();
  factory MockPrinterService() => _instance;
  MockPrinterService._internal();

  final List<PrinterInfo> _mockPrinters = [
    const PrinterInfo(
      id: 'printer_1',
      name: 'HP LaserJet Pro M404dn',
      model: 'HP LaserJet Pro',
      status: PrinterStatus.ready,
      paperLevel: 85,
      inkLevel: 60,
      ipAddress: '192.168.1.100',
      isDefault: true,
    ),
    const PrinterInfo(
      id: 'printer_2',
      name: 'Epson Receipt Printer TM-T88VI',
      model: 'Epson TM-T88VI',
      status: PrinterStatus.ready,
      paperLevel: 40,
      inkLevel: 100,
      ipAddress: '192.168.1.101',
      isDefault: false,
    ),
  ];

  final List<PrintJob> _printQueue = [];
  String _defaultPrinterId = 'printer_1';

  @override
  Future<List<PrinterInfo>> getAvailablePrinters() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockPrinters;
  }

  @override
  Future<PrinterInfo?> getDefaultPrinter() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockPrinters.firstWhere(
      (p) => p.id == _defaultPrinterId,
      orElse: () => _mockPrinters.first,
    );
  }

  @override
  Future<void> setDefaultPrinter(String printerId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _defaultPrinterId = printerId;
    debugPrint('✅ Default printer set to: $printerId');
  }

  @override
  Future<PrinterStatus> getPrinterStatus(String printerId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final printer = _mockPrinters.firstWhere(
      (p) => p.id == printerId,
      orElse: () => _mockPrinters.first,
    );
    return printer.status;
  }

  @override
  Future<bool> isPrinterReady(String printerId) async {
    final status = await getPrinterStatus(printerId);
    return status == PrinterStatus.ready;
  }

  @override
  Future<String> submitPrintJob(PrintJob job) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Add to queue
    _printQueue.add(job);

    // Simulate printing in background
    _processPrintJob(job);

    debugPrint('📄 Print job submitted: ${job.id} - ${job.name}');
    return job.id;
  }

  @override
  Future<void> cancelPrintJob(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final jobIndex = _printQueue.indexWhere((j) => j.id == jobId);
    if (jobIndex != -1) {
      final job = _printQueue[jobIndex];
      if (job.status == PrintJobStatus.queued) {
        _printQueue[jobIndex] = job.copyWith(
          status: PrintJobStatus.cancelled,
          completedAt: DateTime.now(),
        );
        debugPrint('❌ Print job cancelled: $jobId');
      }
    }
  }

  @override
  List<PrintJob> getPrintQueue() {
    return List.unmodifiable(_printQueue);
  }

  @override
  PrintJob? getPrintJob(String jobId) {
    try {
      return _printQueue.firstWhere((j) => j.id == jobId);
    } catch (e) {
      return null;
    }
  }

  @override
  void clearCompletedJobs() {
    _printQueue.removeWhere(
      (job) =>
          job.status == PrintJobStatus.completed ||
          job.status == PrintJobStatus.cancelled ||
          job.status == PrintJobStatus.failed,
    );
    debugPrint('🗑️ Cleared completed print jobs');
  }

  @override
  Future<String> printPdf({
    required Uint8List pdfBytes,
    required String fileName,
    int copies = 1,
    PrintQuality quality = PrintQuality.normal,
    PaperSize paperSize = PaperSize.a4,
  }) async {
    final jobId = 'job_${DateTime.now().millisecondsSinceEpoch}';

    final job = PrintJob(
      id: jobId,
      name: fileName,
      data: pdfBytes,
      copies: copies,
      quality: quality,
      paperSize: paperSize,
    );

    return submitPrintJob(job);
  }

  @override
  Future<void> testPrint(String printerId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final testData = Uint8List.fromList(
      List.generate(100, (i) => i % 256),
    );

    final job = PrintJob(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Test Page',
      data: testData,
      copies: 1,
      quality: PrintQuality.draft,
    );

    await submitPrintJob(job);
    debugPrint('🖨️ Test print submitted for printer: $printerId');
  }

  /// Simulate print job processing
  Future<void> _processPrintJob(PrintJob job) async {
    // Update to printing status
    final jobIndex = _printQueue.indexWhere((j) => j.id == job.id);
    if (jobIndex == -1) return;

    await Future.delayed(const Duration(milliseconds: 500));

    _printQueue[jobIndex] = job.copyWith(
      status: PrintJobStatus.printing,
      startedAt: DateTime.now(),
    );

    debugPrint('🖨️ Printing: ${job.name}');

    // Simulate print time (3-6 seconds)
    final printTime = 3000 + (job.data.length % 3000);
    await Future.delayed(Duration(milliseconds: printTime));

    // Simulate occasional errors (5% chance)
    final hasError = DateTime.now().millisecond % 20 == 0;

    if (hasError) {
      _printQueue[jobIndex] = job.copyWith(
        status: PrintJobStatus.failed,
        errorMessage: 'Simulated print error - paper jam',
        completedAt: DateTime.now(),
      );
      debugPrint('❌ Print failed: ${job.name}');
    } else {
      _printQueue[jobIndex] = job.copyWith(
        status: PrintJobStatus.completed,
        completedAt: DateTime.now(),
      );
      debugPrint('✅ Print completed: ${job.name}');
    }
  }
}
