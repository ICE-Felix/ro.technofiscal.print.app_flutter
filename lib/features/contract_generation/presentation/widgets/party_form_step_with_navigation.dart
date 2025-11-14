import 'package:flutter/material.dart';
import '../../data/models/party_model.dart';
import '../../data/models/address_model.dart';
import 'keyboard_text_field.dart';
import 'field_navigation_controller.dart';

/// Example implementation of PartyFormStep with field-by-field navigation
/// This demonstrates the pattern for one-field-at-a-time input
class PartyFormStepWithNavigation extends StatefulWidget {
  final String title;
  final String subtitle;
  final PartyModel initialData;
  final Function(PartyModel) onChanged;
  final FieldNavigationController? navigationController;

  const PartyFormStepWithNavigation({
    super.key,
    required this.title,
    required this.subtitle,
    required this.initialData,
    required this.onChanged,
    this.navigationController,
  });

  @override
  State<PartyFormStepWithNavigation> createState() => _PartyFormStepWithNavigationState();
}

class _PartyFormStepWithNavigationState extends State<PartyFormStepWithNavigation> {
  // Text controllers
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

  // Focus nodes for field navigation
  late FocusNode _fullNameFocus;
  late FocusNode _cnpFocus;
  late FocusNode _idSeriesFocus;
  late FocusNode _idNumberFocus;
  late FocusNode _phoneFocus;
  late FocusNode _emailFocus;
  late FocusNode _countryFocus;
  late FocusNode _countyFocus;
  late FocusNode _cityFocus;
  late FocusNode _postalCodeFocus;
  late FocusNode _streetFocus;
  late FocusNode _streetNumberFocus;

  EntityType _selectedEntityType = EntityType.individual;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
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

    // Initialize focus nodes
    _fullNameFocus = FocusNode();
    _cnpFocus = FocusNode();
    _idSeriesFocus = FocusNode();
    _idNumberFocus = FocusNode();
    _phoneFocus = FocusNode();
    _emailFocus = FocusNode();
    _countryFocus = FocusNode();
    _countyFocus = FocusNode();
    _cityFocus = FocusNode();
    _postalCodeFocus = FocusNode();
    _streetFocus = FocusNode();
    _streetNumberFocus = FocusNode();

    // Register fields with navigation controller
    if (widget.navigationController != null) {
      widget.navigationController!.registerField(_fullNameFocus, _fullNameController);
      widget.navigationController!.registerField(_cnpFocus, _cnpController);
      if (_selectedEntityType == EntityType.individual) {
        widget.navigationController!.registerField(_idSeriesFocus, _idSeriesController);
        widget.navigationController!.registerField(_idNumberFocus, _idNumberController);
      }
      widget.navigationController!.registerField(_phoneFocus, _phoneController);
      widget.navigationController!.registerField(_emailFocus, _emailController);
      widget.navigationController!.registerField(_countryFocus, _countryController);
      widget.navigationController!.registerField(_countyFocus, _countyController);
      widget.navigationController!.registerField(_cityFocus, _cityController);
      widget.navigationController!.registerField(_postalCodeFocus, _postalCodeController);
      widget.navigationController!.registerField(_streetFocus, _streetController);
      widget.navigationController!.registerField(_streetNumberFocus, _streetNumberController);

      // Auto-focus first field after frame renders
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.navigationController!.focusFirstField();
      });
    }

    // Add listeners
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
    // Dispose controllers
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

    // Dispose focus nodes
    _fullNameFocus.dispose();
    _cnpFocus.dispose();
    _idSeriesFocus.dispose();
    _idNumberFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _countryFocus.dispose();
    _countyFocus.dispose();
    _cityFocus.dispose();
    _postalCodeFocus.dispose();
    _streetFocus.dispose();
    _streetNumberFocus.dispose();

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

          // All fields with FocusNode support
          KeyboardTextField(
            controller: _fullNameController,
            focusNode: _fullNameFocus,
            label: _selectedEntityType == EntityType.individual
                ? 'Full Name *'
                : 'Company Name *',
            hint: 'Enter full name',
            icon: Icons.person,
            autofocus: true,
          ),
          const SizedBox(height: 16),

          KeyboardTextField(
            controller: _cnpController,
            focusNode: _cnpFocus,
            label: _selectedEntityType == EntityType.individual ? 'CNP *' : 'CUI *',
            hint: _selectedEntityType == EntityType.individual ? 'Enter CNP' : 'Enter CUI',
            icon: Icons.badge,
          ),
          const SizedBox(height: 16),

          if (_selectedEntityType == EntityType.individual) ...[
            KeyboardTextField(
              controller: _idSeriesController,
              focusNode: _idSeriesFocus,
              label: 'ID Card Series *',
              hint: 'e.g. RX',
              icon: Icons.credit_card,
            ),
            const SizedBox(height: 16),
            KeyboardTextField(
              controller: _idNumberController,
              focusNode: _idNumberFocus,
              label: 'ID Card Number *',
              hint: 'e.g. 123456',
              icon: Icons.numbers,
            ),
            const SizedBox(height: 16),
          ],

          KeyboardTextField(
            controller: _phoneController,
            focusNode: _phoneFocus,
            label: 'Phone Number *',
            hint: '+40 7xx xxx xxx',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          KeyboardTextField(
            controller: _emailController,
            focusNode: _emailFocus,
            label: 'Email Address (Optional)',
            hint: 'email@example.com',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 32),

          // Address fields
          Text(
            'Address Information *',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          KeyboardTextField(
            controller: _countryController,
            focusNode: _countryFocus,
            label: 'Country',
            hint: 'Romania',
            icon: Icons.flag,
          ),
          const SizedBox(height: 16),

          KeyboardTextField(
            controller: _countyController,
            focusNode: _countyFocus,
            label: 'County / Region',
            hint: 'Enter county',
            icon: Icons.location_city,
          ),
          const SizedBox(height: 16),

          KeyboardTextField(
            controller: _cityController,
            focusNode: _cityFocus,
            label: 'City / Town',
            hint: 'Enter city',
            icon: Icons.apartment,
          ),
          const SizedBox(height: 16),

          KeyboardTextField(
            controller: _postalCodeController,
            focusNode: _postalCodeFocus,
            label: 'Postal Code',
            hint: 'Enter postal code',
            icon: Icons.markunread_mailbox,
          ),
          const SizedBox(height: 16),

          KeyboardTextField(
            controller: _streetController,
            focusNode: _streetFocus,
            label: 'Street Name',
            hint: 'Enter street name',
            icon: Icons.signpost,
          ),
          const SizedBox(height: 16),

          KeyboardTextField(
            controller: _streetNumberController,
            focusNode: _streetNumberFocus,
            label: 'Number',
            hint: 'No.',
            icon: Icons.numbers,
          ),
        ],
      ),
    );
  }
}
