import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/localization/translation_provider.dart';
import '../domain/entities/app_user.dart';
import '../hooks/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  UserRole _selectedRole = UserRole.citizen;

  @override
  void dispose() {
    _emailController.dispose();
    _displayNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final langNotifier = ref.read(languageProvider.notifier);
    
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(langNotifier.translate('error_passwords_match')),
          backgroundColor: AppColors.crisis,
        ),
      );
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).register(
      email: _emailController.text,
      password: _passwordController.text,
      role: _selectedRole,
      displayName: _displayNameController.text,
    );

    if (success && mounted) {
      Navigator.pop(context); // Go back to login, controller will route or user is already logged in
    } else if (mounted) {
      final error = ref.read(authControllerProvider).errorMessage ?? 'Registration failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.crisis),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final langNotifier = ref.watch(languageProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: ref.watch(languageProvider).isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppColors.primary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            // Background
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
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                langNotifier.translate('create_account'),
                                style: AppTextStyles.h2(isDark: isDark),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              // Role Selection
                              Text(
                                langNotifier.translate('select_role'),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              SegmentedButton<UserRole>(
                                segments: [
                                  ButtonSegment<UserRole>(
                                    value: UserRole.citizen,
                                    label: Text(langNotifier.translate('role_citizen')),
                                    icon: const Icon(Icons.person),
                                  ),
                                  ButtonSegment<UserRole>(
                                    value: UserRole.organization,
                                    label: Text(langNotifier.translate('role_org')),
                                    icon: const Icon(Icons.corporate_fare),
                                  ),
                                  ButtonSegment<UserRole>(
                                    value: UserRole.admin,
                                    label: Text('Admin'),
                                    icon: const Icon(Icons.admin_panel_settings),
                                  ),
                                ],
                                selected: {_selectedRole},
                                onSelectionChanged: (Set<UserRole> newSelection) {
                                  setState(() {
                                    _selectedRole = newSelection.first;
                                  });
                                },
                              ),
                              const SizedBox(height: 24),
                              // Display Name Field
                              TextFormField(
                                controller: _displayNameController,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.face_outlined),
                                  labelText: _selectedRole == UserRole.organization
                                      ? langNotifier.translate('service_name')
                                      : 'Full Name',
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return langNotifier.translate('error_empty_fields');
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
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
                              const SizedBox(height: 16),
                              // Confirm Password Field
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.lock_reset_outlined),
                                  labelText: langNotifier.translate('confirm_password'),
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
                                        langNotifier.translate('register'),
                                        style: AppTextStyles.buttonText(isDark: isDark),
                                      ),
                              ),
                              const SizedBox(height: 20),
                              // Link to Login
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Text(
                                  langNotifier.translate('have_account'),
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
