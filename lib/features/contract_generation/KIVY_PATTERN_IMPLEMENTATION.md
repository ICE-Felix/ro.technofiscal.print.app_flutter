# Implementing Kivy's One-Field-Per-Screen Pattern in Flutter

## Overview

This document explains how to implement the **exact same pattern** used in the Kivy Python project (`/project/main.py`) in our Flutter application.

---

## Kivy Pattern Analysis

### Key Characteristics:

1. **ONE field per screen** (80+ screens total)
2. **Linear navigation** with Previous/Next buttons
3. **Persistent virtual keyboard** at bottom
4. **Immediate validation** on Next button press
5. **JSON data persistence** after each field
6. **Screen registry** defines the entire flow
7. **Cancellation** returns to main menu

### Kivy Screen Structure:

```
┌──────────────────────────────────────┐
│ [CANCEL BUTTON]         [TITLE]      │ ← Top section
├──────────────────────────────────────┤
│                                      │
│         INSTRUCTIONS                 │ ← Middle section (instructions)
│    "Enter your full name"            │
│                                      │
│    ┌────────────────────────────┐   │
│    │ [Single Input Field]       │   │ ← Single input field
│    └────────────────────────────┘   │
│                                      │
│  [← Previous]     [Next →]          │ ← Navigation buttons
│                                      │
├──────────────────────────────────────┤
│  Q  W  E  R  T  Y  U  I  O  P      │
│   A  S  D  F  G  H  J  K  L        │ ← Virtual keyboard (always visible)
│    Z  X  C  V  B  N  M             │
│         [SPACE]                     │
└──────────────────────────────────────┘
```

---

## Flutter Implementation Strategy

### Approach 1: Multi-Page Route System (Recommended)

Create individual route for each field, similar to Kivy's screen-per-field.

#### File Structure:
```
lib/features/contract_generation/
├── presentation/
│   ├── pages/
│   │   ├── contract_generation_flow.dart      # Entry point
│   │   ├── fields/
│   │   │   ├── seller_name_page.dart
│   │   │   ├── seller_cnp_page.dart
│   │   │   ├── seller_country_page.dart
│   │   │   ├── seller_county_page.dart
│   │   │   ├── ... (17 seller fields)
│   │   │   ├── buyer_name_page.dart
│   │   │   ├── ... (17 buyer fields)
│   │   │   └── contract_price_page.dart
│   │   └── summary_page.dart
│   └── widgets/
│       ├── single_field_screen.dart           # Reusable template
│       ├── virtual_keyboard_wrapper.dart      # Already created
│       └── field_navigation_controller.dart   # Already created
└── data/
    └── contract_data_manager.dart             # Like Kivy's DataManager
```

---

## Implementation Example

### 1. Screen Registry (Kivy equivalent)

**File**: `lib/features/contract_generation/data/field_registry.dart`

