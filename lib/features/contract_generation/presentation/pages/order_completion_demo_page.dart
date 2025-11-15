import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/contract_model.dart';
import '../../data/models/party_model.dart';
import '../../data/models/address_model.dart';
import '../../data/models/order_completion_model.dart';
import 'order_completion_page.dart';

class OrderCompletionDemoPage extends StatelessWidget {
  const OrderCompletionDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Create sample contract data
    final contract = ContractModel(
      seller: PartyModel(
        entityType: EntityType.individual,
        fullName: 'John Michael Smith',
        cnp: '123456789',
        idSeries: 'AB',
        idNumber: '123456',
        address: const AddressModel(
          country: 'Germany',
          county: 'Berlin',
          city: 'Berlin',
          postalCode: '10115',
          street: 'Hauptstraße',
          streetNumber: '42',
        ),
        phone: '+49 30 12345678',
        email: 'john.smith@example.com',
      ),
      buyer: PartyModel(
        entityType: EntityType.individual,
        fullName: 'Maria Elena Rodriguez',
        cnp: '987654321',
        idSeries: 'CD',
        idNumber: '654321',
        address: const AddressModel(
          country: 'Germany',
          county: 'Berlin',
          city: 'Berlin',
          postalCode: '10117',
          street: 'Friedrichstraße',
          streetNumber: '156',
        ),
        phone: '+49 30 87654321',
        email: 'maria.rodriguez@example.com',
      ),
      objectDetails: '2015 Volkswagen Golf\nVIN: WVWZZZ1KZ5W123456\nRegistration: B-123-ABC\nCondition: Good\nMileage: 85,000 km',
      contractDetails: 'Vehicle sale agreement including all standard terms and conditions. '
          'The vehicle is sold as-is, with the seller guaranteeing clear title and no outstanding liens. '
          'Payment to be made in full upon transfer of ownership.',
      price: 15500.0,
      createdAt: DateTime.now(),
      isComplete: true,
    );

    // Create sample order completion data
    final completion = OrderCompletionModel(
      contractId: 'CNT-2024-001247',
      contractType: 'Vehicle Sale Agreement',
      numberOfPages: 8,
      language: 'English',
      legalComplianceVerified: true,
      sellerCopies: 1,
      buyerCopies: 1,
      authorityCopies: 1,
      documentFormat: 'PDF',
      paperSize: 'A4',
      printQuality: 'High',
      colorMode: 'Black & White',
      printReady: true,
      emailAvailable: false,
      digitalArchiveSaved: true,
      completionDate: DateTime.now(),
      processingTimeMinutes: 12,
    );

    return OrderCompletionPage(
      contract: contract,
      completion: completion,
      onNewContract: () {
        // Navigate to contract generation page
        context.go('/contract-generation');
      },
      onEmailCopy: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email copy feature will be available soon'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      onSavePdf: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF download will start automatically'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      onHelp: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Help documentation will open'),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }
}
