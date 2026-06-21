import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/localization/translation_provider.dart';
import '../../auth/hooks/auth_controller.dart';
import '../domain/entities/support_service.dart';
import '../hooks/org_dashboard_controller.dart';
import 'manage_service_screen.dart';

class OrgDashboardScreen extends ConsumerWidget {
  const OrgDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgState = ref.watch(orgDashboardControllerProvider);
    final langNotifier = ref.watch(languageProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: ref.watch(languageProvider).isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(langNotifier.translate('org_dashboard')),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            ),
          ],
        ),
        body: orgState.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.secondary))
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1024),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Manage Services',
                                style: AppTextStyles.h2(isDark: isDark),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ManageServiceScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: Text(langNotifier.translate('add_service')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          orgState.services.isEmpty
                              ? Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(48.0),
                                    child: Column(
                                      children: [
                                        const Icon(Icons.business_center_outlined, size: 48, color: Colors.grey),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No services registered yet. Click "Add New Service" to get started.',
                                          style: AppTextStyles.bodyMedium(isDark: isDark),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : LayoutBuilder(
                                  builder: (context, constraints) {
                                    final columns = constraints.maxWidth > 700 ? 2 : 1;
                                    return GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: columns,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        mainAxisExtent: 310,
                                      ),
                                      itemCount: orgState.services.length,
                                      itemBuilder: (context, idx) {
                                        final service = orgState.services[idx];
                                        return _buildServiceCard(context, ref, service, isDark, langNotifier);
                                      },
                                    );
                                  },
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

  Widget _buildServiceCard(
    BuildContext context,
    WidgetRef ref,
    SupportService service,
    bool isDark,
    LanguageNotifier lang,
  ) {
    final capColor = _getCapacityColor(service.capacityStatus);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Category
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    service.serviceName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Chip(
                  label: Text(service.category, style: const TextStyle(fontSize: 10)),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Description
            Expanded(
              child: Text(
                service.description,
                style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            // Capacity dropdown selection
            Row(
              children: [
                const Icon(Icons.people_alt_outlined, size: 16),
                const SizedBox(width: 8),
                const Text('Capacity: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: capColor.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: service.capacityStatus,
                        icon: Icon(Icons.arrow_drop_down, color: capColor),
                        style: TextStyle(color: capColor, fontWeight: FontWeight.bold, fontSize: 13),
                        items: const [
                          DropdownMenuItem(value: 'High', child: Text('High (Available)')),
                          DropdownMenuItem(value: 'Medium', child: Text('Medium (Waitlist)')),
                          DropdownMenuItem(value: 'Low', child: Text('Low (Limited)')),
                        ],
                        onChanged: (newVal) {
                          if (newVal != null) {
                            ref.read(orgDashboardControllerProvider.notifier).updateCapacity(service.id, newVal);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Rules Details summary
            Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Rules: Max income \$${service.incomeThreshold.toStringAsFixed(0)} • Min size ${service.minFamilySize}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Delete Button
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.crisis),
                  onPressed: () => _confirmDelete(context, ref, service.id),
                ),
                const SizedBox(width: 8),
                // Edit Button
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ManageServiceScreen(service: service),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_note, size: 18),
                  label: const Text('Edit Details'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCapacityColor(String cap) {
    switch (cap.toLowerCase()) {
      case 'high':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'low':
      default:
        return AppColors.crisis;
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this service? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(orgDashboardControllerProvider.notifier).delete(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.crisis),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
