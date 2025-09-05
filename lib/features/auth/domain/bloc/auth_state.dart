part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthStateNotAuthorized extends AuthState {
  String get name => 'AuthStateNotAuthorized';
}

final class AuthStateAuthorized extends AuthState {
  const AuthStateAuthorized({
    required this.accessToken,
    required this.refreshToken,
  });
  final String accessToken;
  final String refreshToken;
}

final class AuthStateLoading extends AuthState {
  const AuthStateLoading({required this.message});
  final String message;
}

final class AuthStateError extends AuthState {
  const AuthStateError({required this.message});

  final String message;
}

final class AuthStateSmsSent extends AuthState {
  const AuthStateSmsSent({required this.message});

  final String message;
}
