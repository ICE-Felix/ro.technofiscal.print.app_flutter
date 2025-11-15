# Kiosk Mode Lockdown Feature

## Overview

This feature implements **kiosk mode lockdown** for public deployment, preventing users from exiting the app or accessing device settings. Essential for unattended kiosk operation in public spaces.

## Components

### 1. Kiosk Mode Service (`lib/core/services/kiosk_mode_service.dart`)

Core service managing kiosk mode features:

#### **KioskModeService Class**

Static methods for kiosk control:

```dart
// Enable kiosk mode
await KioskModeService.enable();

// Disable kiosk mode
await KioskModeService.disable();

// Toggle on/off
await KioskModeService.toggle();

// Refresh immersive mode
await KioskModeService.refreshImmersiveMode();

// Check status
bool enabled = KioskModeService.isEnabled;
```

#### **Features Enabled**

**Cross-Platform:**
- ✅ **Full-screen immersive mode** (hides status bar & navigation bar)
- ✅ **Screen always on** (prevents sleep during session)
- ✅ **Auto-restore UI** on app resume

**Android-Specific:**
- ✅ **Screenshot prevention** (FLAG_SECURE)
- ✅ **Screen-on lock** (FLAG_KEEP_SCREEN_ON)
- ✅ **Turn screen on** when app opens (FLAG_TURN_SCREEN_ON)
- ✅ **Show when locked** (FLAG_SHOW_WHEN_LOCKED)

**iOS:**
- ✅ **Full-screen mode** (immersive UI)
- ⚠️ **Guided Access** (user must enable manually in Settings)

### 2. Kiosk Mode Wrapper (`KioskModeWrapper`)

Automatic lifecycle management widget:

```dart
KioskModeWrapper(
  enableKioskMode: true,
  onKioskModeChanged: () {
    print('Kiosk mode status changed');
  },
  child: YourApp(),
)
```

Features:
- **Auto-enable** on widget build
- **Auto-disable** on widget dispose
- **Auto-restore** on app resume
- **Lifecycle observer** for app state changes

### 3. Debug Toggle (`KioskModeToggle`)

Developer panel for testing (debug builds only):

```dart
KioskModeToggle()
```

Shows:
- Current kiosk mode status
- Toggle switch
- Feature checklist:
  - Full-screen mode
  - Screen always on
  - Screenshots disabled (Android)
  - Secure mode (Android)

## Integration

### Main App Integration

```dart
// lib/main.dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ... other initialization

  // Enable kiosk mode for production
  if (kReleaseMode) {
    await KioskModeService.enable();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return KioskModeWrapper(
      enableKioskMode: kReleaseMode, // Only in production
      child: MaterialApp(...),
    );
  }
}
```

### Debug Access

Added to Home Page app bar (debug builds only):

```dart
// Shows fullscreen icon button
// Opens kiosk mode settings dialog
// Toggle kiosk mode on/off
// View feature status
```

## Platform-Specific Setup

### Android

**No additional setup required!**

The following flags are automatically applied:
- `FLAG_SECURE` - Prevents screenshots and screen recording
- `FLAG_KEEP_SCREEN_ON` - Keeps screen awake
- `FLAG_TURN_SCREEN_ON` - Turns on screen when app opens
- `FLAG_SHOW_WHEN_LOCKED` - Shows app over lock screen

### iOS

**Manual Guided Access:**

Users must enable Guided Access in iOS Settings:

1. Open **Settings** → **Accessibility** → **Guided Access**
2. Turn on **Guided Access**
3. Set a passcode
4. In your app, triple-click home button
5. Circle areas to disable (or disable all touch)
6. Tap **Start**

**Programmatic limitations:**
- iOS doesn't allow apps to programmatically lock device
- Full-screen mode works automatically
- Guided Access must be manually enabled

### Android Kiosk Mode (Advanced)

For **true kiosk mode** (lock to single app, disable home button):

