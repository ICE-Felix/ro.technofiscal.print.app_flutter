part of 'intro_bloc.dart';

@immutable
abstract class IntroState extends Equatable {
  const IntroState();

  @override
  List<Object?> get props => [];
}

class IntroInitial extends IntroState {}

class IntroLoading extends IntroState {}

class IntroAnimating extends IntroState {
  final bool isNetworkConnected;

  const IntroAnimating({required this.isNetworkConnected});

  @override
  List<Object> get props => [isNetworkConnected];
}

class IntroNetworkError extends IntroState {
  final String message;

  const IntroNetworkError(this.message);

  @override
  List<Object> get props => [message];
}

class IntroSuccess extends IntroState {
  final IntroEntity intro;

  const IntroSuccess(this.intro);

  @override
  List<Object> get props => [intro];
}

class IntroNavigateToAuth extends IntroState {}

class IntroNavigateToHome extends IntroState {}
