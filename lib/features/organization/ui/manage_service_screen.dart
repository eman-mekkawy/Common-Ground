import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/localization/translation_provider.dart';
import '../domain/entities/support_service.dart';
import '../hooks/org_dashboard_controller.dart';

class ManageServiceScreen extends ConsumerStatefulWidget {
  final SupportService? service;

  const ManageServiceScreen({super.key, this.service});

  @override
  ConsumerState<ManageServiceScreen> createState() => _ManageServiceScreenState();
}

class _ManageServiceScreenState extends ConsumerState<ManageServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _rulesController;
  late final TextEditingController _cityController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _websiteController;
  late final TextEditingController _incomeController;
  late final TextEditingController _familySizeController;

  String _category = 'Housing Support';
  String _capacity = 'High';

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    _nameController = TextEditingController(text: s?.serviceName ?? '');
    _descController = TextEditingController(text: s?.description ?? '');
    _rulesController = TextEditingController(text: s?.eligibilityRules ?? '');
    _cityController = TextEditingController(text: s?.city ?? 'North District');
    _addressController = TextEditingController(text: s?.address ?? '');
    _phoneController = TextEditingController(text: s?.phone ?? '');
    _websiteController = TextEditingController(text: s?.website ?? '');
    _incomeController = TextEditingController(text: s != null ? s.incomeThreshold.toStringAsFixed(0) : '0');
    _familySizeController = TextEditingController(text: s != null ? s.minFamilySize.toString() : '1');

    if (s != null) {
      _category = s.category;
      _capacity = s.capacityStatus;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _rulesController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _incomeController.dispose();
    _familySizeController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = SupportService(
      id: widget.service?.id ?? '',
      serviceName: _nameController.text.trim(),
      category: _category,
      description: _descController.text.trim(),
      eligibilityRules: _rulesController.text.trim(),
      languages: widget.service?.languages ?? ['en', 'ar'],
      city: _cityController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      website: _websiteController.text.trim(),
      capacityStatus: _capacity,
      lastUpdated: DateTime.now(),
      incomeThreshold: double.tryParse(_incomeController.text) ?? 0.0,
      minFamilySize: int.tryParse(_familySizeController.text) ?? 1,
      lat: widget.service?.lat ?? 40.7128,
      lng: widget.service?.lng ?? -74.0060,
    );

    final success = await ref.read(orgDashboardControllerProvider.notifier).saveService(updated);
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service saved successfully!'), backgroundColor: AppColors.success),
      );
    } else if (mounted) {
      final err = ref.read(orgDashboardControllerProvider).errorMessage ?? 'Failed to save';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.crisis),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.watch(languageProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.service != null;

    return Directionality(
      textDirection: ref.watch(languageProvider).isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Service Details' : 'Add Support Program'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            isEditing ? 'Update Service Parameters' : 'Register New Community Service',
                            style: AppTextStyles.h2(isDark: isDark),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          // Service Name
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.business_center_outlined),
                              labelText: langNotifier.translate('service_name'),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Name cannot be empty';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Category Dropdown
                          DropdownButtonFormField<String>(
                            value: _category,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.category_outlined),
                              labelText: langNotifier.translate('category'),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Housing Support', child: Text('Housing Support')),
                              DropdownMenuItem(value: 'Food Assistance', child: Text('Food Assistance')),
                              DropdownMenuItem(value: 'Financial Assistance', child: Text('Financial Assistance')),
                              DropdownMenuItem(value: 'Legal Aid', child: Text('Legal Aid')),
                              DropdownMenuItem(value: 'Childcare', child: Text('Childcare')),
                              DropdownMenuItem(value: 'Employment Support', child: Text('Employment Support')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _category = val);
                            },
                          ),
                          const SizedBox(height: 16),
                          // Description
                          TextFormField(
                            controller: _descController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.description_outlined),
                              labelText: langNotifier.translate('description'),
                              alignLabelWithHint: true,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Description required';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Capacity Status Dropdown
                          DropdownButtonFormField<String>(
                            value: _capacity,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.people_outline),
                              labelText: langNotifier.translate('capacity_status'),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'High', child: Text('High Capacity (Available)')),
                              DropdownMenuItem(value: 'Medium', child: Text('Medium Capacity (Waitlist)')),
                              DropdownMenuItem(value: 'Low', child: Text('Low Capacity (Limited)')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _capacity = val);
                            },
                          ),
                          const SizedBox(height: 24),
                          const Text('Eligibility Criteria Limits (Rule Engine)', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          // Income & family size threshold
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _incomeController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.attach_money),
                                    labelText: 'Max Income (\$)',
                                    helperText: '0 for no income cap',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _familySizeController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.people_outline),
                                    labelText: 'Min Family Size',
                                    helperText: '1 for individual fits',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Rules detail text
                          TextFormField(
                            controller: _rulesController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.rule_outlined),
                              labelText: langNotifier.translate('eligibility_rules'),
                              alignLabelWithHint: true,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Rules description required';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          const Text('Location & Contact Details', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          // City and Address
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _cityController,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.location_city_outlined),
                                    labelText: langNotifier.translate('location'),
                                  ),
                                  validator: (val) => val == null || val.trim().isEmpty ? 'City required' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _addressController,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.map_outlined),
                                    labelText: langNotifier.translate('address'),
                                  ),
                                  validator: (val) => val == null || val.trim().isEmpty ? 'Address required' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Phone and Website
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.phone_outlined),
                                    labelText: langNotifier.translate('phone'),
                                  ),
                                  validator: (val) => val == null || val.trim().isEmpty ? 'Phone required' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _websiteController,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.web_outlined),
                                    labelText: langNotifier.translate('website'),
                                  ),
                                  validator: (val) => val == null || val.trim().isEmpty ? 'Website required' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // Save Button
                          ElevatedButton.icon(
                            onPressed: _save,
                            icon: const Icon(Icons.save),
                            label: Text(
                              langNotifier.translate('save_changes'),
                              style: AppTextStyles.buttonText(isDark: isDark),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              padding: const EdgeInsets.symmetric(vertical: 18),
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
      ),
    );
  }
}
