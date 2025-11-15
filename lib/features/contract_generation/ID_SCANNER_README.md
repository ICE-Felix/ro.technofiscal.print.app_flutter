# ID Card Scanner/OCR Integration (Mock Implementation)

## Overview

This feature implements a **mock ID card scanner service** with OCR (Optical Character Recognition) capabilities for Romanian ID cards (Carte de Identitate). The mock implementation simulates all scanning and data extraction operations for development and testing, providing a foundation for real hardware scanner/camera integration.

## Architecture

### 1. ID Scanner Service Interface (`lib/core/services/id_scanner_service.dart`)

**Abstract Interface (`IDScannerService`):**
```dart
abstract class IDScannerService {
  Future<IDScannerStatus> getStatus();
  Future<bool> isReady();
  Future<IDScanResult> scanIDCard();
  Future<void> cancelScan();
  bool validateCNP(String cnp);
  List<IDScanResult> getScanHistory();
  void clearHistory();
}
```

**Data Models:**

**RomanianIDCard:**
- seria, numar (ID card series and number, e.g., "RR123456")
- cnp (Personal Numerical Code - 13 digits)
- nume, prenume (last name, first name)
- dataNasterii (date of birth)
- locNastere (place of birth)
- domiciliu (full address)
- judet, localitate, strada, numarStrada (county, city, street, number)
- bloc, scara, apartament (building, staircase, apartment - optional)
- dataEmiterii, dataExpirarii (issue date, expiry date)
- emitentCI (issuing authority, e.g., "S.P.C.L.E.P. București")
- cardType (CI, Passport, Residence Permit)

**Computed Properties:**
- `numeComplet` - Full name
- `numarCI` - Full ID number (seria + numar)
- `adresaCompleta` - Full formatted address
- `isValid` - Check if not expired
- `isCNPValid` - CNP format validation
- `varsta` - Calculated age
- `gen` - Gender (from CNP first digit)

**IDScanResult:**
- success (boolean)
- idCard (RomanianIDCard or null)
- errorMessage (for failed scans)
- timestamp

**Enums:**
- `IDScannerStatus`: ready, scanning, processing, offline, error
- `IDCardType`: ci (ID card), pasaport, permis, unknown

### 2. Mock ID Scanner Service (`MockIDScannerService`)

**Singleton implementation** for development:

**Sample ID Cards (5 pre-configured):**
```dart
1. București - POPESCU ION
   CNP: 1850512345678
   Seria: RR, Numar: 123456
   Address: Str. Victoriei, nr. 123, Bl. A1, Sc. 2, Ap. 45

2. Cluj - IONESCU MARIA
   CNP: 2920315987654
   Seria: CJ, Numar: 654321
   Address: Str. Avram Iancu, nr. 45

3. Timișoara - POPA ALEXANDRU
   CNP: 1780215456789
   Seria: TM, Numar: 789012
   Address: Str. Revolutiei, nr. 78, Bl. B5, Sc. 1, Ap. 12

4. Iași - STANESCU ELENA
   CNP: 2880620123456
   Seria: IS, Numar: 345678
   Address: Str. Stefan cel Mare, nr. 156, Bl. C3, Sc. 3, Ap. 89

5. Constanța - MIHAI GEORGE
   CNP: 1950718234567
   Seria: CT, Numar: 901234
   Address: Str. Tomis, nr. 234
```

**Scan Process Flow:**
```dart
scanIDCard()
  ↓
1. Check scanner ready
2. Status: scanning (2 seconds - simulate card placement)
3. Status: processing (1.5 seconds - simulate OCR)
4. Random outcome:
   - 90% success → return random sample ID card
   - 10% failure → return error message
5. Add to scan history
6. Status: ready
7. Return IDScanResult
```

**Mock Behavior:**
- Success rate: 90% (10% random failures for testing)
- Scan time: 3.5 seconds total (2s scan + 1.5s OCR)
- Random card selection from 5 samples
- Dynamic issue/expiry dates (random 1-5 years ago, +10 years)

**Error Messages:**
- "Card nedetectat. Vă rugăm să poziționați cardul corect."
- "Imagine neclară. Vă rugăm să curățați camera."
- "OCR eșuat. Vă rugăm să reîncercați."
- "Card deteriorat. Nu se poate citi informația."

### 3. UI Components (`lib/core/widgets/id_scanner_widget.dart`)

