import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/localization/translation_provider.dart';
import '../../auth/hooks/auth_controller.dart';
import '../hooks/admin_dashboard_controller.dart';
import 'widgets/analytics_charts.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminDashboardControllerProvider);
    final langNotifier = ref.watch(languageProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: ref.watch(languageProvider).isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(langNotifier.translate('admin_dashboard')),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            ),
          ],
        ),
        body: adminState.isLoading || adminState.report == null
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
                          Text(
                            langNotifier.translate('admin_dashboard'),
                            style: AppTextStyles.h2(isDark: isDark),
                          ),
                          const SizedBox(height: 24),
                          // Stats Cards Row
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final columns = constraints.maxWidth > 600 ? 3 : 1;
                              return GridView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  mainAxisExtent: 110,
                                ),
                                children: [
                                  _buildStatCard(
                                    title: langNotifier.translate('citizen_requests'),
                                    value: adminState.report!.totalRequests.toString(),
                                    icon: Icons.analytics_outlined,
                                    color: AppColors.secondary,
                                    isDark: isDark,
                                  ),
                                  _buildStatCard(
                                    title: 'Total Active Gaps',
                                    value: adminState.report!.serviceGapAlerts
                                        .where((g) => g.hasCriticalGap)
                                        .length
                                        .toString(),
                                    icon: Icons.gavel_outlined,
                                    color: AppColors.crisis,
                                    isDark: isDark,
                                  ),
                                  _buildStatCard(
                                    title: 'Monitored Sectors',
                                    value: adminState.report!.serviceGapAlerts.length.toString(),
                                    icon: Icons.map_outlined,
                                    color: AppColors.accent,
                                    isDark: isDark,
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          // Critical Gap Alerts Section
                          Text(
                            langNotifier.translate('gap_alerts'),
                            style: AppTextStyles.h3(isDark: isDark),
                          ),
                          const SizedBox(height: 12),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: adminState.report!.serviceGapAlerts.length,
                            itemBuilder: (context, idx) {
                              final gap = adminState.report!.serviceGapAlerts[idx];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: gap.hasCriticalGap 
                                        ? AppColors.crisis.withOpacity(0.5) 
                                        : AppColors.borderLight,
                                    width: 1.5,
                                  ),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: gap.hasCriticalGap 
                                        ? AppColors.crisis.withOpacity(0.15) 
                                        : AppColors.warning.withOpacity(0.15),
                                    child: Icon(
                                      gap.hasCriticalGap ? Icons.warning : Icons.info_outline,
                                      color: gap.hasCriticalGap ? AppColors.crisis : AppColors.warning,
                                    ),
                                  ),
                                  title: Text(
                                    '${gap.district} • ${gap.category}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    gap.hasCriticalGap
                                        ? '${langNotifier.translate('gap_warning_prefix')}${gap.category} ${langNotifier.translate('gap_warning_suffix')}'
                                        : 'Demand matches supply. Capacity is currently ${gap.activeCapacityStatus}.',
                                  ),
                                  trailing: Chip(
                                    label: Text(
                                      '${gap.searchVolume} Audits',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          // Charts Section
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth;
                              if (width > 750) {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: _buildChartCard(
                                        title: langNotifier.translate('search_volume'),
                                        child: SearchVolumeChart(
                                          data: adminState.report!.searchVolumeByCategory,
                                        ),
                                        isDark: isDark,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildChartCard(
                                        title: langNotifier.translate('demand_vs_capacity'),
                                        child: DemandVsCapacityChart(
                                          demand: adminState.report!.searchVolumeByCategory,
                                          capacity: adminState.report!.serviceDemandByCategory,
                                        ),
                                        isDark: isDark,
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return Column(
                                  children: [
                                    _buildChartCard(
                                      title: langNotifier.translate('search_volume'),
                                      child: SearchVolumeChart(
                                        data: adminState.report!.searchVolumeByCategory,
                                      ),
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildChartCard(
                                      title: langNotifier.translate('demand_vs_capacity'),
                                      child: DemandVsCapacityChart(
                                        demand: adminState.report!.searchVolumeByCategory,
                                        capacity: adminState.report!.serviceDemandByCategory,
                                      ),
                                      isDark: isDark,
                                    ),
                                  ],
                                );
                              }
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required Widget child,
    required bool isDark,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
