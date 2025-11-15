import 'dart:async';

import 'package:app/core/service_locator.dart';
import 'package:app/core/services/firebase_messaging_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/localization/app_localization.dart';
import '../../data/models/user_model.dart';
import '../../domain/services/authentication_service.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final LogoutUseCase logoutUseCase;
  final LocalizationCubit localizationCubit;
  final AuthenticationService _authenticationService;
  late final StreamSubscription<UserModel?> _authStateSubscription;

  AuthenticationBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.forgotPasswordUseCase,
    required this.checkAuthStatusUseCase,
    required this.logoutUseCase,
    required this.localizationCubit,
    required AuthenticationService authenticationService,
  }) : _authenticationService = authenticationService,
       super(AuthInitial()) {
    on<CheckAuthStatusRequested>(_onCheckAuthStatusRequested);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);

    // Listen to real-time auth state changes
    _authStateSubscription = _authenticationService.authStateChanges.listen(
      (UserModel? user) async {
        // Only use Firebase on mobile platforms
        if (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS) {
          if (user != null) {
            // User signed in
            await sl<FirebaseMessagingService>().initializeTokenForLoggedUser(
              userId: user.id.toString(),
            );
            // Note: We can't emit here as we're not in an event handler
            // The auth state changes will be handled by the individual event handlers
          } else {
            // User signed out
            await sl<FirebaseMessagingService>().clearAuthData();
            // Note: We can't emit here as we're not in an event handler
            // The auth state changes will be handled by the individual event handlers
          }
        }
      },
      onError: (error) {
        if (kDebugMode) {
          print('❌ AuthBloc: Auth state change error: $error');
        }
        // Note: We can't emit here as we're not in an event handler
      },
    );

    // Listen to token refresh only on mobile platforms
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        sl<FirebaseMessagingService>().refreshToken();
      });
    }
  }

  @override
  Future<void> close() async {
    await _authStateSubscription.cancel();
    _authenticationService.dispose();
    return super.close();
  }

  Future<void> _onCheckAuthStatusRequested(
    CheckAuthStatusRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🔍 AuthBloc: Checking auth status...');
      }

      emit(AuthLoading());

      final user = await checkAuthStatusUseCase(NoParams());

      if (kDebugMode) {
        print(
          '🔍 AuthBloc: Auth check result - user: ${user != null ? 'authenticated' : 'not authenticated'}',
        );
      }

      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthBloc: Auth check failed: $e');
      }
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🔐 AuthBloc: Login requested for ${event.email}');
      }

      emit(AuthLoading());

      final user = await loginUseCase(
        LoginParams(email: event.email, password: event.password),
      );

      if (kDebugMode) {
        print('✅ AuthBloc: Login successful');
      }

      emit(AuthAuthenticated(user));
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthBloc: Login failed: $e');
      }
      final friendlyMessage = _getFriendlyErrorMessage(e.toString());
      emit(AuthError(friendlyMessage));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🚪 AuthBloc: Logout requested');
      }

      emit(AuthLoading());

      await logoutUseCase(NoParams());

      if (kDebugMode) {
        print('✅ AuthBloc: Logout successful');
      }

      emit(AuthUnauthenticated());
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthBloc: Logout failed: $e');
      }
      // Even if logout fails, we should consider the user logged out locally
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('📝 AuthBloc: Register requested for ${event.email}');
      }

      emit(AuthLoading());

      // Use the register use case to create a user in Supabase
      final user = await registerUseCase(
        RegisterParams(
          name: event.name,
          email: event.email,
          password: event.password,
        ),
      );

      if (kDebugMode) {
        print('✅ AuthBloc: Registration successful');
      }

      // Emit authenticated state with the user
      emit(AuthAuthenticated(user));
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthBloc: Registration failed: $e');
      }
      final friendlyMessage = _getFriendlyErrorMessage(e.toString());
      emit(AuthError(friendlyMessage));
    }
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🔑 AuthBloc: Forgot password requested for ${event.email}');
      }

      emit(AuthLoading());

      await forgotPasswordUseCase(ForgotPasswordParams(email: event.email));

      // Add a slight delay to show loading state
      await Future.delayed(const Duration(milliseconds: 500));

      if (kDebugMode) {
        print('✅ AuthBloc: Password reset email sent');
      }

      // We don't emit the authenticated state since the user is not authenticated yet,
      // they've just requested a password reset
      emit(AuthPasswordResetSent());
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthBloc: Forgot password failed: $e');
      }
      final friendlyMessage = _getFriendlyErrorMessage(e.toString());
      emit(AuthError(friendlyMessage));
    }
  }

  /// Converts technical error messages to user-friendly messages
  String _getFriendlyErrorMessage(String errorMsg) {
    if (kDebugMode) {
      print('🔍 AuthBloc: Processing error: $errorMsg');
    }

    // Check for specific error patterns
    if (errorMsg.contains('invalid_credentials')) {
      return localizationCubit.getString(label: 'invalidCredentials');
    } else if (errorMsg.contains('email_taken') ||
        errorMsg.contains('duplicate')) {
      return localizationCubit.getString(label: 'emailAlreadyInUse');
    } else if (errorMsg.contains('weak_password')) {
      return localizationCubit.getString(label: 'weakPassword');
    } else if (errorMsg.contains('network') ||
        errorMsg.contains('connection')) {
      return localizationCubit.getString(label: 'networkError');
    } else if (errorMsg.contains('timeout')) {
      return localizationCubit.getString(label: 'requestTimeout');
    } else if (errorMsg.contains('not_found')) {
      return localizationCubit.getString(label: 'resourceNotFound');
    } else {
      // Default generic message for unexpected errors
      return localizationCubit.getString(label: 'somethingWentWrong');
    }
  }
}
