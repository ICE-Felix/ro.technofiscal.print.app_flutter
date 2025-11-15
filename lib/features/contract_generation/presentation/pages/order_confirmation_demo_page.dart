import 'package:flutter/material.dart';
import '../../data/models/contract_model.dart';
import '../../data/models/party_model.dart';
import '../../data/models/address_model.dart';
import '../../data/models/order_model.dart';
import '../widgets/order_confirmation_screen.dart';

/// Demo page to showcase the order confirmation feature
/// This demonstrates the complete order confirmation UI with sample data
class OrderConfirmationDemoPage extends StatelessWidget {
  const OrderConfirmationDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample contract data
    final contract = ContractModel(
      seller: PartyModel(
        fullName: 'John Michael Smith',
        cnp: '1850315123456',
        idSeries: 'AB',
        idNumber: '123456',
        phone: '+40 730 123 456',
        email: 'john.smith@email.com',
        address: const AddressModel(
          country: 'Romania',
          county: 'Bucharest',
          city: 'Bucharest',
          postalCode: '010101',
          street: 'Strada Principala',
          streetNumber: '123',
        ),
      ),
      buyer: PartyModel(
        fullName: 'Sarah Emma Johnson',
        cnp: '2900722234567',
        idSeries: 'CD',
        idNumber: '789012',
        phone: '+40 730 987 654',
        email: 'sarah.johnson@email.com',
        address: const AddressModel(
          country: 'Romania',
          county: 'Cluj',
          city: 'Cluj-Napoca',
          postalCode: '400001',
          street: 'Strada Oak',
          streetNumber: '456',
        ),
      ),
      objectDetails: '''Vehicle Details:
Category: Car
Brand: Volkswagen
Model: Golf VII
Year: 2018
VIN: WVWZZZ1KZBW123456
Registration: B-XY-1234
Color: Silver
Mileage: 85,000 km
Engine: 1,600 cc
Fuel Type: Diesel

Additional Notes:
Well maintained, full service history, new tires installed in 2023''',
      contractDetails: '''Sale Conditions:
- Vehicle sold as-is, buyer accepts current condition
- Payment to be made via bank transfer within 3 business days
- All documentation and keys to be transferred upon payment confirmation
- Seller guarantees clear ownership and no outstanding debts on the vehicle
- Handover scheduled for 20 November 2025 at agreed location''',
      price: 12500.00,
      createdAt: DateTime.now(),
    );

    return OrderConfirmationScreen(
      contract: contract,
      onProceedToPayment: (order) {
        _showPaymentDialog(context, order);
      },
      onBack: () {
        Navigator.of(context).pop();
      },
      onPreview: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preview functionality - Contract preview would appear here'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      onSaveDraft: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Draft saved successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      },
      onEditStep: (step) {
        final stepNames = ['Seller', 'Buyer', 'Object Details', 'Contract Details'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Edit ${stepNames[step]} - Navigation would go to step $step'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  void _showPaymentDialog(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          order.paymentMethod == PaymentMethod.card
              ? Icons.credit_card
              : Icons.money,
          size: 64,
          color: Theme.of(context).primaryColor,
        ),
        title: const Text('Proceed to Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Payment Method: ${order.paymentMethod == PaymentMethod.card ? "Card Payment" : "Cash Payment"}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Amount: ${order.totalCost.toStringAsFixed(2)} RON',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Number of Copies: ${order.numberOfCopies}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSuccessDialog(context);
            },
            child: const Text('Confirm Payment'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 64,
        ),
        title: const Text('Payment Successful!'),
        content: const Text(
          'Your contract has been generated and will be printed shortly.',
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
