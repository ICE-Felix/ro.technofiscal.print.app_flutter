# Session Timeout & Idle Management Feature

## Overview

This feature implements **automatic session timeout** for the kiosk application, ensuring that inactive sessions are reset after 60 seconds to maintain security and privacy in public environments.

## Components

### 1. Session Timeout Service (`lib/core/services/session_timeout_service.dart`)

Core service for managing session timeouts and idle detection:

#### **SessionTimeoutService Class**
- **startTimer()** - Start monitoring user activity
- **resetTimer()** - Reset on user interaction (tap, scroll, type, etc.)
- **stopTimer()** - Stop monitoring
- **getTimeSinceLastActivity()** - Check idle duration
- **getRemainingTime()** - Get countdown to timeout
- **setTimeoutDuration()** - Configure timeout length
- **dispose()** - Clean up resources

Configuration:
```dart
static const Duration defaultTimeout = Duration(seconds: 60);
static const Duration warningThreshold = Duration(seconds: 10);
```

#### **SessionTimeoutWrapper Widget**
Detects all user interactions:
- Taps and gestures
- Scrolling and panning
- Pointer movements
- Keyboard input
- Touch events

Automatically resets timer on any activity.

#### **TimeoutWarningDialog Widget**
Visual countdown dialog shown 10 seconds before timeout:
- Large countdown timer
- "Continue session" button
- Auto-closes and triggers timeout if no action

### 2. Kiosk Session Wrapper (`lib/core/widgets/kiosk_session_wrapper.dart`)

High-level wrapper that combines timeout with data clearing:

```dart
KioskSessionWrapper(
  timeout: Duration(seconds: 60),
  clearDataOnTimeout: true,
  dataKeysToClear: ['contract_data', 'current_field'],
  child: YourKioskPage(),
)
```

Features:
- **Automatic timeout after 60 seconds** of inactivity
- **Warning dialog at 50 seconds** (10 seconds before timeout)
- **Auto-clear contract data** on timeout
- **Navigate to home** page automatically
- **User feedback** with SnackBar notification

### 3. Integration (Single Field Flow Page)

Updated contract generation flow to include session management:
- Wraps entire flow with `KioskSessionWrapper`
- Monitors all user interactions during form filling
- Shows warning dialog when idle
- Clears data and returns to home on timeout

## User Flow

### Normal Session

```
User taps screen
    ↓
Timer resets (60s countdown starts)
    ↓
User fills fields
    ↓
Each interaction resets timer
    ↓
User completes contract
    ↓
Session ends normally
```

### Idle Session

```
User stops interacting
    ↓
Timer counts down from 60s
    ↓
At 50 seconds (10s warning):
    ┌─────────────────────────────┐
    │  ⚠️ Sesiune inactivă       │
    │                             │
    │  Sesiunea va expira în:     │
    │         10 seconds          │
    │                             │
    │  [Continuă sesiunea]        │
    └─────────────────────────────┘
    ↓
User clicks "Continuă" → Timer resets
OR
No action for 10 more seconds
    ↓
Session timeout triggered:
  1. Clear contract data
  2. Show notification
  3. Navigate to home page
```

## Visual Design

### Warning Dialog (at 50s)

```
┌───────────────────────────────────┐
│ ⚠️  Sesiune inactivă              │
├───────────────────────────────────┤
│                                   │
│ Sesiunea dumneavoastră va expira  │
│ în:                               │
│                                   │
│        ┌──────────────┐          │
│        │      10      │          │ ← Large countdown
│        └──────────────┘          │
│          secunde                  │
│                                   │
│ Apăsați "Continuă" pentru a       │
│ păstra sesiunea activă.           │
│                                   │
│  ┌──────────────────────────┐   │
│  │ 👆 Continuă sesiunea     │   │ ← Full-width button
│  └──────────────────────────┘   │
│                                   │
└───────────────────────────────────┘
```

### Timeout Notification

```
┌─────────────────────────────────────┐
│ Sesiune expirată din cauza         │
│ inactivității. Reveniți la          │
│ pagina principală.                  │
└─────────────────────────────────────┘
     Orange SnackBar (3 seconds)
```

## Configuration

### Timeout Duration

Adjust in `KioskSessionWrapper`:
```dart
KioskSessionWrapper(
  timeout: Duration(seconds: 60),  // Change to desired duration
  ...
)
```

### Warning Threshold

Adjust in `SessionTimeoutService`:
```dart
static const Duration warningThreshold = Duration(seconds: 10);
```

### Data to Clear

Configure which keys to clear on timeout:
```dart
KioskSessionWrapper(
  dataKeysToClear: [
    'contract_data',
    'current_field',
    'user_preferences',  // Add more as needed
  ],
  ...
)
```

### Disable Data Clearing

```dart
KioskSessionWrapper(
  clearDataOnTimeout: false,  // Keep data after timeout
  ...
)
```

## Usage Examples

### Basic Implementation

```dart
class MyKioskPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return KioskSessionWrapper(
      timeout: Duration(seconds: 60),
      child: Scaffold(
        body: YourContent(),
      ),
    );
  }
}
```

### Custom Timeout

```dart
KioskSessionWrapper(
  timeout: Duration(minutes: 2),  // 2 minute timeout
  clearDataOnTimeout: true,
  dataKeysToClear: ['form_data'],
  child: MyFormPage(),
)
```

