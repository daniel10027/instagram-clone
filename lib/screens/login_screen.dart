import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_wordmark.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'feed_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final authProvider = context.read<AuthProvider>();
    FocusScope.of(context).unfocus();

    final success = await authProvider.login(
      _usernameController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const FeedScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              const AppWordmark(),
              const SizedBox(height: 40),
              CustomTextField(
                hintText: 'Phone number, username or email',
                controller: _usernameController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                hintText: 'Password',
                controller: _passwordController,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Text(
                    _obscurePassword ? 'Show' : 'Hide',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "La recuperation de mot de passe n'est pas disponible dans cette demonstration.",
                        ),
                      ),
                    );
                  },
                  child: const Text('Forgotten password?', style: AppTextStyles.linkText),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: authProvider.errorMessage != null
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            authProvider.errorMessage!,
                            style: AppTextStyles.errorText,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              PrimaryButton(
                label: 'Log In',
                isLoading: authProvider.isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 24),
              const _OrDivider(),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "La connexion via Facebook n'est pas disponible dans cette demonstration.",
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.facebook, color: AppColors.facebookBlue, size: 18),
                label: const Text(
                  'Log in with Facebook',
                  style: TextStyle(
                    color: AppColors.facebookBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 64),
              const _SignUpFooter(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text('OR', style: TextStyle(color: AppColors.secondaryText, fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      ],
    );
  }
}

class _SignUpFooter extends StatelessWidget {
  const _SignUpFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(color: AppColors.border, thickness: 1),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have an account? ", style: AppTextStyles.footerText),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("L'inscription n'est pas disponible dans cette demonstration."),
                  ),
                );
              },
              child: const Text('Sign up.', style: AppTextStyles.footerAction),
            ),
          ],
        ),
      ],
    );
  }
}
