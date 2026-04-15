part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class AuthEventSignInSms extends AuthEvent {
  const AuthEventSignInSms({required this.email});

  final String email;

  @override
  List<Object?> get props => <Object?>[email];
}

final class AuthEventSendSms extends AuthEvent {
  const AuthEventSendSms({required this.code, required this.email});

  final String code;
  final String email;

  @override
  List<Object?> get props => <Object?>[code, email];
}
