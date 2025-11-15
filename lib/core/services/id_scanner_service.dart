import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// ID scanner status
enum IDScannerStatus {
  ready,
  scanning,
  processing,
  offline,
  error,
}

/// ID card type (Romanian)
enum IDCardType {
  ci,             // Carte de Identitate (ID Card)
  pasaport,       // Pașaport (Passport)
  permis,         // Permis de ședere (Residence Permit)
  unknown,
}

/// Romanian ID card data model
class RomanianIDCard {
  final String seria;              // Series (e.g., "RR")
  final String numar;              // Number (e.g., "123456")
  final String cnp;                // Personal Numerical Code (13 digits)
  final String nume;               // Last name
  final String prenume;            // First name
  final DateTime dataNasterii;     // Date of birth
  final String locNastere;         // Place of birth
  final String domiciliu;          // Address
  final String judet;              // County
  final String localitate;         // City
  final String strada;             // Street
  final String numarStrada;        // Street number
  final String? bloc;              // Building (optional)
  final String? scara;             // Staircase (optional)
  final String? apartament;        // Apartment (optional)
  final DateTime dataEmiterii;     // Issue date
  final DateTime dataExpirarii;    // Expiration date
  final String emitentCI;          // Issuing authority
  final IDCardType cardType;

  const RomanianIDCard({
    required this.seria,
    required this.numar,
    required this.cnp,
    required this.nume,
    required this.prenume,
    required this.dataNasterii,
    required this.locNastere,
    required this.domiciliu,
    required this.judet,
    required this.localitate,
    required this.strada,
    required this.numarStrada,
    this.bloc,
    this.scara,
    this.apartament,
    required this.dataEmiterii,
    required this.dataExpirarii,
    required this.emitentCI,
    required this.cardType,
  });

  /// Get full name
  String get numeComplet => '$nume $prenume';

  /// Get ID card number (seria + numar)
  String get numarCI => '$seria$numar';

  /// Get full address
  String get adresaCompleta {
    final parts = [
      'Str. $strada, nr. $numarStrada',
      if (bloc != null) 'Bl. $bloc',
      if (scara != null) 'Sc. $scara',
      if (apartament != null) 'Ap. $apartament',
      localitate,
      'Jud. $judet',
    ];
    return parts.join(', ');
  }

  /// Check if ID is valid (not expired)
  bool get isValid => DateTime.now().isBefore(dataExpirarii);

  /// Check if CNP is valid format (13 digits)
  bool get isCNPValid => cnp.length == 13 && int.tryParse(cnp) != null;

  /// Get age
  int get varsta {
    final today = DateTime.now();
    int age = today.year - dataNasterii.year;
    if (today.month < dataNasterii.month ||
        (today.month == dataNasterii.month && today.day < dataNasterii.day)) {
      age--;
    }
    return age;
  }

  /// Extract gender from CNP (first digit: odd = male, even = female)
  String get gen {
    final firstDigit = int.parse(cnp[0]);
    return (firstDigit % 2 == 1) ? 'Masculin' : 'Feminin';
  }
}

/// Scan result
class IDScanResult {
  final bool success;
  final RomanianIDCard? idCard;
  final String? errorMessage;
  final DateTime timestamp;

  const IDScanResult({
    required this.success,
    this.idCard,
    this.errorMessage,
    required this.timestamp,
  });
}

/// Abstract ID scanner service interface
abstract class IDScannerService {
  /// Get scanner status
  Future<IDScannerStatus> getStatus();

  /// Check if scanner is ready
  Future<bool> isReady();

  /// Scan ID card
  Future<IDScanResult> scanIDCard();

  /// Cancel current scan
  Future<void> cancelScan();

  /// Validate CNP (Personal Numerical Code)
  bool validateCNP(String cnp);

  /// Get scan history
  List<IDScanResult> getScanHistory();

  /// Clear scan history
  void clearHistory();
}

/// Mock ID scanner service for development
class MockIDScannerService implements IDScannerService {
  static final MockIDScannerService _instance =
      MockIDScannerService._internal();
  factory MockIDScannerService() => _instance;
  MockIDScannerService._internal();

  // Mock state
  IDScannerStatus _status = IDScannerStatus.ready;
  final List<IDScanResult> _scanHistory = [];
  final Random _random = Random();

