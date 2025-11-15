import 'package:flutter/material.dart';
import '../services/printer_service.dart';
import '../style/app_colors.dart';

/// Widget to display printer status
class PrinterStatusWidget extends StatefulWidget {
  final PrinterInfo printer;
  final VoidCallback? onTap;

  const PrinterStatusWidget({
    super.key,
    required this.printer,
    this.onTap,
  });

  @override
  State<PrinterStatusWidget> createState() => _PrinterStatusWidgetState();
}

class _PrinterStatusWidgetState extends State<PrinterStatusWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.printer.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (widget.printer.isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.kioskBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'DEFAULT',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.kioskBlue,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.printer.model,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (widget.printer.ipAddress != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.printer.ipAddress!,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildLevelIndicator(
                      icon: Icons.description,
                      label: 'Paper',
                      level: widget.printer.paperLevel,
                      color: _getPaperLevelColor(widget.printer.paperLevel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildLevelIndicator(
                      icon: Icons.opacity,
                      label: 'Ink',
                      level: widget.printer.inkLevel,
                      color: _getInkLevelColor(widget.printer.inkLevel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;

    switch (widget.printer.status) {
      case PrinterStatus.ready:
        icon = Icons.check_circle;
        color = AppColors.success;
        break;
      case PrinterStatus.printing:
        icon = Icons.print;
        color = AppColors.kioskBlue;
        break;
      case PrinterStatus.offline:
        icon = Icons.cloud_off;
        color = AppColors.gray500;
        break;
      case PrinterStatus.error:
      case PrinterStatus.paperJam:
        icon = Icons.error;
        color = AppColors.error;
        break;
      case PrinterStatus.outOfPaper:
        icon = Icons.warning;
        color = AppColors.warning;
        break;
      case PrinterStatus.lowInk:
        icon = Icons.warning_amber;
        color = AppColors.warning;
        break;
      default:
        icon = Icons.help_outline;
        color = AppColors.gray500;
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

  Widget _buildLevelIndicator({
    required IconData icon,
    required String label,
    required int level,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              '$level%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: level / 100,
            backgroundColor: AppColors.gray200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Color _getPaperLevelColor(int level) {
    if (level > 50) return AppColors.success;
    if (level > 20) return AppColors.warning;
    return AppColors.error;
  }

  Color _getInkLevelColor(int level) {
    if (level > 30) return AppColors.success;
    if (level > 10) return AppColors.warning;
    return AppColors.error;
  }
}

/// Print queue display widget
class PrintQueueWidget extends StatelessWidget {
  final List<PrintJob> queue;
  final Function(String)? onCancelJob;

  const PrintQueueWidget({
    super.key,
    required this.queue,
    this.onCancelJob,
  });

  @override
  Widget build(BuildContext context) {
    if (queue.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.print_disabled, size: 64, color: AppColors.gray400),
              SizedBox(height: 16),
              Text(
                'No print jobs',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: queue.length,
      itemBuilder: (context, index) {
        final job = queue[index];
        return _PrintJobTile(
          job: job,
          onCancel: onCancelJob != null ? () => onCancelJob!(job.id) : null,
        );
      },
    );
  }
}

class _PrintJobTile extends StatelessWidget {
  final PrintJob job;
  final VoidCallback? onCancel;

  const _PrintJobTile({
    required this.job,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: _buildStatusIcon(),
        title: Text(
          job.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(_getStatusText()),
        trailing: job.status == PrintJobStatus.queued && onCancel != null
            ? IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: onCancel,
                tooltip: 'Cancel',
              )
            : null,
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;

    switch (job.status) {
      case PrintJobStatus.queued:
        icon = Icons.schedule;
        color = AppColors.gray600;
        break;
      case PrintJobStatus.printing:
        icon = Icons.print;
        color = AppColors.kioskBlue;
        break;
      case PrintJobStatus.completed:
        icon = Icons.check_circle;
        color = AppColors.success;
        break;
      case PrintJobStatus.failed:
        icon = Icons.error;
        color = AppColors.error;
        break;
      case PrintJobStatus.cancelled:
        icon = Icons.cancel;
        color = AppColors.gray500;
        break;
    }

    return Icon(icon, color: color);
  }

  String _getStatusText() {
    switch (job.status) {
      case PrintJobStatus.queued:
        return 'Queued - ${job.copies} ${job.copies == 1 ? 'copy' : 'copies'}';
      case PrintJobStatus.printing:
        return 'Printing...';
      case PrintJobStatus.completed:
        return 'Completed';
      case PrintJobStatus.failed:
        return 'Failed: ${job.errorMessage ?? 'Unknown error'}';
      case PrintJobStatus.cancelled:
        return 'Cancelled';
    }
  }
}
