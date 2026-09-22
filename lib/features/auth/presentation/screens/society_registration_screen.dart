import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/providers/auth_provider.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../../../../shared/widgets/gradient_button.dart';

const _amenityOptions = [
  'Swimming Pool', 'Gym', 'Clubhouse', 'Tennis Court', 'Basketball Court',
  'Badminton Court', 'Jogging Track', 'Yoga Room', 'Kids Play Area',
  'Party Hall', 'Conference Room', 'Library', 'Indoor Games', 'Sauna',
  'Squash Court', 'Cricket Net', 'Skating Rink', 'Amphitheatre',
  'BBQ Area', 'Rooftop Garden',
];

class SocietyRegistrationScreen extends ConsumerStatefulWidget {
  const SocietyRegistrationScreen({super.key});

  @override
  ConsumerState<SocietyRegistrationScreen> createState() => _SocietyRegistrationScreenState();
}

class _SocietyRegistrationScreenState extends ConsumerState<SocietyRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _flatsCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final Set<String> _selectedAmenities = {};
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _addressCtrl.dispose(); _flatsCtrl.dispose();
    _contactCtrl.dispose(); _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAmenities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one amenity'), backgroundColor: AppColors.warning),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final user = ref.read(currentUserProvider).value!;
      final svc = ref.read(societyServiceProvider);
      final code = await svc.registerSociety(
        societyName: _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        numOfFlats: int.parse(_flatsCtrl.text.trim()),
        contactPerson: _contactCtrl.text.trim(),
        contactNumber: _phoneCtrl.text.trim(),
        amenities: _selectedAmenities.toList(),
        admin: user,
      );
      // Refresh the in-memory user so the admin dashboard streams pick up
      // the new role and society code immediately.
      ref.read(currentUserProvider.notifier).updateUser(
            user.copyWith(role: AppConstants.roleAdmin, societyCode: code),
          );
      if (!mounted) return;
      context.go(AppRoutes.adminHome);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              IconButton(
                onPressed: () => context.go(AppRoutes.dashboardSelection),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                padding: EdgeInsets.zero, constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 32),
              Text('Register Society',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
              ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.3, end: 0),
              const SizedBox(height: 8),
              Text('Set up your housing society',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ).animate(delay: 150.ms).fadeIn(),
              const SizedBox(height: 32),
              GlassCard(
                padding: const EdgeInsets.all(20),
                borderRadius: 20,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(label: 'Society name', controller: _nameCtrl, prefixIcon: Icons.apartment_rounded, textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                      const SizedBox(height: 14),
                      AppTextField(label: 'Address', controller: _addressCtrl, prefixIcon: Icons.location_on_outlined, maxLines: 2, textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                      const SizedBox(height: 14),
                      AppTextField(label: 'Number of flats', controller: _flatsCtrl, keyboardType: TextInputType.number, prefixIcon: Icons.domain_rounded, textInputAction: TextInputAction.next,
                        validator: (v) { if (v == null || v.isEmpty) return 'Required'; if (int.tryParse(v) == null) return 'Enter a number'; return null; }),
                      const SizedBox(height: 14),
                      AppTextField(label: 'Contact person name', controller: _contactCtrl, prefixIcon: Icons.person_outline_rounded, textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                      const SizedBox(height: 14),
                      AppTextField(label: 'Contact phone', controller: _phoneCtrl, keyboardType: TextInputType.phone, prefixIcon: Icons.phone_outlined, textInputAction: TextInputAction.done,
                        validator: (v) { if (v == null || v.trim().isEmpty) return 'Required'; if (v.length < 10) return 'Invalid number'; return null; }),
                    ],
                  ),
                ),
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: 20),
              Text('Amenities', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('Select all amenities available in your society',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                )),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _amenityOptions.map((a) {
                  final selected = _selectedAmenities.contains(a);
                  return FilterChip(
                    label: Text(a),
                    selected: selected,
                    onSelected: (v) => setState(() => v ? _selectedAmenities.add(a) : _selectedAmenities.remove(a)),
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontFamily: 'Inter', fontSize: 12, fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                    side: BorderSide(color: selected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                    backgroundColor: isDark ? AppColors.darkSurfaceHigh : AppColors.lightSurfaceHigh,
                  );
                }).toList(),
              ).animate(delay: 300.ms).fadeIn(),
              const SizedBox(height: 32),
              GradientButton(label: 'Register Society', onTap: _submit, isLoading: _loading)
                  .animate(delay: 400.ms).fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