```dart
/// Defines the complete field-by-field flow (like Kivy's screen_registry.py)
class FieldRegistry {
  static const List<FieldDefinition> sellerFields = [
    FieldDefinition(
      id: 'seller_name',
      title: 'COMPLETARE CONTRACT VANZARE AUTO',
      instruction: 'COMPLETATI\nNUMELE SI PRENUMELE PERSOANEI CARE INSTRAINEAZA\n(VANZATOR)',
      hint: 'ex: POPESCU ION',
      fieldType: FieldType.text,
      isRequired: true,
      nextField: 'seller_country',
      previousField: 'contract_menu',
    ),
    FieldDefinition(
      id: 'seller_country',
      title: 'COMPLETARE CONTRACT VANZARE AUTO',
      instruction: 'COMPLETATI\nTARA DE DOMICILIU',
      hint: 'ex: ROMANIA',
      fieldType: FieldType.text,
      isRequired: true,
      nextField: 'seller_county',
      previousField: 'seller_name',
    ),
    FieldDefinition(
      id: 'seller_county',
      title: 'COMPLETARE CONTRACT VANZARE AUTO',
      instruction: 'COMPLETATI\nJUDETUL',
      hint: 'ex: BUCURESTI',
      fieldType: FieldType.text,
      isRequired: true,
      nextField: 'seller_postal_code',
      previousField: 'seller_country',
    ),
    // ... define all 17 seller fields
    FieldDefinition(
      id: 'seller_cnp',
      instruction: 'COMPLETATI\nCODUL NUMERIC PERSONAL (CNP)',
      hint: '13 cifre',
      fieldType: FieldType.numeric,
      isRequired: true,
      validator: Validators.validateCNP,
      nextField: 'seller_phone',
      previousField: 'seller_id_number',
    ),
  ];

  static const List<FieldDefinition> buyerFields = [
    // ... define all 17 buyer fields (same pattern)
  ];

  static const List<FieldDefinition> contractFields = [
    // ... define all 16 contract fields
  ];

  /// Get all fields in order
  static List<FieldDefinition> getAllFields() {
    return [
      ...sellerFields,
      ...buyerFields,
      ...contractFields,
    ];
  }

  /// Get field by ID
  static FieldDefinition? getField(String id) {
    return getAllFields().firstWhere((f) => f.id == id);
  }
}

class FieldDefinition {
  final String id;
  final String title;
  final String instruction;
  final String hint;
  final FieldType fieldType;
  final bool isRequired;
  final String? nextField;
  final String? previousField;
  final String? Function(String)? validator;

  const FieldDefinition({
    required this.id,
    required this.title,
    required this.instruction,
    required this.hint,
    required this.fieldType,
    this.isRequired = true,
    this.nextField,
    this.previousField,
    this.validator,
  });
}

enum FieldType {
  text,        // Full keyboard
  numeric,     // Numeric keyboard
  email,       // Email keyboard
}
```

---

### 2. Data Manager (Kivy's DataManager equivalent)

**File**: `lib/features/contract_generation/data/contract_data_manager.dart`

```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages contract data persistence (like Kivy's DataManager)
class ContractDataManager {
  static const String _sellerDataKey = 'seller_data';
  static const String _buyerDataKey = 'buyer_data';
  static const String _contractDataKey = 'contract_data';

  /// Save a single field value
  static Future<void> saveField(
    String category,
    String fieldId,
    String value
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Load existing data
    final data = await loadData(category);

    // Update field
    data[fieldId] = value;

    // Save back
    await prefs.setString(
      _getKey(category),
      jsonEncode(data),
    );
  }

  /// Load all data for a category
  static Future<Map<String, dynamic>> loadData(String category) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_getKey(category));

    if (jsonString == null) return {};

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  /// Get a specific field value
  static Future<String> getField(
    String category,
    String fieldId,
    {String defaultValue = ''}
  ) async {
    final data = await loadData(category);
    return data[fieldId] ?? defaultValue;
  }

  /// Clear all data (on cancel or completion)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sellerDataKey);
    await prefs.remove(_buyerDataKey);
    await prefs.remove(_contractDataKey);
  }

  static String _getKey(String category) {
    switch (category) {
      case 'seller':
        return _sellerDataKey;
      case 'buyer':
        return _buyerDataKey;
      case 'contract':
        return _contractDataKey;
      default:
        throw ArgumentError('Unknown category: $category');
    }
  }
}
```

---

### 3. Single Field Screen Template (Reusable Widget)

