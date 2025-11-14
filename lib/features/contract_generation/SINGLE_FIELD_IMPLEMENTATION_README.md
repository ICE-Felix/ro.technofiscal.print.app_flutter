# Single-Field-Per-Screen Contract Generation

This implementation replicates the **Kivy Python project's** one-field-per-screen pattern in Flutter, providing the exact same user experience adapted to Flutter's architecture.

## Overview

The contract generation feature now uses a single-field-per-screen approach where:
- **One input field is displayed at a time** (like the Kivy app)
- **Virtual keyboard** appears automatically when the field is tapped
- **Sequential navigation** with Previous/Next buttons
- **Progress tracking** shows completion percentage and section status
- **Auto-save** after each field using SharedPreferences
- **Resume capability** to continue from where the user left off

## Architecture

### Core Components

#### 1. **FieldRegistry** (`data/field_registry.dart`)
Centralized registry of all 43+ contract fields with metadata:
- Field definitions (label, hint, icon, keyboard type)
- Validation requirements
- Navigation links (next/previous field)
- Section grouping

```dart
// Example usage
final field = FieldRegistry.getField('seller_full_name');
final allFields = FieldRegistry.getAllFields();
final isLast = FieldRegistry.isLastField(fieldKey);
```

#### 2. **ContractDataManager** (`data/contract_data_manager.dart`)
Manages data persistence using SharedPreferences:
- Field-by-field data storage
- Current field tracking (for resume)
- Completion percentage calculation
- Section-based data summary
- Import/export as JSON

```dart
// Example usage
final dataManager = await ContractDataManager.create();
await dataManager.setField('seller_full_name', 'John Doe');
final value = dataManager.getField('seller_full_name');
final isComplete = dataManager.isComplete();
```

#### 3. **Validators** (`data/validators.dart`)
Romanian-specific validation functions:
- CNP (Cod Numeric Personal) validation with checksum
- CUI (Cod Unic de Identificare) validation
- VIN (Vehicle Identification Number) validation
- Phone number (Romanian format: +40XXXXXXXXX or 0XXXXXXXXX)
- Postal code (6 digits)
- ID series/number validation
- Email, year, price validation

```dart
// Example usage
final error = ContractValidators.validateCNP('1234567890123');
final phoneError = ContractValidators.validatePhone('+40712345678');
```

#### 4. **SingleFieldScreen** (`presentation/widgets/single_field_screen.dart`)
Reusable template widget for displaying a single field:
- Auto-focus on field
- Real-time validation
- Progress indicator
- Section summary display
- Optional field skip functionality
- Navigation buttons (Previous/Next/Complete)