**IDScannerStatusWidget:**
- Displays scanner status with icon
- Status text with color coding
- "Scanare CI" button when ready
- "Anulează" button during scan
- Visual feedback for each status

**IDCardDisplayWidget:**
- Romanian ID card visual representation
- Gradient card design with border
- Validity status badge (VALABIL/EXPIRAT)
- Organized sections:
  - Header: Card number, validity
  - Personal data: Name, CNP, gender, age, birth info
  - Address: Full formatted address
  - Validity: Issue/expiry dates, issuing authority
- Action buttons: Edit, Use Data

**ScanHistoryWidget:**
- Lists all scan attempts
- Reverse chronological order (newest first)
- Success/failure indicators
- Quick select from history
- Clear history button

### 4. ID Scanner Page (`lib/features/contract_generation/presentation/pages/id_scanner_page.dart`)

Full-featured scanner management:
- **Left Panel**: Scanner status, current scanned card, instructions
- **Right Panel**: Scan history
- **Features**:
  - Scan ID card button
  - Real-time scanning animation
  - OCR processing indicator
  - Card data display
  - Use data for contract auto-fill
  - Test with custom data (manual entry)
  - Scan history management
  - Auto-refresh every second

## User Flows

### Scan ID Card Flow

```
User opens ID Scanner Page
    ↓
Left panel shows: Scanner ready + Instructions
    ↓
User clicks "Scanare CI"
    ↓
Status: Scanning (2 seconds)
  - Shows circular progress indicator
  - "Scanare carte de identitate..."
  - "Vă rugăm să mențineți cardul pe scanner"
    ↓
Status: Processing (1.5 seconds)
  - Progress continues
  - "Procesare date OCR..."
  - "Se extrag datele din imagine"
    ↓
Random outcome (90% success):

SUCCESS PATH:
  ✅ Status: Ready
  ✅ Card data displayed in left panel
  ✅ Success notification shown
  ✅ Scan added to history (right panel)
  ✅ User can click "Folosește Datele"
      ↓
  Dialog shows: Extracted data summary
  Message: "Datele ar fi folosite pentru completare automată"
  ✅ Click OK to close

FAILURE PATH:
  ❌ Status: Ready
  ❌ Error notification shown
  ❌ Scan failure added to history
  ❌ User can retry scan
```

### Use Scanned Data

```
Card scanned successfully
    ↓
Card displayed with all information
    ↓
User clicks "Folosește Datele"
    ↓
Dialog shows:
  - ✓ Full name
  - ✓ CNP
  - ✓ Full address
  - Note: "În aplicația reală, aceste date ar fi folosite pentru completarea automată a contractului."
    ↓
User clicks "OK"
    ↓
(In real app, data would be passed to contract form)
```

### Select from History

```
User views scan history (right panel)
    ↓
Previous successful scans listed
    ↓
User clicks arrow button on a card
    ↓
Card data loads in left panel
    ↓
User can use this card's data
```

### Test with Custom Data

```
User clicks lab icon (test mode)
    ↓
Dialog opens: "Test cu Date Personalizate"
    ↓
User enters (optional):
  - Nume: e.g., "POPESCU"
  - CNP: e.g., "1850512345678"
    ↓
User clicks "Generează"
    ↓
Test card created with:
  - Custom name/CNP if provided
  - Random sample data for other fields
  - Random address, dates, etc.
    ↓
Card displayed in left panel
    ↓
Success notification shown
```

## Mock Behavior

### Scan Simulation

**Timing:**
- Scanning phase: 2 seconds
- OCR processing: 1.5 seconds
- Total: 3.5 seconds per scan

**Success Rate:**
- 90% success (returns valid ID card data)
- 10% failure (returns error message)

**Data Generation:**
- Randomly selects from 5 pre-configured samples
- Generates dynamic issue/expiry dates
- Issue date: Random 1-5 years ago
- Expiry date: Issue date + 10 years

### CNP (Personal Numerical Code) Validation

**Format:** SAALLZZJJNNNC
- S: Gender/century (1-9)
- AA: Year (last 2 digits)
- LL: Month (01-12)
- ZZ: Day (01-31)
- JJ: County code
- NNN: Sequential number
- C: Control digit

**Validation:**
- Length: exactly 13 digits
- Format: all numeric
- First digit: 1-9
- Month: 01-12
- Day: 01-31

### Gender Extraction