**File**: `lib/features/contract_generation/presentation/widgets/single_field_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../data/field_registry.dart';
import '../data/contract_data_manager.dart';
import 'virtual_keyboard_wrapper.dart';
import 'keyboard_text_field.dart';

/// Reusable template for single-field screens (like Kivy's BaseScreen)
class SingleFieldScreen extends StatefulWidget {
  final FieldDefinition field;
  final String category; // 'seller', 'buyer', or 'contract'

  const SingleFieldScreen({
    super.key,
    required this.field,
    required this.category,
  });

  @override
  State<SingleFieldScreen> createState() => _SingleFieldScreenState();
}

class _SingleFieldScreenState extends State<SingleFieldScreen> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _loadSavedValue();
  }

  Future<void> _loadSavedValue() async {
    // Load previously saved value (like Kivy loads from JSON)
    final savedValue = await ContractDataManager.getField(
      widget.category,
      widget.field.id,
    );

    setState(() {
      _controller.text = savedValue;
      _isLoading = false;
    });

    // Auto-focus field and show keyboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handlePrevious() async {
    if (widget.field.previousField != null) {
      // Save current value before navigating
      await ContractDataManager.saveField(
        widget.category,
        widget.field.id,
        _controller.text.trim(),
      );

      // Navigate to previous field
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _handleNext() async {
    final value = _controller.text.trim();

    // Validate required field
    if (widget.field.isRequired && value.isEmpty) {
      _showError('Acest câmp este obligatoriu');
      return;
    }

    // Validate format if validator exists
    if (widget.field.validator != null) {
      final error = widget.field.validator!(value);
      if (error != null) {
        _showError(error);
        return;
      }
    }

    // Save value to storage
    await ContractDataManager.saveField(
      widget.category,
      widget.field.id,
      value,
    );

    // Navigate to next field
    if (widget.field.nextField != null) {
      final nextFieldDef = FieldRegistry.getField(widget.field.nextField!);
      if (nextFieldDef != null && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SingleFieldScreen(
              field: nextFieldDef,
              category: _getCategoryForField(nextFieldDef.id),
            ),
          ),
        );
      }
    } else {
      // Last field - go to summary
      if (mounted) {
        Navigator.of(context).pushNamed('/contract-summary');
      }
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eroare'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getCategoryForField(String fieldId) {
    if (fieldId.startsWith('seller')) return 'seller';
    if (fieldId.startsWith('buyer')) return 'buyer';
    return 'contract';
  }

  Future<void> _handleCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renunță la completarea formularului?'),
        content: const Text('Toate datele introduse vor fi șterse.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('NU'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('DA'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ContractDataManager.clearAll();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.lightBlue[100], // Like Kivy's background
      body: VirtualKeyboardWrapper(
        child: SafeArea(
          child: Column(
            children: [
              // TOP SECTION: Cancel button and title
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cancel button (like Kivy's RENUNTA button)
                    SizedBox(
                      width: 300,
                      child: OutlinedButton(
                        onPressed: _handleCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'RENUNTA LA COMPLETAREA FORMULARULUI',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    // Title
                    Expanded(
                      child: Text(
                        widget.field.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // MIDDLE SECTION: Instructions and input field
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Instructions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        widget.field.instruction,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Single input field (centered, large)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 100),
                      child: KeyboardTextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        label: '',
                        hint: widget.field.hint,
                        icon: _getIcon(widget.field.fieldType),
                        keyboardType: _getKeyboardType(widget.field.fieldType),
                        autofocus: true,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Navigation buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 100),
                      child: Row(
                        children: [
                          // Previous button
                          if (widget.field.previousField != null)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _handlePrevious,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.arrow_back),
                                    SizedBox(width: 8),
                                    Text('Pasul anterior'),
                                  ],
                                ),
                              ),
                            ),
                          if (widget.field.previousField != null)
                            const SizedBox(width: 16),

                          // Next button
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _handleNext,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.white,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Pasul urmator'),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(FieldType type) {
    switch (type) {
      case FieldType.text:
        return Icons.text_fields;
      case FieldType.numeric:
        return Icons.numbers;
      case FieldType.email:
        return Icons.email;
    }
  }

  TextInputType _getKeyboardType(FieldType type) {
    switch (type) {
      case FieldType.text:
        return TextInputType.text;
      case FieldType.numeric:
        return TextInputType.number;
      case FieldType.email:
        return TextInputType.emailAddress;
    }
  }
}
```

