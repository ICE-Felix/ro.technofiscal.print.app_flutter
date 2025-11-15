import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/contract_model.dart';
import '../../../../core/localization/app_localization.dart';

/// Checkout/Summary page for contract generation
/// This is the final step before payment and printing
class ContractCheckoutPage extends StatefulWidget {
  final ContractModel contract;
  final VoidCallback? onBack;
  final VoidCallback? onProceedToPayment;

  const ContractCheckoutPage({
    super.key,
    required this.contract,
    this.onBack,
    this.onProceedToPayment,
  });

  @override
  State<ContractCheckoutPage> createState() => _ContractCheckoutPageState();
}

class _ContractCheckoutPageState extends State<ContractCheckoutPage> {
  int _copiesToPrint = 2;
  String _selectedPaymentMethod = 'card'; // 'card' or 'cash'
  bool _termsAccepted = false;

  final double _printingFeePerCopy = 2.50; // €2.50 per copy
  final double _serviceFee = 10.00; // €10.00 service fee

  double get _totalPrintingFee => _copiesToPrint * _printingFeePerCopy;
  double get _totalCost => _totalPrintingFee + _serviceFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildProgressBar(context),
          Expanded(
            child: _buildContent(context),
          ),
        ],
      ),
      bottomNavigationBar: _buildFooter(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.description, color: Colors.blue),
        onPressed: () {},
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ContractKiosk',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            'Document Generation & Printing',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Current Time',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                DateFormat('HH:mm').format(DateTime.now()),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 18),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final steps = [
      context.getString(label: 'contractGeneration.sellerInformation'),
      context.getString(label: 'contractGeneration.buyerInformation'),
      context.getString(label: 'contractGeneration.objectDetails'),
      context.getString(label: 'contractGeneration.contractDetails'),
      context.getString(label: 'contractGeneration.summary'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isEven) {
                final stepIndex = index ~/ 2;
                final isActive = stepIndex == steps.length - 1;
                final isCompleted = stepIndex < steps.length - 1;

                return Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.blue
                            : (isCompleted ? Colors.green : Colors.grey[300]),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : Text(
                                '${stepIndex + 1}',
                                style: TextStyle(
                                  color: isActive ? Colors.white : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      steps[stepIndex],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive ? Colors.blue : Colors.grey[700],
                      ),
                    ),
                  ],
                );
              } else {
                return Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: Colors.green,
                  ),
                );
              }
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.getString(
                  label: 'contractGeneration.stepXofY',
                  params: {'current': 5, 'total': 5},
                ),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                context.getString(label: 'contractGeneration.finalReviewBeforePrinting'),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[50]!, Colors.indigo[50]!],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.getString(label: 'contractGeneration.orderSummary'),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.getString(label: 'contractGeneration.reviewAllInformation'),
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column - Information Cards
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildSellerInfoCard(context),
                      const SizedBox(height: 16),
                      _buildBuyerInfoCard(context),
                      const SizedBox(height: 16),
                      _buildObjectDetailsCard(context),
                      const SizedBox(height: 16),
                      _buildContractDetailsCard(context),
                    ],
                  ),
                ),
                const SizedBox(width: 24),

                // Right Column - Order Summary & Payment
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildOrderSummaryCard(context),
                      const SizedBox(height: 16),
                      _buildPaymentMethodCard(context),
                      const SizedBox(height: 16),
                      _buildTermsAcceptanceCard(context),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Verification Notice
          _buildVerificationNotice(context),
          const SizedBox(height: 80), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildSellerInfoCard(BuildContext context) {
    return _buildInfoCard(
      context: context,
      title: context.getString(label: 'contractGeneration.sellerInformation'),
      icon: Icons.person_outline,
      gradient: LinearGradient(
        colors: [Colors.blue[600]!, Colors.blue[500]!],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      children: [
        _InfoRow(
          label: context.getString(label: 'contractGeneration.name'),
          value: widget.contract.seller.fullName,
        ),
        _InfoRow(
          label: context.getString(label: 'contractGeneration.cnpCui'),
          value: widget.contract.seller.cnp,
        ),
        if (widget.contract.seller.idSeries.isNotEmpty)
          _InfoRow(
            label: context.getString(label: 'contractGeneration.idCard'),
            value:
                '${widget.contract.seller.idSeries} ${widget.contract.seller.idNumber}',
          ),
        _InfoRow(
          label: context.getString(label: 'contractGeneration.phone'),
          value: widget.contract.seller.phone,
        ),
        if (widget.contract.seller.email.isNotEmpty)
          _InfoRow(
            label: context.getString(label: 'contractGeneration.email'),
            value: widget.contract.seller.email,
          ),
        _InfoRow(
          label: context.getString(label: 'contractGeneration.address'),
          value:
              '${widget.contract.seller.address.street} ${widget.contract.seller.address.streetNumber}, '
              '${widget.contract.seller.address.city}, ${widget.contract.seller.address.county}, '
              '${widget.contract.seller.address.country}',
        ),
      ],
    );
  }

  Widget _buildBuyerInfoCard(BuildContext context) {
    return _buildInfoCard(
      context: context,
      title: context.getString(label: 'contractGeneration.buyerInformation'),
      icon: Icons.person,
      gradient: LinearGradient(
        colors: [Colors.purple[600]!, Colors.purple[500]!],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      children: [
        _InfoRow(
          label: context.getString(label: 'contractGeneration.name'),
          value: widget.contract.buyer.fullName,
        ),
        _InfoRow(
          label: context.getString(label: 'contractGeneration.cnpCui'),
          value: widget.contract.buyer.cnp,
        ),
        if (widget.contract.buyer.idSeries.isNotEmpty)
          _InfoRow(
            label: context.getString(label: 'contractGeneration.idCard'),
            value:
                '${widget.contract.buyer.idSeries} ${widget.contract.buyer.idNumber}',
          ),
        _InfoRow(
          label: context.getString(label: 'contractGeneration.phone'),
          value: widget.contract.buyer.phone,
        ),
        if (widget.contract.buyer.email.isNotEmpty)
          _InfoRow(
            label: context.getString(label: 'contractGeneration.email'),
            value: widget.contract.buyer.email,
          ),
        _InfoRow(
          label: context.getString(label: 'contractGeneration.address'),
          value:
              '${widget.contract.buyer.address.street} ${widget.contract.buyer.address.streetNumber}, '
              '${widget.contract.buyer.address.city}, ${widget.contract.buyer.address.county}, '
              '${widget.contract.buyer.address.country}',
        ),
      ],
    );
  }

  Widget _buildObjectDetailsCard(BuildContext context) {
    return _buildInfoCard(
      context: context,
      title: context.getString(label: 'contractGeneration.objectDetails'),
      icon: Icons.directions_car,
      gradient: LinearGradient(
        colors: [Colors.green[600]!, Colors.green[500]!],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      children: [
        Text(
          widget.contract.objectDetails,
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildContractDetailsCard(BuildContext context) {
    return _buildInfoCard(
      context: context,
      title: context.getString(label: 'contractGeneration.contractDetails'),
      icon: Icons.description,
      gradient: LinearGradient(
        colors: [Colors.orange[600]!, Colors.orange[500]!],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      children: [
        _InfoRow(
          label: context.getString(label: 'contractGeneration.salePrice'),
          value: '€${widget.contract.price.toStringAsFixed(2)}',
          valueStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.contract.contractDetails,
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Gradient gradient,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    // TODO: Implement edit functionality
                  },
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

  Widget _buildOrderSummaryCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  context.getString(label: 'contractGeneration.orderSummary'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _SummaryRow(
                  label: context.getString(label: 'contractGeneration.contractType'),
                  value: context.getString(label: 'contractGeneration.vehicleSale'),
                ),
                const Divider(),
                _SummaryRow(
                  label: context.getString(label: 'contractGeneration.documentPages'),
                  value:
                      '4 ${context.getString(label: 'contractGeneration.pages')}',
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.getString(label: 'contractGeneration.copiesToPrint'),
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: _copiesToPrint > 1
                              ? () => setState(() => _copiesToPrint--)
                              : null,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(32, 32),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            '$_copiesToPrint',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => setState(() => _copiesToPrint++),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(32, 32),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                _SummaryRow(
                  label: context.getString(label: 'contractGeneration.printingFee'),
                  value: '€${_totalPrintingFee.toStringAsFixed(2)}',
                ),
                const Divider(),
                _SummaryRow(
                  label: context.getString(label: 'contractGeneration.serviceFee'),
                  value: '€${_serviceFee.toStringAsFixed(2)}',
                ),
                const Divider(thickness: 2),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      context.getString(label: 'contractGeneration.totalCost'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '€${_totalCost.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              context.getString(label: 'contractGeneration.paymentMethod'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _PaymentOption(
                  icon: Icons.credit_card,
                  title: context.getString(label: 'contractGeneration.cardPayment'),
                  subtitle:
                      context.getString(label: 'contractGeneration.creditDebitCard'),
                  isSelected: _selectedPaymentMethod == 'card',
                  onTap: () => setState(() => _selectedPaymentMethod = 'card'),
                ),
                const SizedBox(height: 12),
                _PaymentOption(
                  icon: Icons.money,
                  title: context.getString(label: 'contractGeneration.cashPayment'),
                  subtitle:
                      context.getString(label: 'contractGeneration.payAtCounter'),
                  isSelected: _selectedPaymentMethod == 'cash',
                  onTap: () => setState(() => _selectedPaymentMethod = 'cash'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAcceptanceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _termsAccepted,
            onChanged: (value) => setState(() => _termsAccepted = value ?? false),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.getString(label: 'contractGeneration.acceptTerms'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.getString(label: 'contractGeneration.confirmAccuracy'),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationNotice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.blue[50],
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shield_outlined, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.getString(label: 'contractGeneration.finalVerification'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.getString(label: 'contractGeneration.reviewCarefully'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Back Button
                OutlinedButton.icon(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back),
                  label: Text(context.getString(label: 'contractGeneration.back')),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
                const Spacer(),

                // Preview Button
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement preview
                  },
                  icon: const Icon(Icons.visibility),
                  label: Text(context.getString(label: 'contractGeneration.preview')),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Save Draft Button
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement save draft
                  },
                  icon: const Icon(Icons.save),
                  label:
                      Text(context.getString(label: 'contractGeneration.saveDraft')),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Proceed to Payment Button
                ElevatedButton.icon(
                  onPressed: _termsAccepted ? _handleProceedToPayment : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                      context.getString(label: 'contractGeneration.proceedToPayment')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Status Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey[900],
            child: Row(
              children: [
                _StatusItem(
                  icon: Icons.circle,
                  label: context.getString(label: 'contractGeneration.systemOnline'),
                  color: Colors.green,
                ),
                const SizedBox(width: 24),
                _StatusItem(
                  icon: Icons.print,
                  label: context.getString(label: 'contractGeneration.printerReady'),
                  color: Colors.green,
                ),
                const Spacer(),
                Text(
                  '${context.getString(label: 'contractGeneration.sessionId')}: KSK-${DateFormat('yyyy-MM-dd-HHmm').format(DateTime.now())}',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleProceedToPayment() {
    if (widget.onProceedToPayment != null) {
      widget.onProceedToPayment!();
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: valueStyle ??
                  const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 15),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.blue[50] : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
      ],
    );
  }
}
