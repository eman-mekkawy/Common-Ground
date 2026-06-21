import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/localization/translation_provider.dart';
import '../hooks/citizen_flow_controller.dart';

class CrisisScreen extends ConsumerWidget {
  const CrisisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(citizenFlowControllerProvider);
    final langNotifier = ref.watch(languageProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final crisisType = flowState.crisisType ?? 'general';
    final hotlineName = _getHotlineName(crisisType, langNotifier);
    final hotlineNumber = _getHotlinePhone(crisisType);

    return Directionality(
      textDirection: ref.watch(languageProvider).isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF1E0B11) : const Color(0xFFFFF1F2),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppColors.primary),
            onPressed: () {
              ref.read(citizenFlowControllerProvider.notifier).resetFlow();
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Warning Icon
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.crisis,
                      size: 80,
                    ),
                    const SizedBox(height: 24),
                    // Header
                    Text(
                      langNotifier.translate('crisis_detected'),
                      style: AppTextStyles.h1(isDark: isDark).copyWith(
                        color: AppColors.crisis,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Message
                    Text(
                      langNotifier.translate('crisis_warning'),
                      style: AppTextStyles.bodyLarge(isDark: isDark).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Specific Crisis Hotline Card
                    Card(
                      elevation: 4,
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      shadowColor: AppColors.crisis.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.crisis, width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              hotlineName,
                              style: AppTextStyles.h2(isDark: isDark).copyWith(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              hotlineNumber,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.crisis,
                                letterSpacing: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Calling $hotlineNumber...')),
                                );
                              },
                              icon: const Icon(Icons.phone_in_talk),
                              label: Text(
                                langNotifier.translate('call_now'),
                                style: AppTextStyles.buttonText(isDark: isDark),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.crisis,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Human counselor card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 28,
                              backgroundColor: AppColors.secondary,
                              child: Icon(Icons.support_agent, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    langNotifier.translate('talk_to_counselor'),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    langNotifier.translate('counselor_available'),
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chat_bubble_outline, color: AppColors.secondary),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Connecting to human chat counselor...')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Reset/Go back button
                    OutlinedButton(
                      onPressed: () {
                        ref.read(citizenFlowControllerProvider.notifier).resetFlow();
                        Navigator.pop(context);
                      },
                      child: const Text('Return to Safety Hub'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getHotlineName(String type, LanguageNotifier lang) {
    switch (type) {
      case 'suicide_risk':
        return 'National Suicide Prevention Lifeline';
      case 'domestic_violence':
        return 'National Domestic Violence Hotline';
      case 'homelessness':
        return 'Homelessness & Housing Crisis Link';
      case 'general':
      default:
        return lang.translate('emergency_hotline');
    }
  }

  String _getHotlinePhone(String type) {
    switch (type) {
      case 'suicide_risk':
        return '988';
      case 'domestic_violence':
        return '1-800-799-7233';
      case 'homelessness':
        return '1-877-424-3838';
      case 'general':
      default:
        return '911';
    }
  }
}