---

### 4. Usage Example

**File**: `lib/features/contract_generation/presentation/pages/contract_generation_flow.dart`

```dart
import 'package:flutter/material.dart';
import '../data/field_registry.dart';
import '../widgets/single_field_screen.dart';

class ContractGenerationFlow extends StatelessWidget {
  const ContractGenerationFlow({super.key});

  @override
  Widget build(BuildContext context) {
    // Start with first field (seller name)
    final firstField = FieldRegistry.sellerFields.first;

    return SingleFieldScreen(
      field: firstField,
      category: 'seller',
    );
  }
}
```

---

## Comparison: Kivy vs Flutter Implementation

| Aspect | Kivy Python | Flutter Implementation |
|--------|-------------|----------------------|
| **Screens** | 80+ individual Python files | 1 reusable SingleFieldScreen widget |
| **Registry** | screen_registry.py with class paths | field_registry.dart with FieldDefinitions |
| **Navigation** | ScreenManager.current = "next_screen" | Navigator.push(SingleFieldScreen) |
| **Data** | JSON files (seller_data.json) | SharedPreferences |
| **Validation** | BaseScreen.validate_required_field() | Built into SingleFieldScreen |
| **Keyboard** | VirtualKeyboard widget | VirtualKeyboardWrapper (package) |
| **Cleanup** | on_stop() deletes JSON files | ContractDataManager.clearAll() |

---

## Benefits of This Pattern

### ✅ Advantages:
1. **Simple user experience** - One field at a time, no confusion
2. **Large touch targets** - Perfect for kiosk/touchscreen use
3. **Progressive saving** - Data saved after each field
4. **Easy to maintain** - Single template for all fields
5. **Flexible flow** - Easy to add/remove/reorder fields
6. **Graceful cancellation** - Can abort at any point
7. **Resume capability** - Can continue from where user left off

### ⚠️ Considerations:
1. **Many navigation steps** - 50+ steps for complete contract
2. **Screen transitions** - May feel slow compared to scrolling
3. **No overview** - User can't see all fields at once
4. **Back button behavior** - Need to handle Android back button

---

## Implementation Checklist

To implement this pattern in your Flutter app:

- [ ] Create `field_registry.dart` with all field definitions
- [ ] Create `contract_data_manager.dart` for data persistence
- [ ] Create `single_field_screen.dart` reusable template
- [ ] Define all 50+ fields in registry (seller, buyer, contract)
- [ ] Add validators for special fields (CNP, VIN, email, etc.)
- [ ] Update routes to use new flow
- [ ] Add cancel confirmation dialog
- [ ] Implement data cleanup on cancel/completion
- [ ] Test navigation flow end-to-end
- [ ] Add summary page showing all collected data

---

## Migration Strategy

### Option A: Replace Existing Implementation
Replace the current multi-field wizard with the single-field pattern.

**Pros**: Matches Kivy exactly, simpler UX
**Cons**: More navigation steps

### Option B: Hybrid Approach
Use single-field pattern for complex fields, keep multi-field for simple sections.

**Pros**: Best of both worlds
**Cons**: Inconsistent UX

### Option C: Both Options Available
Let user choose between "Quick Mode" (multi-field) and "Step-by-Step Mode" (single-field).

**Pros**: Flexibility
**Cons**: More code to maintain

---

## Next Steps

1. **Test the pattern** - Implement 3-5 fields as proof of concept
2. **Get user feedback** - Is one-field-at-a-time better for your kiosk?
3. **Performance test** - Measure navigation speed with 50+ fields
4. **Decide on migration** - Choose Option A, B, or C above
5. **Full implementation** - Define all fields in registry
6. **Integration** - Connect to existing contract generation BLoC

---

This pattern provides the exact same user experience as your Kivy Python application, adapted to Flutter's architecture!