#### 5. **SingleFieldFlowPage** (`presentation/pages/single_field_flow_page.dart`)
Main orchestrator (like Kivy's ScreenManager):
- Manages field progression
- Handles navigation between fields
- Shows summary dialog on completion
- Exit confirmation with progress save
- Contract generation

## User Flow

### Step-by-Step Process

1. **Start Contract Generation**
   - User clicks "Incepe Generarea" button on home page
   - App loads/creates ContractDataManager
   - First field is displayed (Seller Entity Type)

2. **Fill Each Field**
   - Field label, hint, and icon displayed prominently
   - Virtual keyboard appears automatically
   - User enters data
   - Real-time validation as they type
   - Optional fields can be skipped

3. **Navigate Between Fields**
   - **Next** button: Validates and moves to next field
   - **Previous** button: Goes back (saves current value)
   - **Skip** button: Available for optional fields
   - Progress bar shows % completion

4. **Progress Tracking**
   - Progress percentage in app bar (e.g., "45%")
   - "Field X of Y" indicator
   - Section-wise completion shown in summary card
   - Linear progress bar at top

5. **Complete Contract**
   - After last field, **Complete** button appears
   - Summary dialog shows all entered data grouped by section
   - User reviews and confirms
   - **Generate Contract** creates the final document

6. **Resume Capability**
   - If user exits mid-flow, progress is saved
   - On return, app resumes from last field
   - Exit confirmation dialog explains progress is saved

## Field Structure

### 43 Total Fields Across 4 Sections

#### Seller Information (13 fields)
- Entity Type (Individual/Company)
- Full Name / Company Name
- CNP / CUI
- ID Series, ID Number
- Country, County, City
- Postal Code, Street, Street Number
- Phone Number
- Email (Optional)

#### Buyer Information (13 fields)
- Same structure as Seller

#### Object Details (8 fields)
- Category
- Description
- Brand (Optional)
- Model (Optional)
- Serial Number (Optional)
- VIN (Optional)
- Year (Optional)
- Condition

#### Contract Details (7 fields)
- Price
- Currency
- Payment Method
- Delivery Date
- Location
- Additional Terms (Optional)
- Warranty (Optional)

## Integration

### Route Configuration

The single-field flow is registered in the app routing:

```dart
// routes_name.dart
contractGenerationSingleField(
  name: 'contract_generation_single_field',
  path: '/contract-generation-single-field',
),

// routes.dart
GoRoute(
  path: AppRoutesNames.contractGenerationSingleField.path,
  name: AppRoutesNames.contractGenerationSingleField.name,
  builder: (context, state) => const SingleFieldFlowPage(),
),
```

### Home Page Integration

The "Incepe Generarea" button now navigates to the single-field flow:

```dart
onTap: () {
  context.goNamed(
    AppRoutesNames.contractGenerationSingleField.name,
  );
},
```

## Key Features

### 1. **Automatic Virtual Keyboard**
- Uses `virtual_keyboard_multi_language` package
- Automatically shows numeric or alphanumeric keyboard
- Toggle between keyboard types
- Hide keyboard button
- Full keyboard wrapper integration

### 2. **Smart Navigation**
- Previous button disabled on first field
- Next button becomes "Complete" on last field
- Skip button for optional fields
- Enter key moves to next field

### 3. **Progress Tracking**
- Overall completion percentage
- Field counter (e.g., "Field 15 of 43")
- Section-wise progress bars
- Visual progress indicator at top

### 4. **Data Persistence**
- Auto-save after each field
- SharedPreferences for local storage
- Resume from last field
- Export/import as JSON

### 5. **Validation**
- Real-time validation as user types
- Romanian-specific validators (CNP, CUI, VIN)
- Required vs optional field handling
- Error messages in Romanian

### 6. **User Experience**
- Large field display (one at a time)
- Clear labels and hints
- Prominent icons for each field
- Progress summary card
- Exit confirmation with save

## Comparison with Kivy Implementation

| Feature | Kivy Python | Flutter Implementation |
|---------|-------------|----------------------|
| Fields per screen | 1 | 1 ✓ |
| Screen count | 80+ screens | 43 fields (reusable template) |
| Navigation | ScreenManager | SingleFieldFlowPage |
| Data storage | JSON file | SharedPreferences |
| Keyboard | Custom VirtualKeyboard | virtual_keyboard_multi_language |
| Validators | Custom Python validators | ContractValidators class |
| Field registry | Hardcoded in screens | FieldRegistry class |
| Resume capability | Yes | Yes ✓ |
| Progress tracking | Basic | Enhanced with percentages |

## Testing

To test the complete flow:

1. Run the app: `flutter run`
2. Navigate to Home page
3. Click "Incepe Generarea" button
4. Go through each field:
   - Test validation (try entering invalid data)
   - Test navigation (Previous/Next)
   - Test skip for optional fields
   - Test keyboard types (numeric/alphanumeric)
5. Exit mid-flow and return (test resume)
6. Complete all fields and review summary
7. Generate contract

## Future Enhancements

- [ ] Add document scanning integration
- [ ] Implement actual contract PDF generation
- [ ] Add print functionality
- [ ] Add fiscal receipt generation
- [ ] Implement barcode/QR code scanning for VIN
- [ ] Add signature capture fields
- [ ] Multi-language support
- [ ] Cloud sync capability
- [ ] Contract templates

## Files Created/Modified

### New Files
- `data/field_registry.dart` - Field definitions
- `data/contract_data_manager.dart` - Data persistence
- `data/validators.dart` - Validation functions
- `presentation/widgets/single_field_screen.dart` - Single field template
- `presentation/pages/single_field_flow_page.dart` - Flow orchestrator

### Modified Files
- `core/navigation/routes_name.dart` - Added single-field route
- `core/navigation/routes.dart` - Registered single-field page
- `features/home/presentation/pages/home_page.dart` - Updated button navigation

## Notes

This implementation provides the **exact same user experience** as the Kivy Python application, with each field presented one at a time, while leveraging Flutter's strengths:
- Reusable widget architecture
- Type-safe field definitions
- Declarative UI
- Cross-platform compatibility
- Better state management

The original multi-step wizard (`ContractGenerationPage`) is still available for reference but is no longer the default flow.
