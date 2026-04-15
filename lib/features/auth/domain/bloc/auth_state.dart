part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => const <Object?>[];
}

final class AuthStateNotAuthorized extends AuthState {
  const AuthStateNotAuthorized();
}

final class AuthStateAuthorized extends AuthState {
  const AuthStateAuthorized({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  @override
  List<Object?> get props => <Object?>[accessToken, refreshToken];
}

final class AuthStateLoading extends AuthState {
  const AuthStateLoading({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

final class AuthStateError extends AuthState {
  const AuthStateError({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

final class AuthStateSmsSent extends AuthState {
  const AuthStateSmsSent({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
