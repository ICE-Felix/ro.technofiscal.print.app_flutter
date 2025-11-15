import 'package:app/core/navigation/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/core/service_locator.dart';
import 'package:app/core/style/app_colors.dart';
import 'package:app/core/style/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import '../cubit/checkout_cubit.dart';
import '../widgets/billing_form.dart';
import '../widgets/shipping_form.dart';
import '../widgets/billing_same_as_shipping_checkbox.dart';
import '../widgets/payment_method_selector.dart';
import '../../domain/models/payment_method_model.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<CheckoutCubit>()..loadCheckout(),
      child: const CheckoutPageView(),
    );
  }
}

class CheckoutPageView extends StatelessWidget {
  const CheckoutPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<CheckoutCubit, CheckoutState>(
        listener: (context, state) {
          if (state.isPayReady && state.redirectUrl.isNotEmpty) {
            context.read<CheckoutCubit>().resetCheckout();

            context.goNamed(
              AppRoutesNames.paymentWebView.name,
              pathParameters: {'url': state.redirectUrl},
            );
          }
          if (state.isError && state.message.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<CheckoutCubit>().clearError();
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Shipping Form
                ShippingForm(
                  initialData: state.checkout.shipping,
                  onChanged: (shipping) {
                    context.read<CheckoutCubit>().updateShipping(shipping);
                  },
                ),

                const SizedBox(height: 32),

                // Billing Same as Shipping Checkbox
                BillingSameAsShippingCheckbox(
                  value: state.checkout.billingSameAsShipping,
                  onChanged: (value) {
                    context.read<CheckoutCubit>().updateBillingSameAsShipping(
                      value,
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Billing Form (conditional)
                if (!state.checkout.billingSameAsShipping) ...[
                  BillingForm(
                    initialData: state.checkout.billing,
                    onChanged: (billing) {
                      context.read<CheckoutCubit>().updateBilling(billing);
                    },
                  ),
                  const SizedBox(height: 32),
                ],

                // Payment Method Selector
                PaymentMethodSelector(
                  paymentMethods: PaymentMethodModel.getDefaultPaymentMethods(),
                  selectedMethod: state.checkout.selectedPaymentMethod,
                  onMethodSelected: (method) {
                    context.read<CheckoutCubit>().updatePaymentMethod(method);
                  },
                ),

                const SizedBox(height: 32),

                // Checkout Summary
                _CheckoutSummaryCard(
                  isComplete: state.checkout.isComplete,
                  onPlaceOrder: () {
                    _showOrderConfirmationDialog(
                      context,
                      context.read<CheckoutCubit>(),
                    );
                  },
                  onClearCheckout: () {
                    _showClearCheckoutDialog(context);
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showOrderConfirmationDialog(BuildContext context, CheckoutCubit cubit) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Place Order'),
            content: const Text('Are you sure you want to place this order?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  cubit.placeOrder();
                  Navigator.of(context).pop();
                },
                child: const Text('Place Order'),
              ),
            ],
          ),
    );
  }

  void _showClearCheckoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Checkout'),
            content: const Text(
              'Are you sure you want to clear all checkout data?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<CheckoutCubit>().clearCheckout();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Clear All'),
              ),
            ],
          ),
    );
  }
}

class _CheckoutSummaryCard extends StatelessWidget {
  final bool isComplete;
  final VoidCallback onPlaceOrder;
  final VoidCallback onClearCheckout;

  const _CheckoutSummaryCard({
    required this.isComplete,
    required this.onPlaceOrder,
    required this.onClearCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Order Summary',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Order status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isComplete ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isComplete
                          ? Colors.green.shade200
                          : Colors.orange.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isComplete ? Icons.check_circle : Icons.warning,
                    color: isComplete ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isComplete
                          ? 'Ready to place order'
                          : 'Please complete all required fields',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color:
                            isComplete
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onClearCheckout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isComplete ? onPlaceOrder : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: const Text('Place Order'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
