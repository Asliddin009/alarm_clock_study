import 'package:equatable/equatable.dart';

enum AuthSessionType { authorized, guest }

final class AuthSession extends Equatable {
  const AuthSession({required this.type, this.email, this.displayName});

  final AuthSessionType type;
  final String? email;
  final String? displayName;

  bool get isGuest => type == AuthSessionType.guest;

  @override
  List<Object?> get props => <Object?>[type, email, displayName];
}
