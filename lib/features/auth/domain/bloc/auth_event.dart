part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

final class AuthEventSignInSms extends AuthEvent {
  const AuthEventSignInSms({required this.email});
  final String email;
}

final class AuthEventSendSms extends AuthEvent {
  const AuthEventSendSms({required this.code, required this.email});
  final String code;
  final String email;
}
