import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/style/app_colors.dart';
import '../../data/models/contract_model.dart';
import '../../data/models/order_completion_model.dart';

class OrderCompletionPage extends StatelessWidget {
  final ContractModel contract;
  final OrderCompletionModel completion;
  final VoidCallback? onNewContract;
  final VoidCallback? onEmailCopy;
  final VoidCallback? onSavePdf;
  final VoidCallback? onHelp;

  const OrderCompletionPage({
    super.key,
    required this.contract,
    required this.completion,
    this.onNewContract,
    this.onEmailCopy,
    this.onSavePdf,
    this.onHelp,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          _buildHeader(context),

          // Progress Bar
          _buildProgressBar(context),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Success Banner
                  _buildSuccessBanner(context),

                  // Order Details Section
                  _buildOrderDetailsSection(context),

                  // Contract Parties Section
                  _buildPartiesSection(context),

                  // Printing Options Section
                  _buildPrintingOptionsSection(context),

                  // Next Steps Section
                  _buildNextStepsSection(context),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Footer
          _buildFooter(context),

          // Status Bar
          _buildStatusBar(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final timeFormat = DateFormat.Hm();
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.gray200),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.description,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ContractKiosk',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray900,
                        ),
                  ),
                  Text(
                    'Document Generation & Printing',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray500,
                        ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Current Time',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray500,
                        ),
                  ),
                  Text(
                    timeFormat.format(DateTime.now()),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray900,
                        ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final steps = [
      'Seller Data',
      'Buyer Data',
      'Object Details',
      'Contract Details',
      'Complete',
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.gray200),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              for (int i = 0; i < steps.length; i++) ...[
                // Step indicator
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      steps[i],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: i == steps.length - 1
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: i == steps.length - 1
                                ? AppColors.success
                                : AppColors.gray900,
                          ),
                    ),
                  ],
                ),
                // Connector line
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      color: AppColors.success,
                    ),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Process Complete',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.gray500,
                    ),
              ),
              Text(
                'Total time: ${completion.processingTimeMinutes} minutes',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.gray500,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner(BuildContext context) {
    final dateFormat = DateFormat.yMMMMd();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF10B981),
            Color(0xFF059669),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: AppColors.success,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Order Successful!',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your contract has been generated and is ready for printing',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFFD1FAE5),
                ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.schedule, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Processing time: ${completion.processingTimeMinutes} minutes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.calendar_today, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                dateFormat.format(completion.completionDate),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsSection(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contract Summary Card
              Expanded(
                child: _buildContractSummaryCard(context),
              ),
              const SizedBox(width: 32),
              // Vehicle/Object Details Card
              Expanded(
                child: _buildObjectDetailsCard(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContractSummaryCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Contract Summary',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900,
                    ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.description,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSummaryRow('Contract Type:', completion.contractType),
          _buildSummaryRow(
            'Contract ID:',
            completion.contractId,
            valueColor: AppColors.primary,
            valueStyle: const TextStyle(fontFamily: 'monospace'),
          ),
          _buildSummaryRow(
            'Pages Generated:',
            '${completion.numberOfPages} pages',
          ),
          _buildSummaryRow('Language:', completion.language),
          _buildSummaryRow(
            'Legal Compliance:',
            'Verified',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Verified',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectDetailsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Object Details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900,
                    ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.blue50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            contract.objectDetails,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  color: AppColors.gray700,
                ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            'Sale Price:',
            '€${contract.price.toStringAsFixed(2)}',
            valueColor: AppColors.primary,
            valueStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartiesSection(BuildContext context) {
    return Container(
      color: AppColors.gray50,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contract Parties',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seller Card
              Expanded(
                child: _buildPartyCard(
                  context,
                  title: 'Seller',
                  subtitle: 'Vehicle Owner',
                  party: contract.seller,
                  icon: Icons.person_outline,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 32),
              // Buyer Card
              Expanded(
                child: _buildPartyCard(
                  context,
                  title: 'Buyer',
                  subtitle: 'New Owner',
                  party: contract.buyer,
                  icon: Icons.person,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartyCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required party,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray900,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.gray500,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildPartyInfo('Full Name', party.fullName),
          _buildPartyInfo('ID Number', party.cnp),
          _buildPartyInfo(
            'Address',
            '${party.address.street} ${party.address.streetNumber}, '
            '${party.address.city}, ${party.address.county}',
          ),
          _buildPartyInfo('Contact', party.phone),
        ],
      ),
    );
  }

  Widget _buildPartyInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.gray500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrintingOptionsSection(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Printing & Document Options',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              // Print Copies Card
              Expanded(
                child: _buildPrintCopiesCard(context),
              ),
              const SizedBox(width: 24),
              // Document Format Card
              Expanded(
                child: _buildDocumentFormatCard(context),
              ),
              const SizedBox(width: 24),
              // Delivery Options Card
              Expanded(
                child: _buildDeliveryOptionsCard(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrintCopiesCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Print Copies',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
              ),
              const Icon(
                Icons.print,
                color: AppColors.primary,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCopyRow('Seller Copy:', '${completion.sellerCopies} copy'),
          _buildCopyRow('Buyer Copy:', '${completion.buyerCopies} copy'),
          _buildCopyRow('Authority Copy:', '${completion.authorityCopies} copy'),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
              Text(
                '${completion.totalCopies} copies',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentFormatCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Document Format',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
              ),
              const Icon(
                Icons.picture_as_pdf,
                color: AppColors.error,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCopyRow('Format:', completion.documentFormat),
          _buildCopyRow('Paper Size:', completion.paperSize),
          _buildCopyRow('Quality:', completion.printQuality),
          _buildCopyRow('Color:', completion.colorMode),
        ],
      ),
    );
  }

  Widget _buildDeliveryOptionsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery Options',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
              ),
              const Icon(
                Icons.mail_outline,
                color: AppColors.warning,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatusRow(
            'Print:',
            'Ready',
            completion.printReady ? AppColors.success : AppColors.gray500,
          ),
          _buildStatusRow(
            'Email Copy:',
            completion.emailAvailable ? 'Sent' : 'Optional',
            completion.emailAvailable ? AppColors.success : AppColors.warning,
          ),
          _buildStatusRow(
            'Digital Archive:',
            completion.digitalArchiveSaved ? 'Saved' : 'Not Saved',
            completion.digitalArchiveSaved ? AppColors.success : AppColors.gray500,
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepsSection(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.blue50,
        border: Border(
          top: BorderSide(color: AppColors.blue100),
        ),
      ),
      padding: const EdgeInsets.all(32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.checklist,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Steps',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray900,
                      ),
                ),
                const SizedBox(height: 16),
                _buildNextStep(
                  context,
                  '1',
                  'Collect your printed contract copies from the printer tray',
                ),
                _buildNextStep(
                  context,
                  '2',
                  'Both parties should sign all copies in the designated areas',
                ),
                _buildNextStep(
                  context,
                  '3',
                  'Submit the authority copy to the local vehicle registration office',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStep(BuildContext context, String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.gray700,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      height: 96,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.gray200),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onEmailCopy,
                icon: const Icon(Icons.email_outlined),
                label: const Text('Email Copy'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  side: const BorderSide(color: AppColors.warning, width: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: onSavePdf,
                icon: const Icon(Icons.download_outlined),
                label: const Text('Save PDF'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onHelp,
                icon: const Icon(Icons.help_outline),
                label: const Text('Help'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: onNewContract,
                icon: const Icon(Icons.add),
                label: const Text('New Contract'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  elevation: 4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(BuildContext context) {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: AppColors.gray900,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Printing Complete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 24),
              const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                'Contract Generated',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'Session ID: ${completion.contractId}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? valueColor,
    TextStyle? valueStyle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.gray600,
              fontSize: 15,
            ),
          ),
          trailing ??
              Text(
                value,
                style: valueStyle ??
                    TextStyle(
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? AppColors.gray900,
                      fontSize: 15,
                    ),
              ),
        ],
      ),
    );
  }

  Widget _buildCopyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.gray600,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.gray600,
              fontSize: 14,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