  // Mock sample data
  static final List<Map<String, dynamic>> _sampleIDCards = [
    {
      'seria': 'RR',
      'numar': '123456',
      'cnp': '1850512345678',
      'nume': 'POPESCU',
      'prenume': 'ION',
      'dataNasterii': DateTime(1985, 5, 1),
      'locNastere': 'București',
      'judet': 'București',
      'localitate': 'București',
      'strada': 'Victoriei',
      'numarStrada': '123',
      'bloc': 'A1',
      'scara': '2',
      'apartament': '45',
      'emitentCI': 'S.P.C.L.E.P. București',
    },
    {
      'seria': 'CJ',
      'numar': '654321',
      'cnp': '2920315987654',
      'nume': 'IONESCU',
      'prenume': 'MARIA',
      'dataNasterii': DateTime(1992, 3, 1),
      'locNastere': 'Cluj-Napoca',
      'judet': 'Cluj',
      'localitate': 'Cluj-Napoca',
      'strada': 'Avram Iancu',
      'numarStrada': '45',
      'bloc': null,
      'scara': null,
      'apartament': null,
      'emitentCI': 'S.P.C.L.E.P. Cluj',
    },
    {
      'seria': 'TM',
      'numar': '789012',
      'cnp': '1780215456789',
      'nume': 'POPA',
      'prenume': 'ALEXANDRU',
      'dataNasterii': DateTime(1978, 2, 1),
      'locNastere': 'Timișoara',
      'judet': 'Timiș',
      'localitate': 'Timișoara',
      'strada': 'Revolutiei',
      'numarStrada': '78',
      'bloc': 'B5',
      'scara': '1',
      'apartament': '12',
      'emitentCI': 'S.P.C.L.E.P. Timiș',
    },
    {
      'seria': 'IS',
      'numar': '345678',
      'cnp': '2880620123456',
      'nume': 'STANESCU',
      'prenume': 'ELENA',
      'dataNasterii': DateTime(1988, 6, 20),
      'locNastere': 'Iași',
      'judet': 'Iași',
      'localitate': 'Iași',
      'strada': 'Stefan cel Mare',
      'numarStrada': '156',
      'bloc': 'C3',
      'scara': '3',
      'apartament': '89',
      'emitentCI': 'S.P.C.L.E.P. Iași',
    },
    {
      'seria': 'CT',
      'numar': '901234',
      'cnp': '1950718234567',
      'nume': 'MIHAI',
      'prenume': 'GEORGE',
      'dataNasterii': DateTime(1995, 7, 18),
      'locNastere': 'Constanța',
      'judet': 'Constanța',
      'localitate': 'Constanța',
      'strada': 'Tomis',
      'numarStrada': '234',
      'bloc': null,
      'scara': null,
      'apartament': null,
      'emitentCI': 'S.P.C.L.E.P. Constanța',
    },
  ];

