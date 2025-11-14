# Field-by-Field Navigation Implementation Guide

This document explains how to implement one-field-at-a-time input navigation with the virtual keyboard in the contract generation feature.

## Architecture Overview

The field-by-field navigation system consists of three main components:

### 1. **FieldNavigationController**
Manages the focus state and navigation between fields.

**Location:** `presentation/widgets/field_navigation_controller.dart`

**Key Methods:**
- `registerField(FocusNode, TextEditingController)` - Register a field for navigation
- `focusFirstField()` - Auto-focus the first field
- `nextField()` - Move to next field
- `previousField()` - Move to previous field
- `focusField(int index)` - Focus specific field by index

### 2. **VirtualKeyboardWrapper**
Wraps the form content and displays the virtual keyboard with navigation buttons.

**Location:** `presentation/widgets/virtual_keyboard_wrapper.dart`

**Features:**
- Shows/hides virtual keyboard
- Displays Previous/Next navigation buttons
- Switches between Numeric/Alphanumeric keyboards
- Integrates with FieldNavigationController

### 3. **KeyboardTextField**
Enhanced TextField that automatically shows keyboard on tap and supports FocusNode.

**Location:** `presentation/widgets/keyboard_text_field.dart`

**Key Properties:**
- `focusNode` - For programmatic focus management
- `autofocus` - Auto-focus on widget load
- Automatic keyboard type detection (numeric vs alphanumeric)

## Implementation Steps

### Step 1: Create FieldNavigationController

```dart
class _YourFormState extends State<YourForm> {
  late FieldNavigationController _navigationController;

  @override
  void initState() {
    super.initState();
    _navigationController = FieldNavigationController();
  }

  @override
  void dispose() {
    _navigationController.dispose();
    super.dispose();
  }
}
```

### Step 2: Create FocusNodes and Controllers for Each Field

```dart
// Text controllers
late TextEditingController _nameController;
late TextEditingController _emailController;
late TextEditingController _phoneController;

// Focus nodes
late FocusNode _nameFocus;
late FocusNode _emailFocus;
late FocusNode _phoneFocus;

@override
void initState() {
  super.initState();

  // Initialize controllers
  _nameController = TextEditingController();
  _emailController = TextEditingController();
  _phoneController = TextEditingController();

  // Initialize focus nodes
  _nameFocus = FocusNode();
  _emailFocus = FocusNode();
  _phoneFocus = FocusNode();

  // Register fields with navigation controller
  _navigationController.registerField(_nameFocus, _nameController);
  _navigationController.registerField(_emailFocus, _emailController);
  _navigationController.registerField(_phoneFocus, _phoneController);

  // Auto-focus first field after frame renders
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _navigationController.focusFirstField();
  });
}

@override
void dispose() {
  // Dispose controllers
  _nameController.dispose();
  _emailController.dispose();
  _phoneController.dispose();

  // Dispose focus nodes
  _nameFocus.dispose();
  _emailFocus.dispose();
  _phoneFocus.dispose();

  super.dispose();
}
```

### Step 3: Wrap Your Form with VirtualKeyboardWrapper

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: VirtualKeyboardWrapper(
      navigationController: _navigationController,  // Pass controller
      child: Column(
        children: [
          // Your form fields here
        ],
      ),
    ),
  );
}
```

### Step 4: Use KeyboardTextField with FocusNodes

```dart
KeyboardTextField(
  controller: _nameController,
  focusNode: _nameFocus,
  label: 'Full Name *',
  hint: 'Enter your name',
  icon: Icons.person,
  autofocus: true,  // First field auto-focuses
),

KeyboardTextField(
  controller: _emailController,
  focusNode: _emailFocus,
  label: 'Email *',
  hint: 'your@email.com',
  icon: Icons.email,
  keyboardType: TextInputType.emailAddress,  // Will show alphanumeric keyboard
),

