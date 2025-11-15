import 'package:flutter/material.dart';
import '../../../../core/style/app_colors.dart';
import '../../data/models/contract_model.dart';
import '../../data/models/order_model.dart';
import 'order_summary_card.dart';
import 'payment_method_selector.dart';
import 'terms_acceptance_card.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final ContractModel contract;
  final Function(OrderModel order)? onProceedToPayment;
  final VoidCallback? onBack;
  final VoidCallback? onPreview;
  final VoidCallback? onSaveDraft;
  final Function(int step)? onEditStep;

  const OrderConfirmationScreen({
    super.key,
    required this.contract,
    this.onProceedToPayment,
    this.onBack,
    this.onPreview,
    this.onSaveDraft,
    this.onEditStep,
  });

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  late OrderModel _order;

  @override
  void initState() {
    super.initState();
    _order = const OrderModel();
  }

  void _updateOrder(OrderModel newOrder) {
    setState(() {
      _order = newOrder;
    });
  }

  bool get _canProceed => _order.termsAccepted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: Column(
        children: [
          // Header
          _buildHeader(),

          // Content
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column - Contract Details
                Expanded(
                  flex: 2,
                  child: _buildContractDetailsColumn(),
                ),

                // Right Column - Order Summary
                SizedBox(
                  width: 400,
                  child: _buildOrderSummaryColumn(),
                ),
              ],
            ),
          ),

          // Footer
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.blue50,
            AppColors.blue100.withOpacity(0.5),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review all information before generating your contract',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.gray600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractDetailsColumn() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Seller Information
          _buildInfoCard(
            title: 'Seller Information',
            icon: Icons.person_outline,
            color: AppColors.kioskBlue,
            onEdit: () => widget.onEditStep?.call(0),
            children: [
              _buildInfoGrid([
                _InfoItem('Full Name', widget.contract.seller.fullName),
                _InfoItem('CNP/CUI', widget.contract.seller.cnp),
                if (widget.contract.seller.idSeries.isNotEmpty)
                  _InfoItem(
                    'ID Card',
                    '${widget.contract.seller.idSeries} ${widget.contract.seller.idNumber}',
                  ),
                _InfoItem('Phone Number', widget.contract.seller.phone),
                if (widget.contract.seller.email.isNotEmpty)
                  _InfoItem('Email', widget.contract.seller.email),
                _InfoItem(
                  'Address',
                  '${widget.contract.seller.address.street} ${widget.contract.seller.address.streetNumber}, '
                  '${widget.contract.seller.address.city}, ${widget.contract.seller.address.county}',
                ),
              ]),
            ],
          ),
          const SizedBox(height: 16),

          // Buyer Information
          _buildInfoCard(
            title: 'Buyer Information',
            icon: Icons.person,
            color: const Color(0xFF9333EA), // Purple
            onEdit: () => widget.onEditStep?.call(1),
            children: [
              _buildInfoGrid([
                _InfoItem('Full Name', widget.contract.buyer.fullName),
                _InfoItem('CNP/CUI', widget.contract.buyer.cnp),
                if (widget.contract.buyer.idSeries.isNotEmpty)
                  _InfoItem(
                    'ID Card',
                    '${widget.contract.buyer.idSeries} ${widget.contract.buyer.idNumber}',
                  ),
                _InfoItem('Phone Number', widget.contract.buyer.phone),
                if (widget.contract.buyer.email.isNotEmpty)
                  _InfoItem('Email', widget.contract.buyer.email),
                _InfoItem(
                  'Address',
                  '${widget.contract.buyer.address.street} ${widget.contract.buyer.address.streetNumber}, '
                  '${widget.contract.buyer.address.city}, ${widget.contract.buyer.address.county}',
                ),
              ]),
            ],
          ),
          const SizedBox(height: 16),

          // Object Details
          _buildInfoCard(
            title: 'Object Details',
            icon: Icons.inventory_2_outlined,
            color: AppColors.kioskGreen,
            onEdit: () => widget.onEditStep?.call(2),
            children: [
              Text(
                widget.contract.objectDetails,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Contract Details
          _buildInfoCard(
            title: 'Contract Details',
            icon: Icons.description_outlined,
            color: const Color(0xFFEA580C), // Orange
            onEdit: () => widget.onEditStep?.call(3),
            children: [
              _buildInfoGrid([
                _InfoItem(
                  'Sale Price',
                  '${widget.contract.price.toStringAsFixed(2)} RON',
                ),
              ]),
              const SizedBox(height: 12),
              Text(
                widget.contract.contractDetails,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Verification Notice
          _buildVerificationNotice(),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryColumn() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: AppColors.gray200),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            OrderSummaryCard(
              order: _order,
              onCopiesChanged: (copies) {
                _updateOrder(_order.copyWith(numberOfCopies: copies));
              },
            ),
            const SizedBox(height: 24),

            PaymentMethodSelector(
              selectedMethod: _order.paymentMethod,
              onMethodChanged: (method) {
                _updateOrder(_order.copyWith(paymentMethod: method));
              },
            ),
            const SizedBox(height: 24),

            TermsAcceptanceCard(
              isAccepted: _order.termsAccepted,
              onChanged: (accepted) {
                _updateOrder(_order.copyWith(termsAccepted: accepted));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.gray200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          OutlinedButton.icon(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),

          // Action Buttons
          Row(
            children: [
              if (widget.onPreview != null)
                OutlinedButton.icon(
                  onPressed: widget.onPreview,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Preview'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  ),
                ),
              const SizedBox(width: 12),
              if (widget.onSaveDraft != null)
                OutlinedButton.icon(
                  onPressed: widget.onSaveDraft,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save Draft'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  ),
                ),
              const SizedBox(width: 24),
              ElevatedButton.icon(
                onPressed: _canProceed
                    ? () => widget.onProceedToPayment?.call(_order)
                    : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Proceed to Payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kioskGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  disabledBackgroundColor: AppColors.gray300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
    VoidCallback? onEdit,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.8)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, color: Colors.white),
                    tooltip: 'Edit',
                  ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(List<_InfoItem> items) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildInfoItem(items[i])),
                if (i + 1 < items.length) ...[
                  const SizedBox(width: 24),
                  Expanded(child: _buildInfoItem(items[i + 1])),
                ] else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInfoItem(_InfoItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.gray500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationNotice() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.blue50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.kioskBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.kioskBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Final Verification',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please review all information carefully. Once you proceed to payment, '
                  'the contract will be generated and printed. Make sure all details are correct before confirming.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.gray700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;

  _InfoItem(this.label, this.value);
}