### Manual Activity Detection

```dart
final service = SessionTimeoutService(
  timeout: Duration(seconds: 60),
  onTimeout: () {
    print('Session expired!');
  },
  onWarning: () {
    print('Warning: 10 seconds left!');
  },
);

service.startTimer();

// Reset on custom events
onUserAction() {
  service.resetTimer();
}

// Check status
final remaining = service.getRemainingTime();
final isIdle = service.isIdle;

// Clean up
service.dispose();
```

## Features

### ✅ Implemented

- **60-second idle timeout** (configurable)
- **10-second warning dialog** with countdown
- **All user interactions detected**:
  - Taps and clicks
  - Scrolling
  - Gestures
  - Keyboard input
  - Pointer movements
- **Automatic data clearing** on timeout
- **Navigation to home** page
- **User notifications** (SnackBar)
- **"Continue session" button** in warning
- **Countdown timer** in warning dialog
- **Auto-dismissing warning** if no action
- **Configurable timeouts**
- **Configurable data keys** to clear
- **Enable/disable data clearing**

### 🎨 Design Highlights

- **Large countdown display** (48px font)
- **Orange warning color** scheme
- **Full-width action button** for easy tapping
- **Clear messaging** in Romanian
- **Non-dismissible warning** (must click button)
- **Visual feedback** with icons

## Security & Privacy

### Data Protection

On timeout, automatically clears:
- ✅ Contract form data
- ✅ Current field position
- ✅ Any custom data keys specified

### Privacy Compliance

- ✅ **No data retention** after idle timeout
- ✅ **Automatic session reset** for next user
- ✅ **Clear visual warnings** before timeout
- ✅ **User control** with "Continue" button

## Performance

- **Minimal CPU usage** (timer-based, not polling)
- **Efficient event detection** (native Flutter gesture detection)
- **No impact on app responsiveness**
- **Clean resource disposal**

## Testing

### Test Idle Detection

1. **Run app**: `flutter run`
2. **Navigate to**: Contract Generation
3. **Stop interacting** with screen
4. **Wait 50 seconds**
5. **Verify**: Warning dialog appears
6. **Wait 10 more seconds**
7. **Verify**:
   - Data cleared
   - Notification shown
   - Navigated to home

### Test Continue Button

1. **Trigger warning** (wait 50s)
2. **Click "Continuă sesiunea"**
3. **Verify**:
   - Dialog closes
   - Timer resets to 60s
   - Can continue working

### Test Activity Detection

1. **Start contract** generation
2. **Interact periodically**:
   - Tap fields
   - Scroll
   - Type text
3. **Verify**: No timeout occurs

## Integration Points

### Current Implementation

Only the **Contract Generation Flow** currently has session timeout:

```dart
// lib/features/contract_generation/presentation/pages/single_field_flow_page.dart
return KioskSessionWrapper(
  timeout: const Duration(seconds: 60),
  clearDataOnTimeout: true,
  dataKeysToClear: const ['contract_data', 'current_field'],
  child: PopScope(...),
);
```

### Future Integration

Add to other kiosk pages:
- Home page (for inactivity on main screen)
- Document printing page
- Payment pages

## Troubleshooting

### Timer Not Resetting

**Issue**: Timeout occurs even with user activity

**Solutions**:
- Check if page is wrapped with `SessionTimeoutWrapper` or `KioskSessionWrapper`
- Verify gesture detection isn't blocked by other widgets
- Ensure `enabled: true` on wrapper

### Warning Dialog Not Appearing

**Issue**: Session times out without warning

**Solutions**:
- Check `warningThreshold` setting (must be < timeout duration)
- Verify dialog context is valid
- Check for navigation blocking dialog

### Data Not Clearing

**Issue**: Data persists after timeout

**Solutions**:
- Verify `clearDataOnTimeout: true`
- Check `dataKeysToClear` includes correct keys
- Ensure SharedPreferences permissions

## File Structure

```
lib/
├── core/
│   ├── services/
│   │   └── session_timeout_service.dart       # Core timeout logic
│   └── widgets/
│       └── kiosk_session_wrapper.dart         # High-level wrapper
└── features/
    └── contract_generation/
        ├── presentation/
        │   └── pages/
        │       └── single_field_flow_page.dart # Updated with timeout
        └── SESSION_TIMEOUT_README.md           # This file
```

## Dependencies

No external dependencies required. Uses built-in Flutter:
- `dart:async` (Timer)
- `package:flutter/material.dart` (Widgets)
- `package:shared_preferences` (Data clearing)
- `package:go_router` (Navigation)

## Next Steps

Future enhancements:

- [ ] **Configurable timeout** in app settings
- [ ] **Admin override** to disable timeout
- [ ] **Activity logging** for analytics
- [ ] **Different timeouts** for different pages
- [ ] **Sound/vibration** warning
- [ ] **Multi-language** warning dialog
- [ ] **Session extension** option (add 5 more minutes)
- [ ] **Analytics integration** (track timeout frequency)

## Compliance

Matches requirement from Home Page:
```dart
// lib/features/home/presentation/pages/home_page.dart:259
Text(
  'Sesiunea se va închide automat după 60 secunde de inactivitate',
  ...
)
```

✅ **Now fully implemented!**

---

**Status**: ✅ Complete and production-ready
**Version**: 1.0
**Last Updated**: January 2025
