import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/session_timeout_service.dart';
import '../navigation/routes_name.dart';

/// Wrapper widget for kiosk pages that need session timeout management
/// Automatically resets session and clears data after inactivity
class KioskSessionWrapper extends StatefulWidget {
  final Widget child;
  final Duration timeout;
  final bool clearDataOnTimeout;
  final List<String> dataKeysToClear;

  const KioskSessionWrapper({
    super.key,
    required this.child,
    this.timeout = const Duration(seconds: 60),
    this.clearDataOnTimeout = true,
    this.dataKeysToClear = const [
      'contract_data',
      'current_field',
    ],
  });

  @override
  State<KioskSessionWrapper> createState() => _KioskSessionWrapperState();
}

class _KioskSessionWrapperState extends State<KioskSessionWrapper> {
  bool _warningDialogShown = false;

  @override
  Widget build(BuildContext context) {
    return SessionTimeoutWrapper(
      timeout: widget.timeout,
      onWarning: _handleWarning,
      onTimeout: _handleTimeout,
      child: widget.child,
    );
  }

  void _handleWarning() {
    if (_warningDialogShown) return;

    _warningDialogShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TimeoutWarningDialog(
        remainingTime: const Duration(seconds: 10),
        onContinue: () {
          _warningDialogShown = false;
        },
        onTimeout: () {
          _warningDialogShown = false;
          _handleTimeout();
        },
      ),
    );
  }

  Future<void> _handleTimeout() async {
    // Clear contract data if requested
    if (widget.clearDataOnTimeout) {
      await _clearData();
    }

    // Show timeout message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sesiune expirată din cauza inactivității. Reveniți la pagina principală.',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );

      // Wait a moment for user to see the message
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to home
      if (mounted) {
        context.go(AppRoutesNames.home.path);
      }
    }
  }

  Future<void> _clearData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      for (final key in widget.dataKeysToClear) {
        await prefs.remove(key);
      }
    } catch (e) {
      debugPrint('Error clearing session data: $e');
    }
  }
}
