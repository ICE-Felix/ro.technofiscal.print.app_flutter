import 'package:flutter/material.dart';
import '../../../../core/style/app_colors.dart';
import '../../data/models/order_model.dart';

class OrderSummaryCard extends StatelessWidget {
  final OrderModel order;
  final Function(int copies)? onCopiesChanged;

  const OrderSummaryCard({
    super.key,
    required this.order,
    this.onCopiesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.kioskBlue, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.kioskBlue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.kioskBlue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.shopping_cart, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSummaryRow(
                  label: 'Contract Type',
                  value: order.contractType,
                ),
                const Divider(height: 24),

                _buildSummaryRow(
                  label: 'Document Pages',
                  value: '${order.numberOfPages} pages',
                ),
                const Divider(height: 24),

                // Copies with controls
                _buildCopiesRow(),
                const Divider(height: 24),

                _buildSummaryRow(
                  label: 'Printing Fee',
                  value: '${order.printingFee.toStringAsFixed(2)} RON',
                ),
                const Divider(height: 24),

                _buildSummaryRow(
                  label: 'Service Fee',
                  value: '${order.serviceFee.toStringAsFixed(2)} RON',
                ),
                const Divider(height: 24, color: AppColors.gray900),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Cost',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray900,
                      ),
                    ),
                    Text(
                      '${order.totalCost.toStringAsFixed(2)} RON',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.kioskBlue,
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

  Widget _buildSummaryRow({
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.gray600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
          ),
        ),
      ],
    );
  }

  Widget _buildCopiesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Copies to Print',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.gray600,
          ),
        ),
        Row(
          children: [
            _buildQuantityButton(
              icon: Icons.remove,
              onPressed: order.numberOfCopies > 1
                  ? () => onCopiesChanged?.call(order.numberOfCopies - 1)
                  : null,
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                '${order.numberOfCopies}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
            ),
            _buildQuantityButton(
              icon: Icons.add,
              onPressed: order.numberOfCopies < 10
                  ? () => onCopiesChanged?.call(order.numberOfCopies + 1)
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: onPressed != null ? AppColors.gray200 : AppColors.gray100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 16,
          color: onPressed != null ? AppColors.gray700 : AppColors.gray300,
        ),
      ),
    );
  }
}
