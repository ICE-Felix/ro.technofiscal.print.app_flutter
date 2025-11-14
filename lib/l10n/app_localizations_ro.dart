// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appTitle => 'ContractKiosk';

  @override
  String get contractGeneration => 'Generare Contract';

  @override
  String get salePurchaseContract => 'Contract Vânzare-Cumpărare';

  @override
  String get loading => 'Se încarcă...';

  @override
  String get error => 'Eroare';

  @override
  String get fieldNotFound => 'Câmpul nu a fost găsit';

  @override
  String get failedToInitialize => 'Inițializarea a eșuat';

  @override
  String get noCurrentField => 'Niciun câmp curent';

  @override
  String get exitContractGeneration => 'Ieșiți din generarea contractului?';

  @override
  String get progressSaved =>
      'Progresul dvs. a fost salvat. Puteți continua mai târziu de unde ați rămas.';

  @override
  String get continueBtn => 'Continuă';

  @override
  String get exitBtn => 'Ieșire';

  @override
  String get previous => 'Înapoi';

  @override
  String get next => 'Următorul';

  @override
  String get skip => 'Sari peste';

  @override
  String get complete => 'Finalizare';

  @override
  String get done => 'Terminat';

  @override
  String fieldXofY(int current, int total) {
    return 'Câmpul $current din $total';
  }

  @override
  String get sellerInformation => 'Informații Vânzător';

  @override
  String get buyerInformation => 'Informații Cumpărător';

  @override
  String get objectDetails => 'Detalii Obiect';

  @override
  String get contractDetails => 'Detalii Contract';

  @override
  String get summary => 'Sumar';

  @override
  String get entityTypeSelection => 'Selectare Tip Entitate';

  @override
  String get pleaseSelectEntityType =>
      'Vă rugăm să selectați tipul de entitate';

  @override
  String get chooseEntityType =>
      'Alegeți dacă aceasta este o persoană fizică sau o persoană juridică/companie';

  @override
  String get individualPerson => 'Persoană Fizică';

  @override
  String get forPersonalTransactions => 'Pentru tranzacții personale';

  @override
  String get companyLegalEntity => 'Companie / Persoană Juridică';

  @override
  String get forBusinessTransactions => 'Pentru tranzacții de afaceri';

  @override
  String get selectedIndividual => 'Selectat: Persoană Fizică';

  @override
  String get selectedCompany => 'Selectat: Companie/Persoană Juridică';

  @override
  String get entityTypeInfo =>
      'Această selecție va determina ce documente și informații sunt necesare';

  @override
  String get optionalFieldInfo =>
      'Câmp opțional - puteți sări peste dacă nu este aplicabil';

  @override
  String get yourProgress => 'Progresul Dvs.';

  @override
  String completedFields(int completed, int total) {
    return '$completed din $total câmpuri completate';
  }

  @override
  String get contractSummary => 'Sumar Contract';

  @override
  String get reviewInformation =>
      'Vă rugăm să revizuiți informațiile înainte de a genera contractul:';

  @override
  String get reviewData => 'Revizuiește Datele';

  @override
  String get generateContract => 'Generează Contract';

  @override
  String get contractGeneratedSuccess => 'Contract generat cu succes!';

  @override
  String get contractGeneratedMessage =>
      'Contractul dvs. a fost generat. Acum îl puteți tipări sau salva pentru evidențele dvs.';

  @override
  String get close => 'Închide';

  @override
  String get printContract => 'Tipărește Contract';

  @override
  String get fullNameCompanyName => 'Nume Complet / Denumire Companie';

  @override
  String get enterFullLegalName => 'Introduceți numele legal complet';

  @override
  String get cnpCui => 'CNP / CUI';

  @override
  String get enterCnpOrCui => 'Introduceți CNP (personal) sau CUI (companie)';

  @override
  String get idSeries => 'Serie CI';

  @override
  String get idSeriesHint => 'ex., RX';

  @override
  String get idNumber => 'Număr CI';

  @override
  String get enterIdNumber => 'Introduceți numărul cărții de identitate';

  @override
  String get country => 'Țară';

  @override
  String get countryHint => 'ex., România';

  @override
  String get county => 'Județ';

  @override
  String get countyHint => 'ex., Cluj';

  @override
  String get city => 'Oraș';

  @override
  String get cityHint => 'ex., Cluj-Napoca';

  @override
  String get postalCode => 'Cod Poștal';

  @override
  String get postalCodeHint => 'ex., 400001';

  @override
  String get street => 'Stradă';

  @override
  String get enterStreetName => 'Introduceți numele străzii';

  @override
  String get streetNumber => 'Număr Stradă';

  @override
  String get streetNumberHint => 'ex., 123';

  @override
  String get phoneNumber => 'Număr Telefon';

  @override
  String get phoneHint => '+40 123 456 789';

  @override
  String get emailOptional => 'Email (Opțional)';

  @override
  String get emailHint => 'email@exemplu.com';

  @override
  String get objectCategory => 'Categorie Obiect';

  @override
  String get objectCategoryHint => 'ex., Vehicul, Electronice, Imobiliare';

  @override
  String get objectDescription => 'Descriere Obiect';

  @override
  String get objectDescriptionHint => 'Descriere detaliată a obiectului';

  @override
  String get brandOptional => 'Marcă (Opțional)';

  @override
  String get brandHint => 'ex., BMW, Samsung';

  @override
  String get modelOptional => 'Model (Opțional)';

  @override
  String get modelHint => 'ex., X5, Galaxy S23';

  @override
  String get serialNumberOptional => 'Număr Serie (Opțional)';

  @override
  String get serialNumberHint =>
      'Introduceți numărul de serie dacă este aplicabil';

  @override
  String get vinOptional => 'VIN (Opțional)';

  @override
  String get vinHint => 'Număr Identificare Vehicul';

  @override
  String get yearOptional => 'An (Opțional)';

  @override
  String get yearHint => 'ex., 2023';

  @override
  String get condition => 'Stare';

  @override
  String get conditionHint => 'ex., Nou, Folosit, Recondițional';

  @override
  String get contractPrice => 'Preț Contract';

  @override
  String get enterTotalPrice => 'Introduceți prețul total';

  @override
  String get currency => 'Monedă';

  @override
  String get currencyHint => 'ex., RON, EUR, USD';

  @override
  String get paymentMethod => 'Metodă Plată';

  @override
  String get paymentMethodHint => 'ex., Numerar, Transfer Bancar, Card';

  @override
  String get deliveryDate => 'Data Livrare';

  @override
  String get deliveryDateHint => 'Când va avea loc livrarea?';

  @override
  String get contractLocation => 'Locație Contract';

  @override
  String get contractLocationHint => 'Unde este semnat contractul?';

  @override
  String get additionalTermsOptional => 'Termeni Suplimentari (Opțional)';

  @override
  String get additionalTermsHint => 'Orice termeni sau condiții speciale';

  @override
  String get warrantyOptional => 'Garanție (Opțional)';

  @override
  String get warrantyHint => 'Informații despre garanție';

  @override
  String get fillAllRequired =>
      'Vă rugăm să completați toate câmpurile obligatorii';

  @override
  String get virtualKeyboard => 'Tastatură Virtuală';

  @override
  String get previousField => 'Câmp Anterior';

  @override
  String get nextField => 'Câmp Următor';

  @override
  String get switchToNumeric => 'Comutare la Numeric';

  @override
  String get switchToAlphanumeric => 'Comutare la Alfanumeric';

  @override
  String get hideKeyboard => 'Ascunde Tastatura';
}
