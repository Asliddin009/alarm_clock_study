import 'package:alearn/app/app_flow/domain/app_flow_cubit.dart';
import 'package:alearn/app/app_flow/domain/app_flow_state.dart';
import 'package:alearn/app/helper/localization_helper.dart';
import 'package:alearn/app/ui/ui_kit/app_container.dart';
import 'package:alearn/app/ui/ui_kit/app_entrance.dart';
import 'package:alearn/app/ui/ui_kit/text_field/app_text_field.dart';
import 'package:alearn/features/auth/data/mock_app_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: MockAuthRepo.demoEmail);
    _passwordController = TextEditingController(
      text: MockAuthRepo.demoPassword,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = LocalizationHelper.getLocalizations(context);

    return BlocBuilder<AppFlowCubit, AppFlowState>(
      builder: (context, state) {
        return Scaffold(
          key: const Key('auth-screen'),
          body: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: -80,
                  right: -30,
                  child: _AccentOrb(
                    size: 220,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.10),
                  ),
                ),
                Positioned(
                  left: -60,
                  bottom: 40,
                  child: _AccentOrb(
                    size: 180,
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.10),
                  ),
                ),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: AppEntrance(
                        child: AppContainer(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizations.auth_title,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                localizations.auth_subtitle,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 24),
                              AppEntrance(
                                delay: const Duration(milliseconds: 90),
                                child: BaseTextField(
                                  key: const Key('auth-email-field'),
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.none,
                                  hintText: localizations.email,
                                ),
                              ),
                              const SizedBox(height: 16),
                              AppEntrance(
                                delay: const Duration(milliseconds: 140),
                                child: BaseTextField(
                                  key: const Key('auth-password-field'),
                                  controller: _passwordController,
                                  obscureText: true,
                                  textCapitalization: TextCapitalization.none,
                                  hintText: localizations.password,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                localizations.mock_auth_hint,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 22),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  key: const Key('auth-sign-in-button'),
                                  onPressed: state.isLoading
                                      ? null
                                      : () {
                                          context.read<AppFlowCubit>().signIn(
                                            email: _emailController.text.trim(),
                                            password: _passwordController.text
                                                .trim(),
                                          );
                                        },
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 180),
                                    child: state.isLoading
                                        ? const SizedBox(
                                            key: ValueKey('loading'),
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            localizations.sign_in,
                                            key: const ValueKey('label'),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  key: const Key('auth-skip-button'),
                                  onPressed: state.isLoading
                                      ? null
                                      : () {
                                          context
                                              .read<AppFlowCubit>()
                                              .continueAsGuest();
                                        },
                                  child: Text(localizations.skip_for_now),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                key: const Key('auth-change-language-button'),
                                onPressed: state.isLoading
                                    ? null
                                    : () {
                                        context
                                            .read<AppFlowCubit>()
                                            .showLanguageSelection();
                                      },
                                child: Text(localizations.change_language),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AccentOrb extends StatelessWidget {
  const _AccentOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
