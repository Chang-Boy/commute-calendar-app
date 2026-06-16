import 'package:commute_calendar/core/di/service_locator.dart';
import 'package:commute_calendar/core/theme/theme_service.dart';
import 'package:commute_calendar/feature/auth/presentation/sign_in/bloc/sign_in_bloc.dart';
import 'package:commute_calendar/feature/auth/presentation/sign_in/bloc/sign_in_event.dart';
import 'package:commute_calendar/feature/auth/presentation/sign_in/bloc/sign_in_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SignInBloc>(),
      child: const _SignInView(),
    );
  }
}

class _SignInView extends StatefulWidget {
  const _SignInView();

  @override
  State<_SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<_SignInView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    context.read<SignInBloc>().add(
      SignInSubmitted(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService.white,
      body: BlocListener<SignInBloc, SignInState>(
        listener: (context, state) {
          if (state is SignInFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, style: ThemeService.body2.copyWith(color: ThemeService.white)),
                backgroundColor: ThemeService.secondary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                const Text('안녕하세요,', style: ThemeService.headline),
                const SizedBox(height: 4),
                Text(
                  '로그인 후 이용해주세요.',
                  style: ThemeService.body1.copyWith(color: ThemeService.black500),
                ),
                const SizedBox(height: 48),
                _AuthTextField(
                  controller: _emailController,
                  label: '이메일',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _AuthTextField(
                  controller: _passwordController,
                  label: '비밀번호',
                  obscureText: true,
                  onSubmitted: (_) => _onSubmit(),
                ),
                const SizedBox(height: 32),
                BlocBuilder<SignInBloc, SignInState>(
                  builder: (context, state) {
                    final isLoading = state is SignInLoading;
                    return _SignInButton(
                      onPressed: isLoading ? null : _onSubmit,
                      isLoading: isLoading,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.obscureText = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ThemeService.caption.copyWith(color: ThemeService.black600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onSubmitted: onSubmitted,
          style: ThemeService.body2,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: ThemeService.black300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: ThemeService.primary, width: 1.5),
            ),
            filled: true,
            fillColor: ThemeService.black100,
          ),
        ),
      ],
    );
  }
}

class _SignInButton extends StatelessWidget {
  const _SignInButton({required this.onPressed, required this.isLoading});

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: ThemeService.primary,
          disabledBackgroundColor: ThemeService.black300,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ThemeService.white,
                ),
              )
            : Text(
                '로그인',
                style: ThemeService.body2.copyWith(
                  color: ThemeService.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
