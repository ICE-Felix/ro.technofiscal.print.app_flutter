// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ContractKiosk';

  @override
  String get contractGeneration => 'Contract Generation';

  @override
  String get salePurchaseContract => 'Sale-Purchase Contract Generation';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get fieldNotFound => 'Field not found';

  @override
  String get failedToInitialize => 'Failed to initialize data manager';

  @override
  String get noCurrentField => 'No current field';

  @override
  String get exitContractGeneration => 'Exit Contract Generation?';

  @override
  String get progressSaved =>
      'Your progress has been saved. You can continue later from where you left off.';

  @override
  String get continueBtn => 'Continue';

  @override
  String get exitBtn => 'Exit';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get complete => 'Complete';

  @override
  String get done => 'Done';

  @override
  String fieldXofY(int current, int total) {
    return 'Field $current of $total';
  }

  @override
  String get sellerInformation => 'Seller Information';

  @override
  String get buyerInformation => 'Buyer Information';

  @override
  String get objectDetails => 'Object Details';

  @override
  String get contractDetails => 'Contract Details';

  @override
  String get summary => 'Summary';

  @override
  String get entityTypeSelection => 'Entity Type Selection';

  @override
  String get pleaseSelectEntityType => 'Please select the entity type';

  @override
  String get chooseEntityType =>
      'Choose whether this is an individual person or a company/legal entity';

  @override
  String get individualPerson => 'Individual Person';

  @override
  String get forPersonalTransactions => 'For personal transactions';

  @override
  String get companyLegalEntity => 'Company / Legal Entity';

  @override
  String get forBusinessTransactions => 'For business transactions';

  @override
  String get selectedIndividual => 'Selected: Individual Person';

  @override
  String get selectedCompany => 'Selected: Company/Legal Entity';

  @override
  String get entityTypeInfo =>
      'This selection will determine which documents and information are required';

  @override
  String get optionalFieldInfo =>
      'Optional field - you can skip if not applicable';

  @override
  String get yourProgress => 'Your Progress';

  @override
  String completedFields(int completed, int total) {
    return '$completed of $total fields completed';
  }

  @override
  String get contractSummary => 'Contract Summary';

  @override
  String get reviewInformation =>
      'Please review the information before generating the contract:';

  @override
  String get reviewData => 'Review Data';

  @override
  String get generateContract => 'Generate Contract';

  @override
  String get contractGeneratedSuccess => 'Contract Generated Successfully!';

  @override
  String get contractGeneratedMessage =>
      'Your contract has been generated. You can now print it or save it for your records.';

  @override
  String get close => 'Close';

  @override
  String get printContract => 'Print Contract';

  @override
  String get fullNameCompanyName => 'Full Name / Company Name';

  @override
  String get enterFullLegalName => 'Enter full legal name';

  @override
  String get cnpCui => 'CNP / CUI';

  @override
  String get enterCnpOrCui => 'Enter CNP (personal) or CUI (company)';

  @override
  String get idSeries => 'ID Series';

  @override
  String get idSeriesHint => 'e.g., RX';

  @override
  String get idNumber => 'ID Number';

  @override
  String get enterIdNumber => 'Enter ID card number';

  @override
  String get country => 'Country';

  @override
  String get countryHint => 'e.g., Romania';

  @override
  String get county => 'County';

  @override
  String get countyHint => 'e.g., Cluj';

  @override
  String get city => 'City';

  @override
  String get cityHint => 'e.g., Cluj-Napoca';

  @override
  String get postalCode => 'Postal Code';

  @override
  String get postalCodeHint => 'e.g., 400001';

  @override
  String get street => 'Street';

  @override
  String get enterStreetName => 'Enter street name';

  @override
  String get streetNumber => 'Street Number';

  @override
  String get streetNumberHint => 'e.g., 123';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phoneHint => '+40 123 456 789';

  @override
  String get emailOptional => 'Email (Optional)';

  @override
  String get emailHint => 'email@example.com';

  @override
  String get objectCategory => 'Object Category';

  @override
  String get objectCategoryHint => 'e.g., Vehicle, Electronics, Real Estate';

  @override
  String get objectDescription => 'Object Description';

  @override
  String get objectDescriptionHint => 'Detailed description of the object';

  @override
  String get brandOptional => 'Brand (Optional)';

  @override
  String get brandHint => 'e.g., BMW, Samsung';

  @override
  String get modelOptional => 'Model (Optional)';

  @override
  String get modelHint => 'e.g., X5, Galaxy S23';

  @override
  String get serialNumberOptional => 'Serial Number (Optional)';

  @override
  String get serialNumberHint => 'Enter serial number if applicable';

  @override
  String get vinOptional => 'VIN (Optional)';

  @override
  String get vinHint => 'Vehicle Identification Number';

  @override
  String get yearOptional => 'Year (Optional)';

  @override
  String get yearHint => 'e.g., 2023';

  @override
  String get condition => 'Condition';

  @override
  String get conditionHint => 'e.g., New, Used, Refurbished';

  @override
  String get contractPrice => 'Contract Price';

  @override
  String get enterTotalPrice => 'Enter total price';

  @override
  String get currency => 'Currency';

  @override
  String get currencyHint => 'e.g., RON, EUR, USD';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get paymentMethodHint => 'e.g., Cash, Bank Transfer, Card';

  @override
  String get deliveryDate => 'Delivery Date';

  @override
  String get deliveryDateHint => 'When will delivery occur?';

  @override
  String get contractLocation => 'Contract Location';

  @override
  String get contractLocationHint => 'Where is the contract signed?';

  @override
  String get additionalTermsOptional => 'Additional Terms (Optional)';

  @override
  String get additionalTermsHint => 'Any special terms or conditions';

  @override
  String get warrantyOptional => 'Warranty (Optional)';

  @override
  String get warrantyHint => 'Warranty information';

  @override
  String get fillAllRequired => 'Please fill in all required fields';

  @override
  String get virtualKeyboard => 'Virtual Keyboard';

  @override
  String get previousField => 'Previous Field';

  @override
  String get nextField => 'Next Field';

  @override
  String get switchToNumeric => 'Switch to Numeric';

  @override
  String get switchToAlphanumeric => 'Switch to Alphanumeric';

  @override
  String get hideKeyboard => 'Hide Keyboard';
}