KeyboardTextField(
  controller: _phoneController,
  focusNode: _phoneFocus,
  label: 'Phone *',
  hint: '+40 7xx xxx xxx',
  icon: Icons.phone,
  keyboardType: TextInputType.phone,  // Will show numeric keyboard
),
```

## User Flow

1. **Page Loads** → First field automatically gets focus → Keyboard appears
2. **User types** → Virtual keyboard inputs text
3. **User taps "Next" button** (or presses Return on keyboard) → Next field gets focus
4. **User taps "Previous" button** → Previous field gets focus
5. **Last field** → "Next" button changes to "Done" → Hides keyboard when pressed

## Navigation Buttons Behavior

### Previous Button
- **Disabled** on first field
- **Enabled** on all other fields
- Moves focus to previous field

### Next/Done Button
- Shows **"Next"** with arrow icon on all fields except last
- Shows **"Done"** with checkmark icon on last field
- **Next**: Moves focus to next field
- **Done**: Hides keyboard

### Keyboard Type Toggle
- Switches between Alphanumeric ↔ Numeric
- Useful when user needs different keyboard than auto-detected

### Close Button
- Always available
- Immediately hides keyboard
- Keeps current field focused

## Example: Complete Implementation

See `party_form_step_with_navigation.dart` for a complete working example showing:
- 12 fields with full navigation
- Conditional fields (ID card only for individuals)
- Address section with multiple fields
- Auto-focus on first field
- Proper cleanup in dispose()

## Testing the Implementation

1. **Run the app** and navigate to contract generation
2. **First field should auto-focus** and keyboard should appear
3. **Type some text** using the virtual keyboard
4. **Press "Next"** → Second field should focus
5. **Press "Previous"** → First field should focus again
6. **Navigate to last field** → Button should show "Done"
7. **Press "Done"** → Keyboard should hide

## Tips & Best Practices

### Auto-focus First Field
Always use `addPostFrameCallback` to focus first field:
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  _navigationController.focusFirstField();
});
```

### Register Fields in Order
Register fields in the order you want users to navigate:
```dart
_navigationController.registerField(_field1Focus, _field1Controller);
_navigationController.registerField(_field2Focus, _field2Controller);
_navigationController.registerField(_field3Focus, _field3Controller);
```

### Conditional Fields
For fields that appear conditionally, register them when they become visible:
```dart
if (_selectedEntityType == EntityType.individual) {
  _navigationController.registerField(_idSeriesFocus, _idSeriesController);
  _navigationController.registerField(_idNumberFocus, _idNumberController);
}
```

### Keyboard Type Detection
The system automatically detects numeric fields:
- `TextInputType.number`
- `TextInputType.numberWithOptions(decimal: true)`
- `TextInputType.phone`

All other types show alphanumeric keyboard.

### Memory Management
Always dispose of resources:
```dart
@override
void dispose() {
  _navigationController.dispose();  // Disposes all focus nodes and controllers
  super.dispose();
}
```

## Troubleshooting

### Keyboard doesn't appear
- Ensure `VirtualKeyboardWrapper` wraps your form
- Check that `navigationController` is passed to wrapper

### Navigation doesn't work
- Verify all fields are registered with `registerField()`
- Check fields are registered in correct order
- Ensure `focusFirstField()` is called in `addPostFrameCallback`

### Wrong keyboard type shows
- Check `keyboardType` property on `KeyboardTextField`
- Use `TextInputType.number` for numeric fields
- Use `TextInputType.phone` for phone numbers

### Focus not moving between fields
- Verify `FocusNode` is passed to each `KeyboardTextField`
- Check `focusNode` parameter is not null
- Ensure focus nodes are initialized in `initState()`

## Architecture Diagram

```
┌─────────────────────────────────────────┐
│     ContractGenerationPage              │
│  ┌───────────────────────────────────┐  │
│  │  VirtualKeyboardWrapper           │  │
│  │  (with navigationController)      │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │  PartyFormStep              │  │  │
│  │  │  ┌───────────────────────┐  │  │  │
│  │  │  │ KeyboardTextField     │  │  │  │
│  │  │  │ (with focusNode)      │  │  │  │
│  │  │  └───────────────────────┘  │  │  │
│  │  │  ┌───────────────────────┐  │  │  │
│  │  │  │ KeyboardTextField     │  │  │  │
│  │  │  │ (with focusNode)      │  │  │  │
│  │  │  └───────────────────────┘  │  │  │
│  │  │         ...                  │  │  │
│  │  └─────────────────────────────┘  │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │  Virtual Keyboard           │  │  │
│  │  │  [Prev] [Next] [123] [Hide] │  │  │
│  │  │  ┌─────┬─────┬─────┬─────┐  │  │  │
│  │  │  │  Q  │  W  │  E  │  R  │  │  │  │
│  │  │  └─────┴─────┴─────┴─────┘  │  │  │
│  │  └─────────────────────────────┘  │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
           ↕
  FieldNavigationController
  • Manages focus state
  • Navigates between fields
  • Tracks current field index
```

## Future Enhancements

Potential improvements to consider:

1. **Field Validation** - Show errors before allowing Next
2. **Skip Empty Fields** - Option to skip optional fields
3. **Field Progress Indicator** - Show "Field 3 of 12"
4. **Swipe Gestures** - Swipe left/right to navigate
5. **Voice Input** - Add voice-to-text option
6. **Field Grouping** - Group related fields together
7. **Smart Navigation** - Skip to first empty field
8. **Keyboard Shortcuts** - Ctrl+Arrow for desktop users