**From CNP first digit:**
- 1, 3, 5, 7: Male (Masculin)
- 2, 4, 6, 8: Female (Feminin)
- 9: Foreign resident

### Age Calculation

```dart
int age = currentYear - birthYear;
if (currentMonth < birthMonth ||
    (currentMonth == birthMonth && currentDay < birthDay)) {
  age--;
}
```

## UI Design

### Scanner Status Card

```
┌────────────────────────────────────────┐
│ ✓  Scanner Carte de Identitate        │
│    Pregătit pentru scanare             │
│                                        │
│    [      Scanare CI      ]           │ ← Blue button
└────────────────────────────────────────┘
```

### Scanning Indicator

```
┌────────────────────────────────────────┐
│            ⏳ Loading...               │
│                                        │
│  Scanare carte de identitate...       │
│  Vă rugăm să mențineți cardul pe      │
│  scanner                               │
└────────────────────────────────────────┘
```

### ID Card Display

```
┌────────────────────────────────────────┐
│ 🪪  CARTE DE IDENTITATE                │
│     RR123456              [VALABIL]    │ ← Green badge
├────────────────────────────────────────┤
│ DATE PERSONALE                         │
│                                        │
│ Nume:          POPESCU                 │
│ Prenume:       ION                     │
│ CNP:           1850512345678           │
│ Gen:           Masculin                │
│ Vârstă:        39 ani                  │
│ Data nașterii: 01.05.1985              │
│ Loc naștere:   București               │
├────────────────────────────────────────┤
│ DOMICILIU                              │
│                                        │
│ Adresă: Str. Victoriei, nr. 123,      │
│         Bl. A1, Sc. 2, Ap. 45,        │
│         București, Jud. București      │
├────────────────────────────────────────┤
│ VALABILITATE                           │
│                                        │
│ Data emiterii:  15.01.2020             │
│ Data expirării: 15.01.2030             │
│ Emitent: S.P.C.L.E.P. București       │
│                                        │
│  [Editează]  [Folosește Datele]      │
└────────────────────────────────────────┘
```

### Scan History

```
┌────────────────────────────────────┐
│ Istoric Scanări        [Șterge]   │
├────────────────────────────────────┤
│ ✓  POPESCU ION                 → │
│    CNP: 1850512345678            │
│    15.01.2025 14:32:15           │
├────────────────────────────────────┤
│ ✓  IONESCU MARIA               → │
│    CNP: 2920315987654            │
│    15.01.2025 14:28:42           │
├────────────────────────────────────┤
│ ✗  Scanare eșuată                │
│    OCR eșuat. Vă rugăm să        │
│    reîncercați.                  │
│    15.01.2025 14:25:11           │
└────────────────────────────────────┘
```

### Instructions Card

```
┌────────────────────────────────────────┐
│           🪪                           │
│                                        │
│     Instrucțiuni Scanare              │
│                                        │
│ ① 💳 Plasați cartea de identitate     │
│      pe scanner                        │
│                                        │
│ ② 📷 Apăsați butonul "Scanare CI"     │
│                                        │
│ ③ 🔄 Așteptați procesarea automată    │
│      a datelor                         │
│                                        │
│ ④ ✅ Verificați și folosiți datele    │
│      extrase                           │
│                                        │
│ ⚠️  Aceasta este o implementare mock. │
│    Scanarea și OCR sunt simulate.     │
└────────────────────────────────────────┘
```

## Features

### ✅ Implemented

**Scanning Features:**
- ✅ ID card scan simulation
- ✅ OCR processing simulation
- ✅ Romanian ID card data extraction
- ✅ Success/failure randomization
- ✅ Cancel scan functionality

**Data Extraction:**
- ✅ Personal information (name, CNP, birth date/place)
- ✅ Address parsing (street, building, apartment, county, city)
- ✅ Validity dates (issue, expiry)
- ✅ Issuing authority
- ✅ Card series and number

**Data Validation:**
- ✅ CNP format validation
- ✅ Expiry date checking
- ✅ Gender extraction from CNP
- ✅ Age calculation

**History Management:**
- ✅ Scan history tracking
- ✅ Success/failure logging
- ✅ History selection
- ✅ History clearing

**UI Features:**
- ✅ Scanner status widget
- ✅ ID card display widget
- ✅ Scan history widget
- ✅ Scanning animation
- ✅ Instructions display
- ✅ Test mode (custom data)

### 🔄 Mock Limitations

