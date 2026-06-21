import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/localization/translation_provider.dart';
import '../hooks/citizen_flow_controller.dart';
import 'recommendations_screen.dart';

class NeedsAnalysisScreen extends ConsumerWidget {
  const NeedsAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(citizenFlowControllerProvider);
    final langNotifier = ref.watch(languageProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: ref.watch(languageProvider).isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(langNotifier.translate('needs_analysis')),
        ),
        body: flowState.detectedNeeds.isEmpty
            ? Center(
                child: Text(
                  langNotifier.translate('no_services_found'),
                  style: AppTextStyles.bodyLarge(isDark: isDark),
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            langNotifier.translate('needs_analysis'),
                            style: AppTextStyles.h2(isDark: isDark),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We analyzed your description and inferred the following support categories:',
                            style: AppTextStyles.bodyMedium(isDark: isDark),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          // List of detected needs
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: flowState.detectedNeeds.length,
                            itemBuilder: (context, idx) {
                              final need = flowState.detectedNeeds[idx];
                              final priorityColor = _getPriorityColor(need.priority);
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Need Category Title
                                          Expanded(
                                            child: Text(
                                              need.category,
                                              style: AppTextStyles.h3(isDark: isDark).copyWith(
                                                color: isDark ? AppColors.secondaryLight : AppColors.primary,
                                              ),
                                            ),
                                          ),
                                          // Priority Chip
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: priorityColor.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(color: priorityColor, width: 1.5),
                                            ),
                                            child: Text(
                                              need.priority.toUpperCase(),
                                              style: AppTextStyles.badgeText().copyWith(
                                                color: priorityColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Confidence Bar
                                      Row(
                                        children: [
                                          Text(
                                            '${langNotifier.translate('confidence')}: ',
                                            style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: LinearProgressIndicator(
                                              value: need.confidence,
                                              backgroundColor: isDark ? AppColors.borderDark : AppColors.borderLight,
                                              color: AppColors.secondary,
                                              minHeight: 8,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            '${(need.confidence * 100).toStringAsFixed(0)}%',
                                            style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.secondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      // Why Detected Reasoning
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isDark 
                                              ? AppColors.backgroundDark 
                                              : AppColors.backgroundLight,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              langNotifier.translate('why_detected'),
                                              style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              need.reasoning,
                                              style: AppTextStyles.bodyMedium(isDark: isDark),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          // View Matches Button
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RecommendationsScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.arrow_forward),
                            label: Text(
                              langNotifier.translate('view_matches'),
                              style: AppTextStyles.buttonText(isDark: isDark),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.crisis;
      case 'medium':
        return AppColors.warning;
      case 'low':
      default:
        return AppColors.success;
    }
  }
}