**Option 1: Device Owner Mode**
```bash
# Requires factory reset and ADB setup
adb shell dpm set-device-owner com.yourapp/.DeviceAdminReceiver
```

**Option 2: MDM Solutions**
- Use enterprise MDM (Mobile Device Management)
- Examples: Google Workspace, Microsoft Intune
- Remotely lock devices to kiosk mode

**Option 3: Dedicated Kiosk Hardware**
- Purpose-built kiosk tablets
- Pre-configured with lockdown

## Features

### ✅ Implemented

**Full-Screen Experience:**
- ✅ Hide status bar
- ✅ Hide navigation bar
- ✅ Immersive sticky mode
- ✅ Auto-restore on app resume

**Security:**
- ✅ Prevent screenshots (Android)
- ✅ Secure mode (Android)
- ✅ Screen always on

**Developer Tools:**
- ✅ Debug toggle in app bar
- ✅ Visual status indicators
- ✅ Quick enable/disable
- ✅ Feature checklist

**Lifecycle Management:**
- ✅ Automatic enable/disable
- ✅ App lifecycle observation
- ✅ Restore immersive on resume

### ⚠️ Limitations

**iOS:**
- ❌ Cannot programmatically enable Guided Access
- ⚠️ Users must manually enable in Settings
- ✅ Full-screen mode works

**Android (Standard App):**
- ❌ Cannot disable home button (requires device owner)
- ❌ Cannot prevent task switching (requires device owner)
- ✅ Can hide navigation bar
- ✅ Can prevent screenshots

**To fully lock Android:**
- Requires Device Owner mode OR
- Requires MDM enrollment OR
- Requires dedicated kiosk hardware

## Usage Examples

### Basic Setup (Current Implementation)

```dart
// Automatic in production builds
// lib/main.dart handles it
// No code changes needed!
```

### Manual Control

```dart
// Enable manually
await KioskModeService.enable();

// Disable for testing
await KioskModeService.disable();

// Toggle
await KioskModeService.toggle();

// Check status
if (KioskModeService.isEnabled) {
  print('Kiosk mode active');
}
```

### Custom Implementation

```dart
class MyKioskPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return KioskModeWrapper(
      enableKioskMode: true,
      onKioskModeChanged: () {
        // Handle status change
        print('Kiosk mode changed: ${KioskModeService.isEnabled}');
      },
      child: Scaffold(
        body: MyContent(),
      ),
    );
  }
}
```

## Testing

### Test in Debug Mode

1. **Run app**: `flutter run`
2. **Navigate to**: Home page
3. **Click**: Fullscreen icon (top-right, debug only)
4. **Enable**: Toggle kiosk mode ON
5. **Verify**:
   - Status bar disappears
   - Navigation bar disappears
   - Screen stays awake

### Test in Release Mode

```bash
# Build release APK
flutter build apk --release

# Install on device
flutter install

# Verify kiosk mode auto-enables
```

### Test App Resume

1. Enable kiosk mode
2. Press home button (Android)
3. Re-open app
4. **Verify**: Immersive mode restored

### Test Screenshots (Android)

1. Enable kiosk mode
2. Try taking screenshot
3. **Verify**: Screenshot fails or shows black screen

## Configuration

### Enable/Disable in Code

```dart
// main.dart

// Option 1: Always enabled
await KioskModeService.enable();

// Option 2: Production only (current)
if (kReleaseMode) {
  await KioskModeService.enable();
}

// Option 3: Never enabled (for development)
// Don't call enable()

// Option 4: Environment-based
if (environment == 'kiosk') {
  await KioskModeService.enable();
}
```

### Screen Orientation

Default: Allows all orientations

To lock orientation:

```dart
// In kiosk_mode_service.dart
await SystemChrome.setPreferredOrientations([
  DeviceOrientation.landscapeLeft,    // Lock to landscape
  DeviceOrientation.landscapeRight,
]);
```