**What's Simulated:**
- ⚠️ Camera/scanner operation (delays)
- ⚠️ OCR text extraction (pre-defined samples)
- ⚠️ Random scan failures (10% error rate)
- ⚠️ Data validation (basic CNP check)

**Not Implemented:**
- ❌ Real camera access
- ❌ Actual OCR processing
- ❌ Real ID card scanning
- ❌ Image processing
- ❌ Hardware scanner integration
- ❌ Advanced CNP checksum validation

## Real Hardware Integration

To replace mock with real ID scanners/OCR:

### Option 1: Camera + OCR (Most Common for Kiosks)

**Using ML Kit (Google):**

```yaml
dependencies:
  google_mlkit_text_recognition: ^0.11.0
  camera: ^0.10.5
```

```dart
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:camera/camera.dart';

class CameraIDScannerService implements IDScannerService {
  final TextRecognizer _textRecognizer = TextRecognizer();
  CameraController? _camera;

  Future<void> initialize() async {
    final cameras = await availableCameras();
    _camera = CameraController(cameras.first, ResolutionPreset.high);
    await _camera!.initialize();
  }

  @override
  Future<IDScanResult> scanIDCard() async {
    // Capture image
    final image = await _camera!.takePicture();

    // Process with ML Kit
    final inputImage = InputImage.fromFilePath(image.path);
    final recognizedText = await _textRecognizer.processImage(inputImage);

    // Extract ID card fields
    final idCard = _extractIDCardData(recognizedText.text);

    return IDScanResult(
      success: idCard != null,
      idCard: idCard,
      timestamp: DateTime.now(),
    );
  }

  RomanianIDCard? _extractIDCardData(String text) {
    // Parse OCR text to extract fields
    // Pattern matching for:
    // - CNP: 13 digits
    // - Name: After "NUME"
    // - Address: After "DOMICILIU"
    // etc.

    final cnpRegex = RegExp(r'\b\d{13}\b');
    final cnpMatch = cnpRegex.firstMatch(text);

    if (cnpMatch == null) return null;

    // Extract other fields...
    return RomanianIDCard(...);
  }
}
```

### Option 2: Dedicated ID Scanner Hardware

**Using USB ID card readers:**

```yaml
dependencies:
  usb_serial: ^0.5.1
```

```dart
class USBIDScannerService implements IDScannerService {
  UsbPort? _port;

  Future<void> initialize() async {
    final availablePorts = await UsbSerial.listDevices();
    _port = await availablePorts.first.open();
  }

  @override
  Future<IDScanResult> scanIDCard() async {
    // Send scan command
    await _port!.write(Uint8List.fromList([0x02, 0x01]));

    // Read response
    final data = await _port!.read();
    final idCard = _parseIDCardData(data);

    return IDScanResult(
      success: idCard != null,
      idCard: idCard,
      timestamp: DateTime.now(),
    );
  }

  RomanianIDCard? _parseIDCardData(Uint8List data) {
    // Parse binary data from scanner
    // Format depends on scanner model
    return RomanianIDCard(...);
  }
}
```

### Option 3: NFC Reader (for Romanian eID cards)

**Romanian ID cards have NFC chips (since 2009):**

```yaml
dependencies:
  nfc_manager: ^3.3.0
```

```dart
import 'package:nfc_manager/nfc_manager.dart';

class NFCIDScannerService implements IDScannerService {
  @override
  Future<IDScanResult> scanIDCard() async {
    RomanianIDCard? idCard;

    await NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        // Read NFC data
        final ndefMessage = await Ndef.from(tag)?.read();

        if (ndefMessage != null) {
          idCard = _parseNFCData(ndefMessage);
        }
      },
    );

    return IDScanResult(
      success: idCard != null,
      idCard: idCard,
      timestamp: DateTime.now(),
    );
  }

  RomanianIDCard? _parseNFCData(NdefMessage message) {
    // Parse NDEF records
    // Romanian eID contains:
    // - DG1: MRZ (Machine Readable Zone)
    // - DG2: Face image
    // - DG13: Optional data

    return RomanianIDCard(...);
  }
}
```

### Option 4: QR Code Scanner (Alternative)

**For test environments or simplified flow:**

```yaml
dependencies:
  mobile_scanner: ^4.0.0
```

