import 'dart:async';
import 'package:flutter/material.dart';

/// Service for managing session timeout and idle detection
/// Automatically resets kiosk session after period of inactivity
class SessionTimeoutService {
  static const Duration defaultTimeout = Duration(seconds: 60);
  static const Duration warningThreshold = Duration(seconds: 10);

  Timer? _idleTimer;
  Timer? _warningTimer;
  Duration _timeoutDuration;
  VoidCallback? _onTimeout;
  VoidCallback? _onWarning;
  DateTime _lastActivityTime;

  SessionTimeoutService({
    Duration? timeout,
    VoidCallback? onTimeout,
    VoidCallback? onWarning,
  })  : _timeoutDuration = timeout ?? defaultTimeout,
        _onTimeout = onTimeout,
        _onWarning = onWarning,
        _lastActivityTime = DateTime.now();

  /// Start the idle timer
  void startTimer() {
    resetTimer();
  }

  /// Reset the idle timer (called on user activity)
  void resetTimer() {
    _lastActivityTime = DateTime.now();
    _cancelTimers();

    // Start warning timer
    final warningDelay = _timeoutDuration - warningThreshold;
    if (warningDelay.isNegative) {
      // Timeout is too short for warning, skip it
      _startTimeoutTimer();
    } else {
      _warningTimer = Timer(warningDelay, () {
        _onWarning?.call();
        _startTimeoutTimer();
      });
    }
  }

  void _startTimeoutTimer() {
    _idleTimer = Timer(warningThreshold, () {
      _onTimeout?.call();
    });
  }

  /// Stop all timers
  void stopTimer() {
    _cancelTimers();
  }

  void _cancelTimers() {
    _idleTimer?.cancel();
    _idleTimer = null;
    _warningTimer?.cancel();
    _warningTimer = null;
  }

  /// Get time since last activity
  Duration getTimeSinceLastActivity() {
    return DateTime.now().difference(_lastActivityTime);
  }

  /// Get remaining time before timeout
  Duration getRemainingTime() {
    final elapsed = getTimeSinceLastActivity();
    final remaining = _timeoutDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Update timeout duration
  void setTimeoutDuration(Duration duration) {
    _timeoutDuration = duration;
    resetTimer();
  }

  /// Update callbacks
  void setCallbacks({
    VoidCallback? onTimeout,
    VoidCallback? onWarning,
  }) {
    _onTimeout = onTimeout;
    _onWarning = onWarning;
  }

  /// Dispose and clean up
  void dispose() {
    _cancelTimers();
  }

  /// Check if currently idle
  bool get isIdle => getTimeSinceLastActivity() > _timeoutDuration;

  /// Get timeout duration
  Duration get timeoutDuration => _timeoutDuration;
}

/// Widget wrapper that detects user activity and manages session timeout
class SessionTimeoutWrapper extends StatefulWidget {
  final Widget child;
  final Duration timeout;
  final VoidCallback onTimeout;
  final VoidCallback? onWarning;
  final bool enabled;

  const SessionTimeoutWrapper({
    super.key,
    required this.child,
    this.timeout = SessionTimeoutService.defaultTimeout,
    required this.onTimeout,
    this.onWarning,
    this.enabled = true,
  });

  @override
  State<SessionTimeoutWrapper> createState() => _SessionTimeoutWrapperState();
}

class _SessionTimeoutWrapperState extends State<SessionTimeoutWrapper> {
  late SessionTimeoutService _sessionService;

  @override
  void initState() {
    super.initState();
    _sessionService = SessionTimeoutService(
      timeout: widget.timeout,
      onTimeout: widget.onTimeout,
      onWarning: widget.onWarning,
    );

    if (widget.enabled) {
      _sessionService.startTimer();
    }
  }

  @override
  void didUpdateWidget(SessionTimeoutWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.timeout != oldWidget.timeout) {
      _sessionService.setTimeoutDuration(widget.timeout);
    }

    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _sessionService.startTimer();
      } else {
        _sessionService.stopTimer();
      }
    }

    if (widget.onTimeout != oldWidget.onTimeout ||
        widget.onWarning != oldWidget.onWarning) {
      _sessionService.setCallbacks(
        onTimeout: widget.onTimeout,
        onWarning: widget.onWarning,
      );
    }
  }

  @override
  void dispose() {
    _sessionService.dispose();
    super.dispose();
  }

  void _handleUserActivity() {
    if (widget.enabled) {
      _sessionService.resetTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _handleUserActivity,
      onPanDown: (_) => _handleUserActivity(),
      onScaleStart: (_) => _handleUserActivity(),
      child: Listener(
        onPointerDown: (_) => _handleUserActivity(),
        onPointerMove: (_) => _handleUserActivity(),
        onPointerUp: (_) => _handleUserActivity(),
        onPointerHover: (_) => _handleUserActivity(),
        child: widget.child,
      ),
    );
  }
}

/// Dialog shown when timeout warning is triggered
class TimeoutWarningDialog extends StatefulWidget {
  final Duration remainingTime;
  final VoidCallback onContinue;
  final VoidCallback onTimeout;

  const TimeoutWarningDialog({
    super.key,
    required this.remainingTime,
    required this.onContinue,
    required this.onTimeout,
  });

  @override
  State<TimeoutWarningDialog> createState() => _TimeoutWarningDialogState();
}

class _TimeoutWarningDialogState extends State<TimeoutWarningDialog> {
  late int _secondsRemaining;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.remainingTime.inSeconds;
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsRemaining--;
      });

      if (_secondsRemaining <= 0) {
        timer.cancel();
        Navigator.of(context).pop();
        widget.onTimeout();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange[700],
            size: 32,
          ),
          const SizedBox(width: 12),
          const Text('Sesiune inactivă'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Sesiunea dumneavoastră va expira în:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[300]!, width: 2),
            ),
            child: Text(
              '$_secondsRemaining',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'secunde',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Apăsați "Continuă" pentru a păstra sesiunea activă.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              _countdownTimer?.cancel();
              Navigator.of(context).pop();
              widget.onContinue();
            },
            icon: const Icon(Icons.touch_app),
            label: const Text('Continuă sesiunea'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
