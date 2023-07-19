import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/domain/entities/error_entity/error_entity.dart';
import '../../../app/presentation/app_loader.dart';
import '../../../app/presentation/components/app_dialog.dart';
import '../../../app/presentation/components/app_snack_bar.dart';
import '../domain/auth_state/auth_cubit.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Личный кабинет"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<AuthCubit>().logOut();
              },
              icon: const Icon(Icons.exit_to_app))
        ],
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          state.whenOrNull(
            authorized: (userEntity) {
              if (userEntity.userState?.hasData == true) {
                AppSnackBar.showSnackBarWithMessage(
                    context, userEntity.userState?.data);
              }
              if (userEntity.userState?.hasError == true) {
                AppSnackBar.showSnackBarWithError(context,
                    ErrorEntity.fromException(userEntity.userState?.error));
              }
            },
          );
        },
        builder: (context, state) {
          final userEntity = state.whenOrNull(
            authorized: (userEntity) => userEntity,
          );
          if (userEntity?.userState?.connectionState ==
              ConnectionState.waiting) {
            return const AppLoader();
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Text(
                        userEntity?.username.split("").first ?? "Отсутствует"),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      Text(userEntity?.username ?? ""),
                      Text(userEntity?.email ?? ""),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AppDialog(
                            val1: "old",
                            val2: "new",
                            onPressed: (v1, v2) {
                              context.read<AuthCubit>().passwordUpdate(
                                  newPassword: v1, oldPassword: v2);
                            },
                          ),
                        );
                      },
                      child: const Text("Обновить пароль")),
                  TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AppDialog(
                            val1: "username",
                            val2: "email",
                            onPressed: (v1, v2) {
                              context
                                  .read<AuthCubit>()
                                  .userUpdate(email: v2, username: v1);
                            },
                          ),
                        );
                      },
                      child: const Text("Обновить данные"))
                ],
              )
            ]),
          );
        },
      ),
    );
  }
}
