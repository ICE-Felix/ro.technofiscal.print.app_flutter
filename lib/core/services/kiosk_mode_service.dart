import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

/// Service for managing kiosk mode settings
/// Provides full-screen experience and prevents user from exiting app
class KioskModeService {
  static bool _isEnabled = false;
  static bool _isInitialized = false;

  /// Enable kiosk mode
  /// - Full screen (hide status bar and navigation bar)
  /// - Keep screen awake
  /// - Disable screenshots (Android)
  /// - Secure mode (Android)
  static Future<void> enable() async {
    if (_isEnabled) return;

    try {
      // Enable immersive mode (hide system UI)
      await _enableImmersiveMode();

      // Keep screen awake
      await WakelockPlus.enable();

      // Android-specific security features
      if (await _isAndroid()) {
        try {
          // Disable screenshots
          await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

          // Keep screen on
          await FlutterWindowManager.addFlags(
            FlutterWindowManager.FLAG_KEEP_SCREEN_ON,
          );

          // Turn screen on when app opens
          await FlutterWindowManager.addFlags(
            FlutterWindowManager.FLAG_TURN_SCREEN_ON,
          );

          // Show when locked
          await FlutterWindowManager.addFlags(
            FlutterWindowManager.FLAG_SHOW_WHEN_LOCKED,
          );
        } catch (e) {
          debugPrint('Android kiosk flags error: $e');
        }
      }

      _isEnabled = true;
      _isInitialized = true;
      debugPrint('✅ Kiosk mode enabled');
    } catch (e) {
      debugPrint('❌ Error enabling kiosk mode: $e');
    }
  }

  /// Disable kiosk mode
  /// Restore normal system UI behavior
  static Future<void> disable() async {
    if (!_isEnabled) return;

    try {
      // Restore system UI
      await _disableImmersiveMode();

      // Allow screen to sleep
      await WakelockPlus.disable();

      // Android-specific: remove security flags
      if (await _isAndroid()) {
        try {
          await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
          await FlutterWindowManager.clearFlags(
            FlutterWindowManager.FLAG_KEEP_SCREEN_ON,
          );
        } catch (e) {
          debugPrint('Android clear flags error: $e');
        }
      }

      _isEnabled = false;
      debugPrint('✅ Kiosk mode disabled');
    } catch (e) {
      debugPrint('❌ Error disabling kiosk mode: $e');
    }
  }

  /// Enable immersive full-screen mode
  static Future<void> _enableImmersiveMode() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );

    // Set preferred orientations (optional - landscape for kiosk)
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
  }

  /// Disable immersive mode
  static Future<void> _disableImmersiveMode() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );

    // Reset orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// Check if running on Android
  static Future<bool> _isAndroid() async {
    try {
      return Theme.of(
        WidgetsBinding.instance.rootElement!,
      ).platform == TargetPlatform.android;
    } catch (e) {
      return false;
    }
  }

  /// Check if kiosk mode is currently enabled
  static bool get isEnabled => _isEnabled;

  /// Check if kiosk mode has been initialized
  static bool get isInitialized => _isInitialized;

  /// Toggle kiosk mode on/off
  static Future<void> toggle() async {
    if (_isEnabled) {
      await disable();
    } else {
      await enable();
    }
  }

  /// Restore immersive mode if system UI reappears
  /// Call this on app resume or when user returns to app
  static Future<void> refreshImmersiveMode() async {
    if (_isEnabled) {
      await _enableImmersiveMode();
    }
  }
}

/// Widget that automatically enables kiosk mode when built
/// and disables when disposed
class KioskModeWrapper extends StatefulWidget {
  final Widget child;
  final bool enableKioskMode;
  final VoidCallback? onKioskModeChanged;

  const KioskModeWrapper({
    super.key,
    required this.child,
    this.enableKioskMode = true,
    this.onKioskModeChanged,
  });

  @override
  State<KioskModeWrapper> createState() => _KioskModeWrapperState();
}

class _KioskModeWrapperState extends State<KioskModeWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.enableKioskMode) {
      _enableKioskMode();
    }
  }

  @override
  void didUpdateWidget(KioskModeWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.enableKioskMode != oldWidget.enableKioskMode) {
      if (widget.enableKioskMode) {
        _enableKioskMode();
      } else {
        _disableKioskMode();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When app resumes, restore immersive mode
    if (state == AppLifecycleState.resumed && widget.enableKioskMode) {
      KioskModeService.refreshImmersiveMode();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    if (widget.enableKioskMode) {
      _disableKioskMode();
    }

    super.dispose();
  }

  Future<void> _enableKioskMode() async {
    await KioskModeService.enable();
    widget.onKioskModeChanged?.call();
  }

  Future<void> _disableKioskMode() async {
    await KioskModeService.disable();
    widget.onKioskModeChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Admin panel to toggle kiosk mode
/// Use this in debug/development mode only
class KioskModeToggle extends StatefulWidget {
  const KioskModeToggle({super.key});

  @override
  State<KioskModeToggle> createState() => _KioskModeToggleState();
}

class _KioskModeToggleState extends State<KioskModeToggle> {
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    _isEnabled = KioskModeService.isEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kiosk Mode',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isEnabled ? 'Enabled' : 'Disabled',
                      style: TextStyle(
                        fontSize: 14,
                        color: _isEnabled ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: _isEnabled,
                  onChanged: (value) async {
                    await KioskModeService.toggle();
                    setState(() {
                      _isEnabled = KioskModeService.isEnabled;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Features:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _buildFeatureRow(
              '• Full-screen mode',
              KioskModeService.isEnabled,
            ),
            _buildFeatureRow(
              '• Screen always on',
              KioskModeService.isEnabled,
            ),
            _buildFeatureRow(
              '• Screenshots disabled (Android)',
              KioskModeService.isEnabled,
            ),
            _buildFeatureRow(
              '• Secure mode (Android)',
              KioskModeService.isEnabled,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String label, bool enabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: enabled ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: enabled ? Colors.black87 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
