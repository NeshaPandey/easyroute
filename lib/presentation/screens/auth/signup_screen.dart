import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/common/er_button.dart';
import '../../widgets/common/er_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _signup() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            SignUpWithEmail(_emailCtrl.text.trim(), _passCtrl.text, _nameCtrl.text.trim()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) context.go(RouteNames.home);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.go(RouteNames.login)),
          title: const Text('Create account'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Let\'s get you started',
                      style: AppTypography.displayMedium
                          .copyWith(color: AppColors.onSurface)),
                  const SizedBox(height: 8),
                  Text('EasyRoute works better when it knows you.',
                      style: AppTypography.bodyLarge
                          .copyWith(color: AppColors.onSurfaceMuted)),
                  const SizedBox(height: 36),
                  ErTextField(
                    controller: _nameCtrl,
                    label: 'Full name',
                    hint: 'Ravi Kumar',
                    prefixIcon: Icons.person_outline,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 16),
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
                    hint: 'At least 6 characters',
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
                  const SizedBox(height: 32),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) => ErButton(
                      label: 'Create account',
                      onPressed: _signup,
                      loading: state is AuthLoading,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'By signing up you agree to our Terms & Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: AppTypography.caption
                          .copyWith(color: AppColors.onSurfaceMuted),
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
