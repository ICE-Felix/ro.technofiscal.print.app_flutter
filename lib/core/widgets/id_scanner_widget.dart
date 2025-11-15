import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/id_scanner_service.dart';
import '../style/app_colors.dart';

/// Widget to display ID scanner status
class IDScannerStatusWidget extends StatelessWidget {
  final IDScannerStatus status;
  final VoidCallback? onScan;
  final VoidCallback? onCancel;

  const IDScannerStatusWidget({
    super.key,
    required this.status,
    this.onScan,
    this.onCancel,
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
                        'Scanner Carte de Identitate',
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
                if (status == IDScannerStatus.ready && onScan != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onScan,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Scanare CI'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.kioskBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),
                if ((status == IDScannerStatus.scanning ||
                        status == IDScannerStatus.processing) &&
                    onCancel != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.cancel),
                      label: const Text('Anulează'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
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
      case IDScannerStatus.ready:
        icon = Icons.check_circle;
        color = AppColors.success;
        break;
      case IDScannerStatus.scanning:
        icon = Icons.camera_alt;
        color = AppColors.warning;
        break;
      case IDScannerStatus.processing:
        icon = Icons.sync;
        color = AppColors.kioskBlue;
        break;
      case IDScannerStatus.offline:
        icon = Icons.cloud_off;
        color = AppColors.gray500;
        break;
      case IDScannerStatus.error:
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

  String _getStatusText() {
    switch (status) {
      case IDScannerStatus.ready:
        return 'Pregătit pentru scanare';
      case IDScannerStatus.scanning:
        return 'Scanare în curs...';
      case IDScannerStatus.processing:
        return 'Procesare OCR...';
      case IDScannerStatus.offline:
        return 'Offline';
      case IDScannerStatus.error:
        return 'Eroare';
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case IDScannerStatus.ready:
        return AppColors.success;
      case IDScannerStatus.scanning:
        return AppColors.warning;
      case IDScannerStatus.processing:
        return AppColors.kioskBlue;
      case IDScannerStatus.offline:
        return AppColors.gray500;
      case IDScannerStatus.error:
        return AppColors.error;
    }
  }
}

/// Widget to display scanned ID card data
class IDCardDisplayWidget extends StatelessWidget {
  final RomanianIDCard idCard;
  final VoidCallback? onEdit;
  final VoidCallback? onUse;

  const IDCardDisplayWidget({
    super.key,
    required this.idCard,
    this.onEdit,
    this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.kioskBlue.withOpacity(0.05),
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: idCard.isValid ? AppColors.success : AppColors.error,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.kioskBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.badge,
                    color: AppColors.kioskBlue,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CARTE DE IDENTITATE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        idCard.numarCI,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: idCard.isValid
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: idCard.isValid ? AppColors.success : AppColors.error,
                    ),
                  ),
                  child: Text(
                    idCard.isValid ? 'VALABIL' : 'EXPIRAT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: idCard.isValid ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            // Personal information
            const Text(
              'DATE PERSONALE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            _buildInfoRow('Nume:', idCard.nume),
            _buildInfoRow('Prenume:', idCard.prenume),
            _buildInfoRow('CNP:', idCard.cnp),
            _buildInfoRow('Gen:', idCard.gen),
            _buildInfoRow('Vârstă:', '${idCard.varsta} ani'),
            _buildInfoRow('Data nașterii:', dateFormat.format(idCard.dataNasterii)),
            _buildInfoRow('Loc naștere:', idCard.locNastere),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Address
            const Text(
              'DOMICILIU',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            _buildInfoRow('Adresă:', idCard.adresaCompleta, maxLines: 3),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Validity
            const Text(
              'VALABILITATE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            _buildInfoRow('Data emiterii:', dateFormat.format(idCard.dataEmiterii)),
            _buildInfoRow('Data expirării:', dateFormat.format(idCard.dataExpirarii)),
            _buildInfoRow('Emitent:', idCard.emitentCI, maxLines: 2),

            if (onEdit != null || onUse != null) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  if (onEdit != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit),
                        label: const Text('Editează'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.kioskBlue,
                        ),
                      ),
                    ),
                  if (onEdit != null && onUse != null) const SizedBox(width: 12),
                  if (onUse != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onUse,
                        icon: const Icon(Icons.check),
                        label: const Text('Folosește Datele'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
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
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget to display scan history
class ScanHistoryWidget extends StatelessWidget {
  final List<IDScanResult> scanHistory;
  final void Function(RomanianIDCard)? onSelectCard;
  final VoidCallback? onClearHistory;

  const ScanHistoryWidget({
    super.key,
    required this.scanHistory,
    this.onSelectCard,
    this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Istoric Scanări',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (scanHistory.isNotEmpty && onClearHistory != null)
                  TextButton.icon(
                    onPressed: onClearHistory,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Șterge'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (scanHistory.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: 48,
                      color: AppColors.gray400,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Nicio scanare efectuată',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: scanHistory.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final result = scanHistory[scanHistory.length - 1 - index];
                  return _buildScanResultItem(result);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScanResultItem(IDScanResult result) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm:ss');

    if (!result.success) {
      return ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 24,
          ),
        ),
        title: const Text(
          'Scanare eșuată',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              result.errorMessage ?? 'Eroare necunoscută',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              dateFormat.format(result.timestamp),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final idCard = result.idCard!;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.badge,
          color: AppColors.success,
          size: 24,
        ),
      ),
      title: Text(
        idCard.numeComplet,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            'CNP: ${idCard.cnp} • CI: ${idCard.numarCI}',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            dateFormat.format(result.timestamp),
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      trailing: onSelectCard != null
          ? IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () => onSelectCard!(idCard),
              color: AppColors.kioskBlue,
            )
          : null,
    );
  }
}
