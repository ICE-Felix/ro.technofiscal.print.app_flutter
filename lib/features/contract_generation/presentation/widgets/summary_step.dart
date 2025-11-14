import 'package:flutter/material.dart';
import '../../data/models/contract_model.dart';

class SummaryStep extends StatelessWidget {
  final ContractModel contract;

  const SummaryStep({
    super.key,
    required this.contract,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Contract Summary',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please review all information before generating the contract',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 32),

          // Seller Information
          _SectionCard(
            title: 'Seller Information',
            icon: Icons.person_outline,
            children: [
              _InfoRow('Name', contract.seller.fullName),
              _InfoRow('CNP/CUI', contract.seller.cnp),
              if (contract.seller.idSeries.isNotEmpty)
                _InfoRow('ID Card', '${contract.seller.idSeries} ${contract.seller.idNumber}'),
              _InfoRow('Phone', contract.seller.phone),
              if (contract.seller.email.isNotEmpty)
                _InfoRow('Email', contract.seller.email),
              _InfoRow(
                'Address',
                '${contract.seller.address.street} ${contract.seller.address.streetNumber}, '
                '${contract.seller.address.city}, ${contract.seller.address.county}, '
                '${contract.seller.address.country}',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Buyer Information
          _SectionCard(
            title: 'Buyer Information',
            icon: Icons.person_outline,
            children: [
              _InfoRow('Name', contract.buyer.fullName),
              _InfoRow('CNP/CUI', contract.buyer.cnp),
              if (contract.buyer.idSeries.isNotEmpty)
                _InfoRow('ID Card', '${contract.buyer.idSeries} ${contract.buyer.idNumber}'),
              _InfoRow('Phone', contract.buyer.phone),
              if (contract.buyer.email.isNotEmpty)
                _InfoRow('Email', contract.buyer.email),
              _InfoRow(
                'Address',
                '${contract.buyer.address.street} ${contract.buyer.address.streetNumber}, '
                '${contract.buyer.address.city}, ${contract.buyer.address.county}, '
                '${contract.buyer.address.country}',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Object Details
          _SectionCard(
            title: 'Object Details',
            icon: Icons.inventory_2_outlined,
            children: [
              Text(
                contract.objectDetails,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Contract Details
          _SectionCard(
            title: 'Contract Details',
            icon: Icons.description_outlined,
            children: [
              _InfoRow('Price', '${contract.price.toStringAsFixed(2)} RON'),
              const SizedBox(height: 12),
              Text(
                contract.contractDetails,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Warning box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange[700], size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Please review all information carefully. Once generated, the contract will be legally binding.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange[900],
                      fontWeight: FontWeight.w500,
                    ),
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

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
