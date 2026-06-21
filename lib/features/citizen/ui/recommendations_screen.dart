import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/localization/translation_provider.dart';
import '../../../core/widgets/responsible_ai_banner.dart';
import '../hooks/citizen_flow_controller.dart';

class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(citizenFlowControllerProvider);
    final langNotifier = ref.watch(languageProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: ref.watch(languageProvider).isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(langNotifier.translate('recommendations_title')),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const ResponsibleAiBanner(),
                    const SizedBox(height: 24),
                    Text(
                      langNotifier.translate('recommendations_title'),
                      style: AppTextStyles.h2(isDark: isDark),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    flowState.recommendations.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40.0),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  children: [
                                    const Icon(Icons.search_off, size: 48, color: Colors.grey),
                                    const SizedBox(height: 16),
                                    Text(
                                      langNotifier.translate('no_services_found'),
                                      style: AppTextStyles.bodyLarge(isDark: isDark),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: flowState.recommendations.length,
                            itemBuilder: (context, idx) {
                              final rec = flowState.recommendations[idx];
                              final matchColor = _getConfidenceColor(rec.confidenceCategory);
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Title + Confidence Percentage
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              rec.serviceName,
                                              style: AppTextStyles.h3(isDark: isDark),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: matchColor.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '${rec.confidenceScore.toStringAsFixed(0)}% Match',
                                              style: TextStyle(
                                                color: matchColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // Category & Distance Tags
                                      Row(
                                        children: [
                                          Chip(
                                            label: Text(
                                              rec.category,
                                              style: const TextStyle(fontSize: 11),
                                            ),
                                            padding: EdgeInsets.zero,
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(Icons.directions_car, size: 14, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${rec.distanceKm} km away',
                                            style: AppTextStyles.bodySmall(isDark: isDark),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      // AI Eligibility / Matches Reasoning Card
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isDark 
                                              ? AppColors.backgroundDark 
                                              : AppColors.backgroundLight,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.auto_awesome, size: 14, color: AppColors.secondary),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'AI Guidance Details',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: AppColors.secondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              rec.reasoning,
                                              style: AppTextStyles.bodyMedium(isDark: isDark),
                                            ),
                                            const SizedBox(height: 8),
                                            // Non-committal eligibility disclaimer
                                            Row(
                                              children: [
                                                const Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    langNotifier.translate('eligibility_statement'),
                                                    style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                                                      fontStyle: FontStyle.italic,
                                                      color: AppColors.warning,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Action Buttons
                                      Row(
                                        children: [
                                          // Phone Contact Action
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () => _showContactDialog(context, rec.serviceName, rec.phone),
                                              icon: const Icon(Icons.phone),
                                              label: Text(
                                                langNotifier.translate('contact_provider'),
                                                style: const TextStyle(fontSize: 13),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // Directions Map Action
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () => _showDirectionsDialog(context, rec.serviceName, rec.address),
                                              icon: const Icon(Icons.map_outlined),
                                              label: Text(
                                                langNotifier.translate('get_directions'),
                                                style: const TextStyle(fontSize: 13),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
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

  Color _getConfidenceColor(String category) {
    switch (category.toLowerCase()) {
      case 'high':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'low':
      default:
        return AppColors.info;
    }
  }

  void _showContactDialog(BuildContext context, String service, String phone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Service Provider'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Program: $service', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.phone, color: AppColors.secondary),
                const SizedBox(width: 12),
                Text(phone, style: const TextStyle(fontSize: 16, letterSpacing: 1.1)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Simulating dial to $phone...')),
              );
            },
            child: const Text('Call Now'),
          ),
        ],
      ),
    );
  }

  void _showDirectionsDialog(BuildContext context, String service, String address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Directions & Map Routing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Routing to: $service', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: AppColors.crisis),
                const SizedBox(width: 12),
                Expanded(child: Text(address)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Mock Map View Rendering', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening maps with navigation...')),
              );
            },
            child: const Text('Open External Maps'),
          ),
        ],
      ),
    );
  }
}
