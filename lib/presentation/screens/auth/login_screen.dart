import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/common/er_button.dart';
import '../../widgets/common/er_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            LoginWithEmail(_emailCtrl.text.trim(), _passCtrl.text),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) context.go(RouteNames.home);
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  // Logo mark
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.navigation_rounded,
                        color: AppColors.primary, size: 30),
                  ),
                  const SizedBox(height: 24),
                  Text('Welcome back',
                      style: AppTypography.displayMedium
                          .copyWith(color: AppColors.onSurface)),
                  const SizedBox(height: 8),
                  Text('Sign in to continue your journey',
                      style: AppTypography.bodyLarge
                          .copyWith(color: AppColors.onSurfaceMuted)),
                  const SizedBox(height: 40),

                  ErTextField(
                    controller: _emailCtrl,
                    label: 'Email address',
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (v) =>
                        (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                  ),
                  const SizedBox(height: 16),
                  ErTextField(
                    controller: _passCtrl,
                    label: 'Password',
                    hint: '••••••••',
                    obscureText: _obscure,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    validator: (v) =>
                        (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return ErButton(
                        label: 'Sign in',
                        onPressed: _login,
                        loading: state is AuthLoading,
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  Row(children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('or',
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.onSurfaceMuted)),
                    ),
                    const Expanded(child: Divider()),
                  ]),
                  const SizedBox(height: 24),

                  // Google sign-in
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.read<AuthBloc>().add(LoginWithGoogle()),
                    icon: const Icon(Icons.g_mobiledata, size: 26),
                    label: const Text('Continue with Google'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      textStyle: AppTypography.labelLarge,
                    ),
                  ),
                  const SizedBox(height: 40),

                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Don't have an account? ",
                            style: AppTypography.bodyMedium
                                .copyWith(color: AppColors.onSurfaceMuted)),
                        GestureDetector(
                          onTap: () => context.go(RouteNames.signup),
                          child: Text('Sign up',
                              style: AppTypography.labelLarge
                                  .copyWith(color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
