import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/localization/translation_provider.dart';
import '../hooks/auth_controller.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final success = await ref.read(authControllerProvider.notifier).login(
      _emailController.text,
      _passwordController.text,
    );

    if (!success && mounted) {
      final error = ref.read(authControllerProvider).errorMessage ?? 'Login failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.crisis),
      );
    }
  }

  void _quickLogin(String email, String password) {
    _emailController.text = email;
    _passwordController.text = password;
    _submit();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final langNotifier = ref.watch(languageProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: ref.watch(languageProvider).isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Stack(
          children: [
            // Background gradient pattern
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.backgroundDark, const Color(0xFF0F172A)]
                        : [AppColors.backgroundLight, const Color(0xFFE2E8F0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            // Header language bar
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton.icon(
                    onPressed: () => ref.read(languageProvider.notifier).toggleLanguage(),
                    icon: Icon(Icons.language, color: isDark ? AppColors.secondaryLight : AppColors.primary),
                    label: Text(
                      ref.read(languageProvider).locale == 'en' ? 'العربية' : 'English',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.secondaryLight : AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Main content
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo and App Name
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.diversity_3,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  langNotifier.translate('app_title'),
                                  style: AppTextStyles.h1(isDark: isDark),
                                ),
                                Text(
                                  langNotifier.translate('tagline'),
                                  style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        // Form Card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    langNotifier.translate('welcome_back'),
                                    style: AppTextStyles.h2(isDark: isDark),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  // Email Field
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.email_outlined),
                                      labelText: langNotifier.translate('email'),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return langNotifier.translate('error_empty_fields');
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  // Password Field
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.lock_outlined),
                                      labelText: langNotifier.translate('password'),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return langNotifier.translate('error_empty_fields');
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  // Submit button
                                  ElevatedButton(
                                    onPressed: authState.isLoading ? null : _submit,
                                    child: authState.isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            langNotifier.translate('login'),
                                            style: AppTextStyles.buttonText(isDark: isDark),
                                          ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Google Login Button
                                  OutlinedButton.icon(
                                    onPressed: authState.isLoading
                                        ? null
                                        : () async {
                                            final success = await ref
                                                .read(authControllerProvider.notifier)
                                                .loginWithGoogle();
                                            if (!success && mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Google Sign-In failed'),
                                                  backgroundColor: AppColors.crisis,
                                                ),
                                              );
                                            }
                                          },
                                    icon: Image.network(
                                      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1024px-Google_%22G%22_logo.svg.png',
                                      height: 18,
                                      width: 18,
                                      errorBuilder: (c, e, s) => const Icon(Icons.g_mobiledata),
                                    ),
                                    label: const Text('Google Sign-In'),
                                  ),
                                  const SizedBox(height: 24),
                                  // Link to Register
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const RegisterScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      langNotifier.translate('no_account'),
                                      style: TextStyle(
                                        color: isDark ? AppColors.secondaryLight : AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Hackathon Demo Quick-Access Section
                        Card(
                          color: isDark
                              ? AppColors.surfaceDark.withOpacity(0.5)
                              : Colors.white.withOpacity(0.7),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            child: Column(
                              children: [
                                const Text(
                                  '⚡ Quick Demo Shortcuts ⚡',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    ActionChip(
                                      label: const Text('Omar (Citizen)'),
                                      onPressed: () => _quickLogin('omar@commonground.org', '123456'),
                                      backgroundColor: AppColors.secondary.withOpacity(0.15),
                                    ),
                                    ActionChip(
                                      label: const Text('Maria (Citizen)'),
                                      onPressed: () => _quickLogin('maria@commonground.org', '123456'),
                                      backgroundColor: AppColors.secondary.withOpacity(0.15),
                                    ),
                                    ActionChip(
                                      label: const Text('Food Bank (Org)'),
                                      onPressed: () => _quickLogin('contact@metrofoodbank.org', '123456'),
                                      backgroundColor: AppColors.accent.withOpacity(0.15),
                                    ),
                                    ActionChip(
                                      label: const Text('Admin'),
                                      onPressed: () => _quickLogin('admin@commonground.org', '123456'),
                                      backgroundColor: AppColors.crisis.withOpacity(0.1),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