  @override
  Future<IDScannerStatus> getStatus() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _status;
  }

  @override
  Future<bool> isReady() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _status == IDScannerStatus.ready;
  }

  @override
  Future<IDScanResult> scanIDCard() async {
    if (_status != IDScannerStatus.ready) {
      throw Exception('Scanner not ready. Status: $_status');
    }

    debugPrint('📷 Starting ID card scan...');

    // Simulate scanning process
    _status = IDScannerStatus.scanning;
    await Future.delayed(const Duration(seconds: 2));

    // Simulate OCR processing
    _status = IDScannerStatus.processing;
    debugPrint('   Processing OCR data...');
    await Future.delayed(const Duration(milliseconds: 1500));

    // Random outcome (90% success rate)
    final isSuccess = _random.nextDouble() > 0.10;

    IDScanResult result;

    if (isSuccess) {
      // Generate random ID card from samples
      final sampleData = _sampleIDCards[_random.nextInt(_sampleIDCards.length)];

      // Add some randomness to dates
      final issueDate = DateTime.now().subtract(
        Duration(days: 365 * (1 + _random.nextInt(5))),
      );
      final expiryDate = issueDate.add(const Duration(days: 365 * 10));

      final idCard = RomanianIDCard(
        seria: sampleData['seria'],
        numar: sampleData['numar'],
        cnp: sampleData['cnp'],
        nume: sampleData['nume'],
        prenume: sampleData['prenume'],
        dataNasterii: sampleData['dataNasterii'],
        locNastere: sampleData['locNastere'],
        domiciliu: _buildAddress(sampleData),
        judet: sampleData['judet'],
        localitate: sampleData['localitate'],
        strada: sampleData['strada'],
        numarStrada: sampleData['numarStrada'],
        bloc: sampleData['bloc'],
        scara: sampleData['scara'],
        apartament: sampleData['apartament'],
        dataEmiterii: issueDate,
        dataExpirarii: expiryDate,
        emitentCI: sampleData['emitentCI'],
        cardType: IDCardType.ci,
      );

      result = IDScanResult(
        success: true,
        idCard: idCard,
        timestamp: DateTime.now(),
      );

      debugPrint('✅ ID card scanned successfully');
      debugPrint('   Name: ${idCard.numeComplet}');
      debugPrint('   CNP: ${idCard.cnp}');
      debugPrint('   ID: ${idCard.numarCI}');
    } else {
      // Simulate scan failure
      final errors = [
        'Card nedetectat. Vă rugăm să poziționați cardul corect.',
        'Imagine neclară. Vă rugăm să curățați camera.',
        'OCR eșuat. Vă rugăm să reîncercați.',
        'Card deteriorat. Nu se poate citi informația.',
      ];

      result = IDScanResult(
        success: false,
        errorMessage: errors[_random.nextInt(errors.length)],
        timestamp: DateTime.now(),
      );

      debugPrint('❌ ID scan failed: ${result.errorMessage}');
    }

    _scanHistory.add(result);
    _status = IDScannerStatus.ready;

    return result;
  }

  @override
  Future<void> cancelScan() async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (_status == IDScannerStatus.ready) {
      throw Exception('No active scan to cancel');
    }

    debugPrint('❌ ID scan cancelled');
    _status = IDScannerStatus.ready;
  }

  @override
  bool validateCNP(String cnp) {
    // Basic CNP validation
    if (cnp.length != 13) return false;
    if (int.tryParse(cnp) == null) return false;

    // Check first digit (gender and century)
    final firstDigit = int.parse(cnp[0]);
    if (firstDigit < 1 || firstDigit > 9) return false;

    // Extract and validate date components
    final year = int.parse(cnp.substring(1, 3));
    final month = int.parse(cnp.substring(3, 5));
    final day = int.parse(cnp.substring(5, 7));

    if (month < 1 || month > 12) return false;
    if (day < 1 || day > 31) return false;

    // Simplified validation (full validation would include checksum)
    return true;
  }

  @override
  List<IDScanResult> getScanHistory() {
    return List.unmodifiable(_scanHistory);
  }

  @override
  void clearHistory() {
    _scanHistory.clear();
    debugPrint('🗑️ ID scan history cleared');
  }

  /// Helper: Build full address from sample data
  String _buildAddress(Map<String, dynamic> data) {
    final parts = [
      'Str. ${data['strada']}, nr. ${data['numarStrada']}',
      if (data['bloc'] != null) 'Bl. ${data['bloc']}',
      if (data['scara'] != null) 'Sc. ${data['scara']}',
      if (data['apartament'] != null) 'Ap. ${data['apartament']}',
      data['localitate'],
      'Jud. ${data['judet']}',
    ];
    return parts.join(', ');
  }

  /// Helper: Reset for testing
  void reset() {
    _status = IDScannerStatus.ready;
    _scanHistory.clear();
    debugPrint('🔄 ID scanner reset');
  }

  /// Helper: Get successful scans
  List<RomanianIDCard> getSuccessfulScans() {
    return _scanHistory
        .where((result) => result.success && result.idCard != null)
        .map((result) => result.idCard!)
        .toList();
  }

  /// Helper: Manually create a test ID card
  RomanianIDCard createTestIDCard({
    String? nume,
    String? prenume,
    String? cnp,
  }) {
    final sample = _sampleIDCards[_random.nextInt(_sampleIDCards.length)];
    final issueDate = DateTime.now().subtract(const Duration(days: 365 * 2));
    final expiryDate = issueDate.add(const Duration(days: 365 * 10));

    return RomanianIDCard(
      seria: sample['seria'],
      numar: sample['numar'],
      cnp: cnp ?? sample['cnp'],
      nume: nume ?? sample['nume'],
      prenume: prenume ?? sample['prenume'],
      dataNasterii: sample['dataNasterii'],
      locNastere: sample['locNastere'],
      domiciliu: _buildAddress(sample),
      judet: sample['judet'],
      localitate: sample['localitate'],
      strada: sample['strada'],
      numarStrada: sample['numarStrada'],
      bloc: sample['bloc'],
      scara: sample['scara'],
      apartament: sample['apartament'],
      dataEmiterii: issueDate,
      dataExpirarii: expiryDate,
      emitentCI: sample['emitentCI'],
      cardType: IDCardType.ci,
    );
  }
}
