import 'package:alearn/features/auth/domain/i_auth_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this.repo) : super(AuthStateNotAuthorized()) {
    on<AuthEventSignInSms>(_signInSms);
    on<AuthEventSendSms>(_sendSms);
  }
  final IAuthRepo repo;

  Future<void> _signInSms(
    AuthEventSignInSms event,
    Emitter<AuthState> emit,
  ) async {
    try {
      if (state is AuthStateLoading) return;
      emit(const AuthStateLoading(message: 'loading'));
      final message = await repo.signInSms(event.email);
      emit(AuthStateSmsSent(message: message));
    } on Object catch (e, st) {
      emit(AuthStateError(message: e.toString()));
      addError(e, st);
    }
  }

  Future<void> _sendSms(AuthEventSendSms event, Emitter<AuthState> emit) async {
    try {
      final token = await repo.sendSms(event.email, event.code);
      emit(AuthStateAuthorized(accessToken: token.$1, refreshToken: token.$2));
    } on Object catch (e, st) {
      emit(AuthStateError(message: e.toString()));
      addError(e, st);
    }
  }
}
