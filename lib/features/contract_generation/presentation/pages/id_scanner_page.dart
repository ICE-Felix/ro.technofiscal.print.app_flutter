import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/services/id_scanner_service.dart';
import '../../../../core/widgets/id_scanner_widget.dart';
import '../../../../core/style/app_colors.dart';

/// ID Scanner Page
class IDScannerPage extends StatefulWidget {
  const IDScannerPage({super.key});

  @override
  State<IDScannerPage> createState() => _IDScannerPageState();
}

class _IDScannerPageState extends State<IDScannerPage> {
  final _scannerService = MockIDScannerService();
  IDScannerStatus _status = IDScannerStatus.ready;
  List<IDScanResult> _scanHistory = [];
  RomanianIDCard? _currentCard;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    final status = await _scannerService.getStatus();
    final history = _scannerService.getScanHistory();

    if (mounted) {
      setState(() {
        _status = status;
        _scanHistory = history;
      });
    }
  }

  Future<void> _scanIDCard() async {
    try {
      setState(() => _currentCard = null);

      final result = await _scannerService.scanIDCard();

      if (!mounted) return;

      if (result.success && result.idCard != null) {
        setState(() => _currentCard = result.idCard);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Carte de identitate scanată cu succes!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result.errorMessage}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _cancelScan() async {
    try {
      await _scannerService.cancelScan();
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scanare anulată'),
            backgroundColor: AppColors.gray500,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Șterge Istoric'),
        content: const Text(
          'Sigur doriți să ștergeți istoricul scanărilor?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anulează'),
          ),
          ElevatedButton(
            onPressed: () {
              _scannerService.clearHistory();
              setState(() {
                _currentCard = null;
                _scanHistory = [];
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Șterge'),
          ),
        ],
      ),
    );
  }

  void _useIDCardData(RomanianIDCard idCard) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Text('Date Folosite'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Datele au fost extrase cu succes din cartea de identitate:',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✓ ${idCard.numeComplet}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('✓ CNP: ${idCard.cnp}'),
                  Text('✓ ${idCard.adresaCompleta}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'În aplicația reală, aceste date ar fi folosite pentru completarea automată a contractului.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showManualEntryDialog() {
    final nameController = TextEditingController();
    final cnpController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test cu Date Personalizate'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nume (opțional)',
                  hintText: 'Ex: POPESCU',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cnpController,
                decoration: const InputDecoration(
                  labelText: 'CNP (opțional)',
                  hintText: 'Ex: 1850512345678',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 13,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anulează'),
          ),
          ElevatedButton(
            onPressed: () {
              final testCard = _scannerService.createTestIDCard(
                nume: nameController.text.isEmpty
                    ? null
                    : nameController.text.toUpperCase(),
                cnp: cnpController.text.isEmpty ? null : cnpController.text,
              );

              setState(() => _currentCard = testCard);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Cartea de test a fost generată!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kioskBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Generează'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner Carte de Identitate'),
        backgroundColor: AppColors.kioskBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.science),
            onPressed: _showManualEntryDialog,
            tooltip: 'Test cu date personalizate',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Reîmprospătare',
          ),
        ],
      ),
      body: Row(
        children: [
          // Left panel - Scanner and current card
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  IDScannerStatusWidget(
                    status: _status,
                    onScan: _scanIDCard,
                    onCancel: _cancelScan,
                  ),
                  const SizedBox(height: 16),
                  if (_status == IDScannerStatus.scanning ||
                      _status == IDScannerStatus.processing)
                    _buildScanningIndicator(),
                  if (_currentCard != null) ...[
                    IDCardDisplayWidget(
                      idCard: _currentCard!,
                      onEdit: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Editarea este disponibilă în aplicația reală',
                            ),
                          ),
                        );
                      },
                      onUse: () => _useIDCardData(_currentCard!),
                    ),
                  ],
                  if (_currentCard == null &&
                      _status != IDScannerStatus.scanning &&
                      _status != IDScannerStatus.processing)
                    _buildInstructions(),
                ],
              ),
            ),
          ),

          const VerticalDivider(width: 1),

          // Right panel - Scan history
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: ScanHistoryWidget(
                scanHistory: _scanHistory,
                onSelectCard: (card) {
                  setState(() => _currentCard = card);
                },
                onClearHistory: _clearHistory,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningIndicator() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation(AppColors.kioskBlue),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _status == IDScannerStatus.scanning
                  ? 'Scanare carte de identitate...'
                  : 'Procesare date OCR...',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _status == IDScannerStatus.scanning
                  ? 'Vă rugăm să mențineți cardul pe scanner'
                  : 'Se extrag datele din imagine',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.kioskBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.badge,
                size: 64,
                color: AppColors.kioskBlue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Instrucțiuni Scanare',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInstructionItem(
              '1',
              'Plasați cartea de identitate pe scanner',
              Icons.credit_card,
            ),
            _buildInstructionItem(
              '2',
              'Apăsați butonul "Scanare CI"',
              Icons.camera_alt,
            ),
            _buildInstructionItem(
              '3',
              'Așteptați procesarea automată a datelor',
              Icons.sync,
            ),
            _buildInstructionItem(
              '4',
              'Verificați și folosiți datele extrase',
              Icons.check_circle,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: AppColors.warning, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Aceasta este o implementare mock. Scanarea și OCR sunt simulate.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.kioskBlue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, color: AppColors.kioskBlue, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
