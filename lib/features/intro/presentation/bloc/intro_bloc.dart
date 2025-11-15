import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/intro_entity.dart';
import '../../domain/usecases/check_network_usecase.dart';
import '../../domain/usecases/complete_intro_usecase.dart';

part 'intro_event.dart';
part 'intro_state.dart';

class IntroBloc extends Bloc<IntroEvent, IntroState> {
  final CheckNetworkUseCase checkNetworkUseCase;
  final CompleteIntroUseCase completeIntroUseCase;

  IntroBloc({
    required this.checkNetworkUseCase,
    required this.completeIntroUseCase,
  }) : super(IntroInitial()) {
    on<IntroStarted>(_onIntroStarted);
    on<IntroNetworkCheckRequested>(_onIntroNetworkCheckRequested);
    on<IntroAnimationCompleted>(_onIntroAnimationCompleted);
    on<IntroCompleted>(_onIntroCompleted);
  }

  Future<void> _onIntroStarted(
    IntroStarted event,
    Emitter<IntroState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🚀 Intro started - checking network connection...');
      }

      emit(IntroLoading());

      // Add a small delay to show loading state
      await Future.delayed(const Duration(milliseconds: 500));

      // Check network connection
      add(IntroNetworkCheckRequested());
    } catch (e) {
      if (kDebugMode) {
        print('❌ Intro start failed: $e');
      }
      emit(IntroNetworkError('Failed to start intro: ${e.toString()}'));
    }
  }

  Future<void> _onIntroNetworkCheckRequested(
    IntroNetworkCheckRequested event,
    Emitter<IntroState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🌐 Checking network connection...');
      }

      final intro = await checkNetworkUseCase(NoParams());

      if (kDebugMode) {
        print('🌐 Network check result: ${intro.isNetworkConnected}');
      }

      if (!intro.isNetworkConnected) {
        if (kDebugMode) {
          print('❌ No network connection detected');
        }
        emit(
          IntroNetworkError(
            intro.errorMessage ??
                'No internet connection. Please check your network settings and try again.',
          ),
        );
        return;
      }

      if (kDebugMode) {
        print('✅ Network connected - starting animation');
      }

      // If network is connected, start the animation
      emit(IntroAnimating(isNetworkConnected: intro.isNetworkConnected));

      // Remove the automatic completion - let the animation widget handle it
    } catch (e) {
      if (kDebugMode) {
        print('❌ Network check failed: $e');
      }
      emit(
        IntroNetworkError(
          'Failed to check network connection. Please try again.',
        ),
      );
    }
  }

  Future<void> _onIntroAnimationCompleted(
    IntroAnimationCompleted event,
    Emitter<IntroState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🎬 Animation completed - completing intro...');
      }

      await completeIntroUseCase(NoParams());

      if (kDebugMode) {
        print('✅ Intro completed - navigating to home');
      }

      emit(IntroNavigateToHome());
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to complete intro: $e');
      }
      emit(IntroNetworkError('Failed to complete intro: ${e.toString()}'));
    }
  }

  Future<void> _onIntroCompleted(
    IntroCompleted event,
    Emitter<IntroState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('✅ Intro completed manually');
      }
      emit(IntroNavigateToHome());
    } catch (e) {
      if (kDebugMode) {
        print('❌ Manual intro completion failed: $e');
      }
      emit(IntroNetworkError('Failed to complete intro: ${e.toString()}'));
    }
  }
}
