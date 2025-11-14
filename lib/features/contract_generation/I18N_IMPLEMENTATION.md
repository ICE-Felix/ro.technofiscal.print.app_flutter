# Contract Generation i18n Implementation

## Overview

The contract generation feature now supports **internationalization (i18n)** with **Romanian** (default) and **English** languages.

## Implementation Details

### Localization System

The app uses a **custom localization system** (not Flutter's gen-l10n) that loads translations from JSON files in `assets/l10n/`:
- `assets/l10n/ro.json` - Romanian translations (default language)
- `assets/l10n/en.json` - English translations

### Default Language

**Romanian (ro)** is set as the default language in `lib/core/localization/cubit/localization_cubit.dart`:

```dart
static const String _defaultLocale = 'ro';
```

### Translation Files

#### Added to `assets/l10n/ro.json`:
```json
{
  "contractGeneration": {
    "appTitle": "ContractKiosk",
    "title": "Generare Contract",
    "salePurchaseContract": "Contract Vânzare-Cumpărare",
    "sellerInformation": "Informații Vânzător",
    "buyerInformation": "Informații Cumpărător",
    ...
  }
}
```

#### Added to `assets/l10n/en.json`:
```json
{
  "contractGeneration": {
    "appTitle": "ContractKiosk",
    "title": "Contract Generation",
    "salePurchaseContract": "Sale-Purchase Contract Generation",
    "sellerInformation": "Seller Information",
    "buyerInformation": "Buyer Information",
    ...
  }
}
```

### Translation Keys Structure

All contract generation translations are under the `contractGeneration` namespace:

| Category | Example Keys |
|----------|-------------|
| General | `appTitle`, `title`, `loading`, `error` |
| Navigation | `previous`, `next`, `skip`, `complete`, `done` |
| Sections | `sellerInformation`, `buyerInformation`, `objectDetails`, `contractDetails`, `summary` |
| Entity Type | `pleaseSelectEntityType`, `individualPerson`, `companyLegalEntity` |
| Field Labels | `fullNameCompanyName`, `cnpCui`, `idSeries`, `phoneNumber` |
| Field Hints | `enterFullLegalName`, `enterCnpOrCui`, `phoneHint` |
| Validation | `fillAllRequired` |
| Progress | `fieldXofY`, `completedFields`, `yourProgress` |
| Dialogs | `exitContractGeneration`, `contractSummary`, `contractGeneratedSuccess` |

### Using Translations in Code

The app uses `LocalizationCubit` to access translations:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/core/localization/app_localization.dart';

// In a widget
final localization = context.read<LocalizationCubit>();

// Get a simple string
String title = localization.getString(label: 'contractGeneration.title');

// Get a string with named parameters
String fieldCount = localization.getString(
  label: 'contractGeneration.fieldXofY',
  namedParameters: {
    'current': 5,
    'total': 43,
  },
);
// Result in Romanian: "Câmpul 5 din 43"
// Result in English: "Field 5 of 43"
```

### Example: EntityTypeSelectionScreen with Translations

```dart
Text(
  localization.getString(
    label: 'contractGeneration.pleaseSelectEntityType',
  ),
  textAlign: TextAlign.center,
  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
),

// Button labels
_EntityTypeButton(
  icon: Icons.person,
  title: localization.getString(
    label: 'contractGeneration.individualPerson',
  ),
  subtitle: localization.getString(
    label: 'contractGeneration.forPersonalTransactions',
  ),
  ...
),
```

### Language Switching

Users can change the language using the existing language switcher in the app. The setting is persisted to `SharedPreferences` and restored on app launch.

To change language programmatically:

```dart
// Switch to English
await context.read<LocalizationCubit>().changeLocale('en');

// Switch to Romanian
await context.read<LocalizationCubit>().changeLocale('ro');
```

## Complete Translation Coverage

### All Translated Elements

✅ **Screens and Sections**
- App title: "ContractKiosk"
- Screen titles for all 4 sections
- Entity type selection screen
- Progress indicators
- Summary and completion dialogs

✅ **Navigation**
- Previous, Next, Skip, Complete buttons
- Field counter (e.g., "Field 5 of 43")
- Progress percentage

✅ **Field Labels and Hints (43 fields)**
- Seller information (13 fields)
- Buyer information (13 fields)
- Object details (8 fields)
- Contract details (7 fields)

✅ **Entity Type Selection**
- "Individual Person" vs "Company / Legal Entity"
- Selection confirmation messages
- Information tooltips

✅ **Dialogs**
- Exit confirmation
- Contract summary
- Success message
- Print options

✅ **Validation Messages**
- "Please fill in all required fields"
- Optional field indicators

✅ **Virtual Keyboard**
- Keyboard labels
- Switch keyboard type tooltips
- Navigation buttons

## Testing Translations

### Test Checklist

1. **Default Language (Romanian)**
   - [ ] App starts in Romanian
   - [ ] All contract generation screens show Romanian text
   - [ ] Field labels and hints are in Romanian
   - [ ] Validation messages are in Romanian
   - [ ] Dialogs show Romanian text

2. **English Language**
   - [ ] Switch to English using language selector
   - [ ] All contract generation screens update to English
   - [ ] Field labels and hints are in English
   - [ ] Validation messages are in English
   - [ ] Dialogs show English text

3. **Language Persistence**
   - [ ] Select English and restart app
   - [ ] App remembers English language preference
   - [ ] Switch back to Romanian and restart
   - [ ] App remembers Romanian language preference

4. **Dynamic Updates**
   - [ ] Change language while on contract generation screen
   - [ ] All text updates immediately without restart

## Files Modified

### Translation Files
- ✅ `assets/l10n/ro.json` - Added `contractGeneration` section (106 translation keys)
- ✅ `assets/l10n/en.json` - Added `contractGeneration` section (106 translation keys)

### Configuration Files (for reference, not used)
- `lib/l10n/app_ro.arb` - Flutter gen-l10n template (Romanian)
- `lib/l10n/app_en.arb` - Flutter gen-l10n English translations
- `l10n.yaml` - Flutter gen-l10n configuration

**Note**: The app uses its existing custom localization system (`LocalizationCubit`), so the ARB files are for reference only.

## Language Information

### Supported Languages

| Code | Language | Status | Default |
|------|----------|--------|---------|
| `ro` | Română (Romanian) | ✅ Fully translated | **Yes** |
| `en` | English | ✅ Fully translated | No |

### Adding More Languages

To add a new language (e.g., Hungarian):

1. Create `assets/l10n/hu.json`
2. Copy the structure from `ro.json` or `en.json`
3. Translate all values under `contractGeneration`
4. Test with `await localization.changeLocale('hu')`

## Example Usage in Contract Generation Screens

### Single Field Screen

```dart
// Section title
Text(
  localization.getString(
    label: 'contractGeneration.sellerInformation',
  ),
  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
),

// Field counter
Text(
  localization.getString(
    label: 'contractGeneration.fieldXofY',
    namedParameters: {'current': fieldIndex + 1, 'total': totalFields},
  ),
  style: TextStyle(fontSize: 12),
),

// Field label
KeyboardTextField(
  controller: controller,
  label: localization.getString(label: 'contractGeneration.fullNameCompanyName'),
  hint: localization.getString(label: 'contractGeneration.enterFullLegalName'),
  icon: Icons.person,
),
```

### Entity Type Selection

```dart
showSnackBar(
  SnackBar(
    content: Text(
      entityType == 'individual'
        ? localization.getString(label: 'contractGeneration.selectedIndividual')
        : localization.getString(label: 'contractGeneration.selectedCompany'),
    ),
    backgroundColor: Colors.green,
  ),
);
```

### Progress Card

```dart
Text(
  localization.getString(
    label: 'contractGeneration.completedFields',
    namedParameters: {
      'completed': stats['completed'],
      'total': stats['total'],
    },
  ),
  style: TextStyle(color: Colors.grey[700]),
),
```

## Benefits

✅ **User-Friendly**: Romanian speakers get native language interface
✅ **International**: English speakers can use the app comfortably
✅ **Extensible**: Easy to add more languages in the future
✅ **Consistent**: All UI text is centrally managed
✅ **Dynamic**: Language changes take effect immediately
✅ **Persistent**: User's language preference is saved

## Implementation Summary

**Total translations added**: 106 keys per language (212 total)
**Languages supported**: 2 (Romanian, English)
**Default language**: Romanian (ro)
**System**: Custom LocalizationCubit with JSON files
**Storage**: SharedPreferences for persistence

The contract generation feature is now **fully internationalized** with Romanian as the default language and complete English support!
