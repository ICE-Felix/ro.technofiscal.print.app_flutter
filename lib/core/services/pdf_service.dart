import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

/// Service for PDF generation and printing operations
class PdfService {
  /// Generate and save PDF to file
  /// Returns the file path where PDF was saved
  static Future<String> generateAndSavePdf({
    required pw.Document pdf,
    required String fileName,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      return file.path;
    } catch (e) {
      throw Exception('Failed to save PDF: $e');
    }
  }

  /// Print PDF directly (shows print dialog)
  static Future<bool> printPdf(pw.Document pdf) async {
    try {
      return await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      throw Exception('Failed to print PDF: $e');
    }
  }

  /// Share PDF file
  static Future<void> sharePdf({
    required pw.Document pdf,
    required String fileName,
  }) async {
    try {
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: fileName,
      );
    } catch (e) {
      throw Exception('Failed to share PDF: $e');
    }
  }

  /// Get formatted current date
  static String getFormattedDate() {
    return DateFormat('dd MMMM yyyy', 'ro').format(DateTime.now());
  }

  /// Get formatted current time
  static String getFormattedTime() {
    return DateFormat('HH:mm', 'ro').format(DateTime.now());
  }

  /// Get contract number (timestamp-based)
  static String generateContractNumber() {
    final now = DateTime.now();
    return 'CNT-${DateFormat('yyyyMMdd-HHmmss').format(now)}';
  }
}