## Visual Design

### Debug Toggle Dialog

```
┌────────────────────────────────────┐
│ ⚙️  Kiosk Mode Settings      [X]  │ ← Blue header
├────────────────────────────────────┤
│                                    │
│  ┌──────────────────────────────┐ │
│  │ Kiosk Mode                   │ │
│  │ Enabled           [Toggle]   │ │ ← Switch
│  │                              │ │
│  │ Features:                    │ │
│  │ ✓ Full-screen mode           │ │ ← Green checkmarks
│  │ ✓ Screen always on           │ │
│  │ ✓ Screenshots disabled       │ │
│  │ ✓ Secure mode (Android)      │ │
│  └──────────────────────────────┘ │
│                                    │
└────────────────────────────────────┘
```

## Dependencies

Added to `pubspec.yaml`:

```yaml
dependencies:
  wakelock_plus: ^1.2.8              # Keep screen awake
  flutter_windowmanager: ^0.2.0      # Android security flags
```

## File Structure

```
lib/
├── core/
│   └── services/
│       └── kiosk_mode_service.dart       # Core kiosk logic
├── features/
│   ├── contract_generation/
│   │   └── KIOSK_MODE_README.md          # This file
│   └── home/
│       └── presentation/
│           └── pages/
│               └── home_page.dart        # Debug toggle
└── main.dart                             # Integration
```

## Troubleshooting

### Status Bar/Nav Bar Still Visible

**Issue**: System UI doesn't hide

**Solutions**:
- Check if kiosk mode is enabled: `KioskModeService.isEnabled`
- Verify release mode: `kReleaseMode`
- Try manual toggle in debug dialog
- Restart app

### Screenshots Still Work (Android)

**Issue**: FLAG_SECURE not working

**Solutions**:
- Verify Android version (works API 14+)
- Check if running in emulator (may not work)
- Test on physical device
- Verify kiosk mode is actually enabled

### Screen Turns Off

**Issue**: Wakelock not working

**Solutions**:
- Check battery optimization settings
- Verify device permissions
- May not work in emulator
- Test on physical device

### Can Still Exit App (Android)

**Issue**: Home button still works

**Solutions**:
- **Standard app limitation** - cannot disable home button
- Need Device Owner mode for true lockdown
- Use MDM solution for enterprise
- Use dedicated kiosk hardware

## Production Deployment

### Recommended Setup

**For True Kiosk Mode:**

1. **Use dedicated kiosk hardware/tablets**
2. **Enroll in MDM** (Mobile Device Management)
3. **Set as Device Owner** (Android)
4. **Enable Guided Access** (iOS - manually)
5. **Physical security** (mount device, lock enclosure)

**For Semi-Kiosk (Current):**

1. **App auto-starts** on device boot
2. **Full-screen mode** active
3. **Session timeout** clears data
4. **Screenshots disabled**
5. **Manual** device management

### Security Checklist

- ✅ Kiosk mode enabled in production
- ✅ Session timeout active (60s)
- ✅ Data clearing on timeout
- ✅ Full-screen mode
- ✅ Screen always on
- ✅ Screenshots disabled (Android)
- ⚠️ Home button accessible (standard app)
- ⚠️ Task switching possible (standard app)

## Next Steps

Future enhancements:

- [ ] **Device Owner mode** implementation
- [ ] **MDM integration** for enterprise
- [ ] **Remote configuration** via API
- [ ] **Passcode exit** (admin unlock)
- [ ] **Usage analytics** tracking
- [ ] **Auto-restart** on crash
- [ ] **Network-based** enable/disable
- [ ] **Scheduled** kiosk mode (hours of operation)

---

**Status**: ✅ Complete for standard app deployment
**Advanced Kiosk**: ⚠️ Requires Device Owner or MDM
**Version**: 1.0
**Last Updated**: January 2025
