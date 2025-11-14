import 'package:flutter/material.dart';
import '../../data/models/party_model.dart';
import '../../data/models/address_model.dart';
import 'keyboard_text_field.dart';

class PartyFormStep extends StatefulWidget {
  final String title;
  final String subtitle;
  final PartyModel initialData;
  final Function(PartyModel) onChanged;

  const PartyFormStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.initialData,
    required this.onChanged,
  });

  @override
  State<PartyFormStep> createState() => _PartyFormStepState();
}

class _PartyFormStepState extends State<PartyFormStep> {
  late TextEditingController _fullNameController;
  late TextEditingController _cnpController;
  late TextEditingController _idSeriesController;
  late TextEditingController _idNumberController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _countryController;
  late TextEditingController _countyController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;
  late TextEditingController _streetController;
  late TextEditingController _streetNumberController;

  EntityType _selectedEntityType = EntityType.individual;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.initialData.fullName);
    _cnpController = TextEditingController(text: widget.initialData.cnp);
    _idSeriesController = TextEditingController(text: widget.initialData.idSeries);
    _idNumberController = TextEditingController(text: widget.initialData.idNumber);
    _phoneController = TextEditingController(text: widget.initialData.phone);
    _emailController = TextEditingController(text: widget.initialData.email);
    _countryController = TextEditingController(text: widget.initialData.address.country);
    _countyController = TextEditingController(text: widget.initialData.address.county);
    _cityController = TextEditingController(text: widget.initialData.address.city);
    _postalCodeController = TextEditingController(text: widget.initialData.address.postalCode);
    _streetController = TextEditingController(text: widget.initialData.address.street);
    _streetNumberController = TextEditingController(text: widget.initialData.address.streetNumber);
    _selectedEntityType = widget.initialData.entityType;

    // Add listeners to auto-update
    _fullNameController.addListener(_updateData);
    _cnpController.addListener(_updateData);
    _idSeriesController.addListener(_updateData);
    _idNumberController.addListener(_updateData);
    _phoneController.addListener(_updateData);
    _emailController.addListener(_updateData);
    _countryController.addListener(_updateData);
    _countyController.addListener(_updateData);
    _cityController.addListener(_updateData);
    _postalCodeController.addListener(_updateData);
    _streetController.addListener(_updateData);
    _streetNumberController.addListener(_updateData);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _cnpController.dispose();
    _idSeriesController.dispose();
    _idNumberController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    _countyController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _streetController.dispose();
    _streetNumberController.dispose();
    super.dispose();
  }

  void _updateData() {
    widget.onChanged(PartyModel(
      entityType: _selectedEntityType,
      fullName: _fullNameController.text,
      cnp: _cnpController.text,
      idSeries: _idSeriesController.text,
      idNumber: _idNumberController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      address: AddressModel(
        country: _countryController.text,
        county: _countyController.text,
        city: _cityController.text,
        postalCode: _postalCodeController.text,
        street: _streetController.text,
        streetNumber: _streetNumberController.text,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 32),

          // Entity Type Selection
          Text(
            'Entity Type *',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _EntityTypeCard(
                  entityType: EntityType.individual,
                  isSelected: _selectedEntityType == EntityType.individual,
                  onTap: () {
                    setState(() {
                      _selectedEntityType = EntityType.individual;
                      _updateData();
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _EntityTypeCard(
                  entityType: EntityType.company,
                  isSelected: _selectedEntityType == EntityType.company,
                  onTap: () {
                    setState(() {
                      _selectedEntityType = EntityType.company;
                      _updateData();
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Personal/Company Information
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _fullNameController,
                  label: _selectedEntityType == EntityType.individual
                      ? 'Full Name *'
                      : 'Company Name *',
                  hint: 'Enter full name',
                  icon: Icons.person,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _cnpController,
                  label: _selectedEntityType == EntityType.individual
                      ? 'CNP *'
                      : 'CUI *',
                  hint: _selectedEntityType == EntityType.individual
                      ? 'Enter CNP'
                      : 'Enter CUI',
                  icon: Icons.badge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ID Card Information (only for individuals)
          if (_selectedEntityType == EntityType.individual) ...[
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _idSeriesController,
                    label: 'ID Card Series *',
                    hint: 'e.g. RX',
                    icon: Icons.credit_card,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _idNumberController,
                    label: 'ID Card Number *',
                    hint: 'e.g. 123456',
                    icon: Icons.numbers,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Contact Information
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number *',
                  hint: '+40 7xx xxx xxx',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _emailController,
                  label: 'Email Address (Optional)',
                  hint: 'email@example.com',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Address Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Address Information *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _countryController,
                        label: 'Country',
                        hint: 'Romania',
                        icon: Icons.flag,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _countyController,
                        label: 'County / Region',
                        hint: 'Enter county',
                        icon: Icons.location_city,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _cityController,
                        label: 'City / Town',
                        hint: 'Enter city',
                        icon: Icons.apartment,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _postalCodeController,
                        label: 'Postal Code',
                        hint: 'Enter postal code',
                        icon: Icons.markunread_mailbox,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        controller: _streetController,
                        label: 'Street Name',
                        hint: 'Enter street name',
                        icon: Icons.signpost,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _streetNumberController,
                        label: 'Number',
                        hint: 'No.',
                        icon: Icons.numbers,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return KeyboardTextField(
      controller: controller,
      label: label,
      hint: hint,
      icon: icon,
      keyboardType: keyboardType,
    );
  }
}

class _EntityTypeCard extends StatelessWidget {
  final EntityType entityType;
  final bool isSelected;
  final VoidCallback onTap;

  const _EntityTypeCard({
    required this.entityType,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              entityType == EntityType.individual ? Icons.person : Icons.business,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entityType.displayName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey[800],
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}
