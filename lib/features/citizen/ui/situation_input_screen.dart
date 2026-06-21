import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/localization/translation_provider.dart';
import '../../../core/widgets/responsible_ai_banner.dart';
import '../../auth/hooks/auth_controller.dart';
import '../domain/entities/situation.dart';
import '../hooks/citizen_flow_controller.dart';
import 'needs_analysis_screen.dart';
import 'crisis_screen.dart';

class SituationInputScreen extends ConsumerStatefulWidget {
  const SituationInputScreen({super.key});

  @override
  ConsumerState<SituationInputScreen> createState() => _SituationInputScreenState();
}

class _SituationInputScreenState extends ConsumerState<SituationInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController(text: 'North District');
  final _householdSizeController = TextEditingController(text: '1');
  final _incomeController = TextEditingController(text: '0');
  String _urgencyLevel = 'medium';

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    _householdSizeController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final situation = Situation(
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
      preferredLanguage: ref.read(languageProvider).locale,
      householdSize: int.tryParse(_householdSizeController.text) ?? 1,
      monthlyIncome: double.tryParse(_incomeController.text) ?? 0.0,
      urgencyLevel: _urgencyLevel,
    );

    // Reset old flow data
    ref.read(citizenFlowControllerProvider.notifier).resetFlow();

    // Trigger analysis
    final navigator = Navigator.of(context);
    
    // Show dynamic overlay loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(color: AppColors.secondary),
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                ref.read(languageProvider.notifier).translate('needs_analysis') + '...',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );

    await ref.read(citizenFlowControllerProvider.notifier).submitSituation(situation);
    
    // Dismiss dialogue
    navigator.pop();

    final flowState = ref.read(citizenFlowControllerProvider);
    if (flowState.isCrisis) {
      navigator.push(
        MaterialPageRoute(builder: (_) => const CrisisScreen()),
      );
    } else if (flowState.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(flowState.errorMessage!),
          backgroundColor: AppColors.crisis,
        ),
      );
    } else {
      navigator.push(
        MaterialPageRoute(builder: (_) => const NeedsAnalysisScreen()),
      );
    }
  }

  void _applyScenario(String desc, double income, int size, String urgency) {
    setState(() {
      _descriptionController.text = desc;
      _incomeController.text = income.toStringAsFixed(0);
      _householdSizeController.text = size.toString();
      _urgencyLevel = urgency;
    });
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: ref.watch(languageProvider).isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(langNotifier.translate('citizen_dashboard')),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            ),
          ],
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
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                langNotifier.translate('describe_situation'),
                                style: AppTextStyles.h3(isDark: isDark),
                              ),
                              const SizedBox(height: 12),
                              // Situation Text Field
                              TextFormField(
                                controller: _descriptionController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText: langNotifier.translate('situation_hint'),
                                  alignLabelWithHint: true,
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return langNotifier.translate('error_empty_fields');
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              // Location and Language Row
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _locationController,
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(Icons.location_on_outlined),
                                        labelText: langNotifier.translate('location'),
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return langNotifier.translate('error_empty_fields');
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Income and Family Size Row
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _incomeController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(Icons.attach_money),
                                        labelText: langNotifier.translate('monthly_income'),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _householdSizeController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(Icons.people_outline),
                                        labelText: langNotifier.translate('household_size'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Urgency Level Dropdown
                              DropdownButtonFormField<String>(
                                value: _urgencyLevel,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.warning_amber_rounded),
                                  labelText: langNotifier.translate('urgency_level'),
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: 'low',
                                    child: Text(langNotifier.translate('urgency_low')),
                                  ),
                                  DropdownMenuItem(
                                    value: 'medium',
                                    child: Text(langNotifier.translate('urgency_medium')),
                                  ),
                                  DropdownMenuItem(
                                    value: 'high',
                                    child: Text(langNotifier.translate('urgency_high')),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _urgencyLevel = val;
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 32),
                              // Submit Button
                              ElevatedButton.icon(
                                onPressed: _submit,
                                icon: const Icon(Icons.auto_awesome),
                                label: Text(
                                  langNotifier.translate('analyze_button'),
                                  style: AppTextStyles.buttonText(isDark: isDark),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Test Personas Panel
                    Text(
                      '📋 Choose Demo Persona Scenarios',
                      style: AppTextStyles.h3(isDark: isDark),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 600;
                        return Flex(
                          direction: isCompact ? Axis.vertical : Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildPersonaCard(
                              title: 'Omar (Eviction Risk)',
                              subtitle: 'Behind on rent, lost job.',
                              desc: 'I lost my job at the warehouse and cannot pay my rent of \$1,200. I received a final warning from my landlord.',
                              income: 400,
                              size: 1,
                              urgency: 'high',
                              color: AppColors.secondary,
                            ),
                            const SizedBox(height: 12, width: 12),
                            _buildPersonaCard(
                              title: 'Sofia (Single Mom)',
                              subtitle: 'Needs food and daycare.',
                              desc: 'I am a single mother of two toddlers looking for a job. I need food assistance and child care help while I look for employment.',
                              income: 1200,
                              size: 3,
                              urgency: 'medium',
                              color: AppColors.accent,
                            ),
                            const SizedBox(height: 12, width: 12),
                            _buildPersonaCard(
                              title: 'Tariq (Student)',
                              subtitle: 'Needs tuition/skills.',
                              desc: 'I am a university student looking for computer training programs, scholarships, and campus food programs.',
                              income: 800,
                              size: 1,
                              urgency: 'low',
                              color: AppColors.info,
                            ),
                          ],
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

  Widget _buildPersonaCard({
    required String title,
    required String subtitle,
    required String desc,
    required double income,
    required int size,
    required String urgency,
    required Color color,
  }) {
    return Expanded(
      flex: MediaQuery.of(context).size.width < 600 ? 0 : 1,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _applyScenario(desc, income, size, urgency),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 8,
                      backgroundColor: color,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
