import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../core/style/app_colors.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/services/printer_service.dart';

/// Dialog with PDF actions after contract generation
class PdfActionDialog extends StatelessWidget {
  final pw.Document pdf;
  final String fileName;
  final VoidCallback? onNewContract;

  const PdfActionDialog({
    super.key,
    required this.pdf,
    required this.fileName,
    this.onNewContract,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'Contract generat cu succes!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Subtitle
            Text(
              'Contractul dumneavoastră a fost creat și este gata pentru tipărire',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                // Save PDF button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await _savePdf(context);
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Salvează PDF'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Print button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _printPdf(context);
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Tipărește'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kioskBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Share button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await _sharePdf(context);
                },
                icon: const Icon(Icons.share),
                label: const Text('Partajează'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Divider
            const Divider(),
            const SizedBox(height: 16),

            // New contract button
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onNewContract?.call();
                },
                icon: const Icon(Icons.add),
                label: const Text('Contract nou'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePdf(BuildContext context) async {
    try {
      final filePath = await PdfService.generateAndSavePdf(
        pdf: pdf,
        fileName: fileName,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF salvat: $filePath'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la salvare: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _printPdf(BuildContext context) async {
    try {
      // Get printer service
      final printerService = MockPrinterService();

      // Check if printer is ready
      final defaultPrinter = await printerService.getDefaultPrinter();
      if (defaultPrinter == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nicio imprimantă disponibilă'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final isReady = await printerService.isPrinterReady(defaultPrinter.id);
      if (!isReady) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Imprimanta ${defaultPrinter.name} nu este pregătită'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

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

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document trimis la imprimantă\nJob ID: $jobId'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la tipărire: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _sharePdf(BuildContext context) async {
    try {
      await PdfService.sharePdf(
        pdf: pdf,
        fileName: fileName,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la partajare: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
