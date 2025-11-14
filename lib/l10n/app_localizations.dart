import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ro.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ro'),
  ];

  /// Application title
  ///
  /// In ro, this message translates to:
  /// **'ContractKiosk'**
  String get appTitle;

  /// Contract generation feature name
  ///
  /// In ro, this message translates to:
  /// **'Generare Contract'**
  String get contractGeneration;

  /// Sale-purchase contract generation
  ///
  /// In ro, this message translates to:
  /// **'Contract Vânzare-Cumpărare'**
  String get salePurchaseContract;

  /// Loading message
  ///
  /// In ro, this message translates to:
  /// **'Se încarcă...'**
  String get loading;

  /// Error message
  ///
  /// In ro, this message translates to:
  /// **'Eroare'**
  String get error;

  /// Field not found error
  ///
  /// In ro, this message translates to:
  /// **'Câmpul nu a fost găsit'**
  String get fieldNotFound;

  /// Failed to initialize data manager
  ///
  /// In ro, this message translates to:
  /// **'Inițializarea a eșuat'**
  String get failedToInitialize;

  /// No current field
  ///
  /// In ro, this message translates to:
  /// **'Niciun câmp curent'**
  String get noCurrentField;

  /// Exit contract generation dialog title
  ///
  /// In ro, this message translates to:
  /// **'Ieșiți din generarea contractului?'**
  String get exitContractGeneration;

  /// Progress saved message
  ///
  /// In ro, this message translates to:
  /// **'Progresul dvs. a fost salvat. Puteți continua mai târziu de unde ați rămas.'**
  String get progressSaved;

  /// Continue button
  ///
  /// In ro, this message translates to:
  /// **'Continuă'**
  String get continueBtn;

  /// Exit button
  ///
  /// In ro, this message translates to:
  /// **'Ieșire'**
  String get exitBtn;

  /// Previous button
  ///
  /// In ro, this message translates to:
  /// **'Înapoi'**
  String get previous;

  /// Next button
  ///
  /// In ro, this message translates to:
  /// **'Următorul'**
  String get next;

  /// Skip button
  ///
  /// In ro, this message translates to:
  /// **'Sari peste'**
  String get skip;

  /// Complete button
  ///
  /// In ro, this message translates to:
  /// **'Finalizare'**
  String get complete;

  /// Done button
  ///
  /// In ro, this message translates to:
  /// **'Terminat'**
  String get done;

  /// Field counter
  ///
  /// In ro, this message translates to:
  /// **'Câmpul {current} din {total}'**
  String fieldXofY(int current, int total);

  /// Seller information section
  ///
  /// In ro, this message translates to:
  /// **'Informații Vânzător'**
  String get sellerInformation;

  /// Buyer information section
  ///
  /// In ro, this message translates to:
  /// **'Informații Cumpărător'**
  String get buyerInformation;

  /// Object details section
  ///
  /// In ro, this message translates to:
  /// **'Detalii Obiect'**
  String get objectDetails;

  /// Contract details section
  ///
  /// In ro, this message translates to:
  /// **'Detalii Contract'**
  String get contractDetails;

  /// Summary section
  ///
  /// In ro, this message translates to:
  /// **'Sumar'**
  String get summary;

  /// Entity type selection
  ///
  /// In ro, this message translates to:
  /// **'Selectare Tip Entitate'**
  String get entityTypeSelection;

  /// Please select entity type prompt
  ///
  /// In ro, this message translates to:
  /// **'Vă rugăm să selectați tipul de entitate'**
  String get pleaseSelectEntityType;

  /// Choose entity type description
  ///
  /// In ro, this message translates to:
  /// **'Alegeți dacă aceasta este o persoană fizică sau o persoană juridică/companie'**
  String get chooseEntityType;

  /// Individual person option
  ///
  /// In ro, this message translates to:
  /// **'Persoană Fizică'**
  String get individualPerson;

  /// For personal transactions subtitle
  ///
  /// In ro, this message translates to:
  /// **'Pentru tranzacții personale'**
  String get forPersonalTransactions;

  /// Company/legal entity option
  ///
  /// In ro, this message translates to:
  /// **'Companie / Persoană Juridică'**
  String get companyLegalEntity;

  /// For business transactions subtitle
  ///
  /// In ro, this message translates to:
  /// **'Pentru tranzacții de afaceri'**
  String get forBusinessTransactions;

  /// Selected individual confirmation
  ///
  /// In ro, this message translates to:
  /// **'Selectat: Persoană Fizică'**
  String get selectedIndividual;

  /// Selected company confirmation
  ///
  /// In ro, this message translates to:
  /// **'Selectat: Companie/Persoană Juridică'**
  String get selectedCompany;

  /// Entity type information message
  ///
  /// In ro, this message translates to:
  /// **'Această selecție va determina ce documente și informații sunt necesare'**
  String get entityTypeInfo;

  /// Optional field information
  ///
  /// In ro, this message translates to:
  /// **'Câmp opțional - puteți sări peste dacă nu este aplicabil'**
  String get optionalFieldInfo;

  /// Your progress header
  ///
  /// In ro, this message translates to:
  /// **'Progresul Dvs.'**
  String get yourProgress;

  /// Completed fields count
  ///
  /// In ro, this message translates to:
  /// **'{completed} din {total} câmpuri completate'**
  String completedFields(int completed, int total);

  /// Contract summary dialog title
  ///
  /// In ro, this message translates to:
  /// **'Sumar Contract'**
  String get contractSummary;

  /// Review information prompt
  ///
  /// In ro, this message translates to:
  /// **'Vă rugăm să revizuiți informațiile înainte de a genera contractul:'**
  String get reviewInformation;

  /// Review data button
  ///
  /// In ro, this message translates to:
  /// **'Revizuiește Datele'**
  String get reviewData;

  /// Generate contract button
  ///
  /// In ro, this message translates to:
  /// **'Generează Contract'**
  String get generateContract;

  /// Contract generated successfully message
  ///
  /// In ro, this message translates to:
  /// **'Contract generat cu succes!'**
  String get contractGeneratedSuccess;

  /// Contract generated message
  ///
  /// In ro, this message translates to:
  /// **'Contractul dvs. a fost generat. Acum îl puteți tipări sau salva pentru evidențele dvs.'**
  String get contractGeneratedMessage;

  /// Close button
  ///
  /// In ro, this message translates to:
  /// **'Închide'**
  String get close;

  /// Print contract button
  ///
  /// In ro, this message translates to:
  /// **'Tipărește Contract'**
  String get printContract;

  /// Full name or company name field
  ///
  /// In ro, this message translates to:
  /// **'Nume Complet / Denumire Companie'**
  String get fullNameCompanyName;

  /// Enter full legal name hint
  ///
  /// In ro, this message translates to:
  /// **'Introduceți numele legal complet'**
  String get enterFullLegalName;

  /// CNP or CUI field
  ///
  /// In ro, this message translates to:
  /// **'CNP / CUI'**
  String get cnpCui;

  /// Enter CNP or CUI hint
  ///
  /// In ro, this message translates to:
  /// **'Introduceți CNP (personal) sau CUI (companie)'**
  String get enterCnpOrCui;

  /// ID series field
  ///
  /// In ro, this message translates to:
  /// **'Serie CI'**
  String get idSeries;

  /// ID series hint
  ///
  /// In ro, this message translates to:
  /// **'ex., RX'**
  String get idSeriesHint;

  /// ID number field
  ///
  /// In ro, this message translates to:
  /// **'Număr CI'**
  String get idNumber;

  /// Enter ID number hint
  ///
  /// In ro, this message translates to:
  /// **'Introduceți numărul cărții de identitate'**
  String get enterIdNumber;

  /// Country field
  ///
  /// In ro, this message translates to:
  /// **'Țară'**
  String get country;

  /// Country hint
  ///
  /// In ro, this message translates to:
  /// **'ex., România'**
  String get countryHint;

  /// County field
  ///
  /// In ro, this message translates to:
  /// **'Județ'**
  String get county;

  /// County hint
  ///
  /// In ro, this message translates to:
  /// **'ex., Cluj'**
  String get countyHint;

  /// City field
  ///
  /// In ro, this message translates to:
  /// **'Oraș'**
  String get city;

  /// City hint
  ///
  /// In ro, this message translates to:
  /// **'ex., Cluj-Napoca'**
  String get cityHint;

  /// Postal code field
  ///
  /// In ro, this message translates to:
  /// **'Cod Poștal'**
  String get postalCode;

  /// Postal code hint
  ///
  /// In ro, this message translates to:
  /// **'ex., 400001'**
  String get postalCodeHint;

  /// Street field
  ///
  /// In ro, this message translates to:
  /// **'Stradă'**
  String get street;

  /// Enter street name hint
  ///
  /// In ro, this message translates to:
  /// **'Introduceți numele străzii'**
  String get enterStreetName;

  /// Street number field
  ///
  /// In ro, this message translates to:
  /// **'Număr Stradă'**
  String get streetNumber;

  /// Street number hint
  ///
  /// In ro, this message translates to:
  /// **'ex., 123'**
  String get streetNumberHint;

  /// Phone number field
  ///
  /// In ro, this message translates to:
  /// **'Număr Telefon'**
  String get phoneNumber;

  /// Phone number hint
  ///
  /// In ro, this message translates to:
  /// **'+40 123 456 789'**
  String get phoneHint;

  /// Email optional field
  ///
  /// In ro, this message translates to:
  /// **'Email (Opțional)'**
  String get emailOptional;

  /// Email hint
  ///
  /// In ro, this message translates to:
  /// **'email@exemplu.com'**
  String get emailHint;

  /// Object category field
  ///
  /// In ro, this message translates to:
  /// **'Categorie Obiect'**
  String get objectCategory;

  /// Object category hint
  ///
  /// In ro, this message translates to:
  /// **'ex., Vehicul, Electronice, Imobiliare'**
  String get objectCategoryHint;

  /// Object description field
  ///
  /// In ro, this message translates to:
  /// **'Descriere Obiect'**
  String get objectDescription;

  /// Object description hint
  ///
  /// In ro, this message translates to:
  /// **'Descriere detaliată a obiectului'**
  String get objectDescriptionHint;

  /// Brand optional field
  ///
  /// In ro, this message translates to:
  /// **'Marcă (Opțional)'**
  String get brandOptional;

  /// Brand hint
  ///
  /// In ro, this message translates to:
  /// **'ex., BMW, Samsung'**
  String get brandHint;

  /// Model optional field
  ///
  /// In ro, this message translates to:
  /// **'Model (Opțional)'**
  String get modelOptional;

  /// Model hint
  ///
  /// In ro, this message translates to:
  /// **'ex., X5, Galaxy S23'**
  String get modelHint;

  /// Serial number optional field
  ///
  /// In ro, this message translates to:
  /// **'Număr Serie (Opțional)'**
  String get serialNumberOptional;

  /// Serial number hint
  ///
  /// In ro, this message translates to:
  /// **'Introduceți numărul de serie dacă este aplicabil'**
  String get serialNumberHint;

  /// VIN optional field
  ///
  /// In ro, this message translates to:
  /// **'VIN (Opțional)'**
  String get vinOptional;

  /// VIN hint
  ///
  /// In ro, this message translates to:
  /// **'Număr Identificare Vehicul'**
  String get vinHint;

  /// Year optional field
  ///
  /// In ro, this message translates to:
  /// **'An (Opțional)'**
  String get yearOptional;

  /// Year hint
  ///
  /// In ro, this message translates to:
  /// **'ex., 2023'**
  String get yearHint;

  /// Condition field
  ///
  /// In ro, this message translates to:
  /// **'Stare'**
  String get condition;

  /// Condition hint
  ///
  /// In ro, this message translates to:
  /// **'ex., Nou, Folosit, Recondițional'**
  String get conditionHint;

  /// Contract price field
  ///
  /// In ro, this message translates to:
  /// **'Preț Contract'**
  String get contractPrice;

  /// Enter total price hint
  ///
  /// In ro, this message translates to:
  /// **'Introduceți prețul total'**
  String get enterTotalPrice;

  /// Currency field
  ///
  /// In ro, this message translates to:
  /// **'Monedă'**
  String get currency;

  /// Currency hint
  ///
  /// In ro, this message translates to:
  /// **'ex., RON, EUR, USD'**
  String get currencyHint;

  /// Payment method field
  ///
  /// In ro, this message translates to:
  /// **'Metodă Plată'**
  String get paymentMethod;

  /// Payment method hint
  ///
  /// In ro, this message translates to:
  /// **'ex., Numerar, Transfer Bancar, Card'**
  String get paymentMethodHint;

  /// Delivery date field
  ///
  /// In ro, this message translates to:
  /// **'Data Livrare'**
  String get deliveryDate;

  /// Delivery date hint
  ///
  /// In ro, this message translates to:
  /// **'Când va avea loc livrarea?'**
  String get deliveryDateHint;

  /// Contract location field
  ///
  /// In ro, this message translates to:
  /// **'Locație Contract'**
  String get contractLocation;

  /// Contract location hint
  ///
  /// In ro, this message translates to:
  /// **'Unde este semnat contractul?'**
  String get contractLocationHint;

  /// Additional terms optional field
  ///
  /// In ro, this message translates to:
  /// **'Termeni Suplimentari (Opțional)'**
  String get additionalTermsOptional;

  /// Additional terms hint
  ///
  /// In ro, this message translates to:
  /// **'Orice termeni sau condiții speciale'**
  String get additionalTermsHint;

  /// Warranty optional field
  ///
  /// In ro, this message translates to:
  /// **'Garanție (Opțional)'**
  String get warrantyOptional;

  /// Warranty hint
  ///
  /// In ro, this message translates to:
  /// **'Informații despre garanție'**
  String get warrantyHint;

  /// Fill all required fields message
  ///
  /// In ro, this message translates to:
  /// **'Vă rugăm să completați toate câmpurile obligatorii'**
  String get fillAllRequired;

  /// Virtual keyboard label
  ///
  /// In ro, this message translates to:
  /// **'Tastatură Virtuală'**
  String get virtualKeyboard;

  /// Previous field tooltip
  ///
  /// In ro, this message translates to:
  /// **'Câmp Anterior'**
  String get previousField;

  /// Next field tooltip
  ///
  /// In ro, this message translates to:
  /// **'Câmp Următor'**
  String get nextField;

  /// Switch to numeric keyboard
  ///
  /// In ro, this message translates to:
  /// **'Comutare la Numeric'**
  String get switchToNumeric;

  /// Switch to alphanumeric keyboard
  ///
  /// In ro, this message translates to:
  /// **'Comutare la Alfanumeric'**
  String get switchToAlphanumeric;

  /// Hide keyboard tooltip
  ///
  /// In ro, this message translates to:
  /// **'Ascunde Tastatura'**
  String get hideKeyboard;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ro'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ro':
      return AppLocalizationsRo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