```dart
import 'package:mobile_scanner/mobile_scanner.dart';

class QRCodeIDScannerService implements IDScannerService {
  @override
  Future<IDScanResult> scanIDCard() async {
    // Show QR scanner UI
    // User scans QR code containing ID data
    // Parse JSON from QR code

    final qrData = await _scanQRCode();
    final idCard = _parseQRData(qrData);

    return IDScanResult(
      success: idCard != null,
      idCard: idCard,
      timestamp: DateTime.now(),
    );
  }
}
```

## Integration with Contract Flow

**Auto-fill contract from scanned ID:**

```dart
// In single_field_flow_page.dart

Future<void> _scanAndFillIDCard() async {
  final scannerService = MockIDScannerService();

  final result = await scannerService.scanIDCard();

  if (result.success && result.idCard != null) {
    final idCard = result.idCard!;

    // Auto-fill contract form fields
    setState(() {
      nameController.text = idCard.numeComplet;
      cnpController.text = idCard.cnp;
      addressController.text = idCard.adresaCompleta;
      cityController.text = idCard.localitate;
      countyController.text = idCard.judet;

      // Validate data
      if (!idCard.isValid) {
        showWarning('Atenție: Cartea de identitate a expirat!');
      }

      if (!idCard.isCNPValid) {
        showWarning('CNP invalid detectat');
      }
    });

    // Show success notification
    showSuccess('Date completate automat din cartea de identitate');
  } else {
    showError(result.errorMessage ?? 'Scanare eșuată');
  }
}
```

## Romanian Compliance

**ID Card Format:**
- Series: 2 letters (county code, e.g., "RR" for București)
- Number: 6 digits
- Full format: "RR123456"

**CNP (Cod Numeric Personal):**
- 13 digits mandatory
- Format validation required
- Used for identity verification
- Linked to birth date and gender

**Address Format:**
- Street (Strada): Required
- Number (Număr): Required
- Building (Bloc): Optional
- Staircase (Scara): Optional
- Apartment (Apartament): Optional
- City (Localitate): Required
- County (Județ): Required

**Issuing Authority:**
- Format: "S.P.C.L.E.P. {County}"
- Example: "S.P.C.L.E.P. București"

## Testing

### Test Scan

1. **Run app**: `flutter run`
2. **Navigate**: Home → ID Scanner
3. **Click "Scanare CI"**
4. **Watch animation**: Scanning → Processing
5. **Result**: 90% success, 10% failure
6. **View data**: Card displayed if successful

### Test with Custom Data

1. **Click lab icon** (top right)
2. **Enter test data**:
   - Name: "POPESCU" (optional)
   - CNP: "1850512345678" (optional)
3. **Click "Generează"**
4. **View result**: Test card with custom/random data

### Test History

1. **Scan multiple times**
2. **View history** (right panel)
3. **Click arrow** on previous scan
4. **Card loads** in left panel
5. **Click "Folosește Datele"**

## Performance

**Mock Service:**
- Scan time: 3.5 seconds
- OCR processing: Simulated (instant)
- Success rate: 90%
- Memory usage: ~1-2MB for history

**Real Implementation (Estimated):**
- Camera capture: 0.5-1 second
- OCR processing: 2-5 seconds
- Total: 3-6 seconds
- Accuracy: 85-95% (depends on image quality)

## File Structure

```
lib/
├── core/
│   ├── services/
│   │   └── id_scanner_service.dart         # Interface + Mock
│   └── widgets/
│       └── id_scanner_widget.dart          # UI components
└── features/
    └── contract_generation/
        ├── presentation/
        │   └── pages/
        │       └── id_scanner_page.dart
        └── ID_SCANNER_README.md             # This file
```

## Next Steps

### Short Term (Mock Enhancements)
- [ ] More sample ID cards (different counties)
- [ ] Expired card samples
- [ ] Invalid CNP samples
- [ ] Confidence score simulation
- [ ] Image quality simulation

### Long Term (Real Hardware)
- [ ] Implement camera access
- [ ] Integrate Google ML Kit OCR
- [ ] Add image preprocessing (crop, rotate, enhance)
- [ ] Implement CNP checksum validation
- [ ] Add NFC reader support
- [ ] Implement field-by-field extraction
- [ ] Add manual correction interface
- [ ] Romanian ID template matching
- [ ] Data verification service integration

---

**Status**: ✅ Mock implementation complete
**Production Ready**: ⚠️ Requires real camera/scanner integration
**Version**: 1.0 (Mock)
**Last Updated**: January 2025
