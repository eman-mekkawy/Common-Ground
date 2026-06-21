import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/colors.dart';
import 'core/localization/translation_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/entities/app_user.dart';
import 'features/auth/hooks/auth_controller.dart';
import 'features/auth/ui/login_screen.dart';
import 'features/citizen/ui/situation_input_screen.dart';
import 'features/organization/ui/org_dashboard_screen.dart';
import 'features/admin/ui/admin_dashboard_screen.dart';

void main() {
  // If not using MockData, you would call:
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(
    const ProviderScope(
      child: CommonGroundApp(),
    ),
  );
}

class CommonGroundApp extends ConsumerWidget {
  const CommonGroundApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageState = ref.watch(languageProvider);
    
    return MaterialApp(
      title: 'CommonGround',
      themeMode: ThemeMode.system, // Dynamically tracks system preference (Dark/Light)
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      debugShowCheckedModeBanner: false,
      locale: Locale(languageState.locale),
      supportedLocales: const [
        Locale('en', ''),
        Locale('ar', ''),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    // 1. Loading State
    if (authState.isLoading && authState.user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.secondary),
        ),
      );
    }

    // 2. Unauthenticated state
    if (authState.user == null) {
      return const LoginScreen();
    }

    // 3. Authenticated state -> Route based on user role
    switch (authState.user!.role) {
      case UserRole.citizen:
        return const SituationInputScreen();
      case UserRole.organization:
        return const OrgDashboardScreen();
      case UserRole.admin:
        return const AdminDashboardScreen();
    }
  }
}
