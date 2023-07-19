import 'package:alarm_study/feature/auth/ui/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/presentation/components/app_text_button.dart';
import '../../../app/presentation/components/app_text_field.dart';
import '../domain/auth_state/auth_cubit.dart';


class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final controllerLogin = TextEditingController();
  final controllerPassword = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("LoginScreen")),
      body: Form(
        key: formKey,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(controller: controllerLogin, labelText: "логин"),
                const SizedBox(height: 16),
                AppTextField(
                  obscureText: true,
                  controller: controllerPassword,
                  labelText: "пароль",
                ),
                const SizedBox(height: 16),
                AppTextButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() == true) {
                      _onTapToSignIn(context.read<AuthCubit>());
                    }
                  },
                  text: "войти",
                ),
                const SizedBox(height: 16),
                AppTextButton(
                  backgroundColor: Colors.blueGrey,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => RegisterScreen()));
                  },
                  text: "регистрация",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTapToSignIn(AuthCubit authCubit) => authCubit.signIn(
        username: controllerLogin.text,
        password: controllerPassword.text,
      );
}
