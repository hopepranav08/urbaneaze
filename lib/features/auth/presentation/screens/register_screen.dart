import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/providers/auth_provider.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../../../../shared/widgets/gradient_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _carCtrl = TextEditingController();
  String _occupancy = 'Owner';
  bool _hasCar = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _carCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(currentUserProvider.notifier).register(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        phone: _phoneCtrl.text.trim(),
        occupancy: _occupancy,
        carNumber: _hasCar ? _carCtrl.text.trim().toUpperCase() : 'NA',
      );
      if (!mounted) return;
      context.go(AppRoutes.dashboardSelection);
    } catch (e) {
      if (!mounted) return;
      _showError(_friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.danger),
    );
  }

  String _friendlyError(String raw) {
    if (raw.contains('email-already-in-use')) return 'This email is already registered.';
    if (raw.contains('weak-password')) return 'Password is too weak. Use 6+ characters.';
    if (raw.contains('network')) return 'No internet connection.';
    return 'Registration failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -60, left: -60,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.secondary.withValues(alpha: isDark ? 0.25 : 0.12),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  IconButton(
                    onPressed: () => context.go(AppRoutes.login),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ).animate().fadeIn(),
                  const SizedBox(height: 40),
                  Text('Create account',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800, letterSpacing: -0.5,
                    ),
                  ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 8),
                  Text('Join your society on UrbanEaze',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ).animate(delay: 150.ms).fadeIn(),
                  const SizedBox(height: 32),
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    borderRadius: 20,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextField(label: 'Full name', controller: _nameCtrl, textInputAction: TextInputAction.next, prefixIcon: Icons.person_outline_rounded,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null),
                          const SizedBox(height: 16),
                          AppTextField(label: 'Email address', controller: _emailCtrl, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, prefixIcon: Icons.mail_outline_rounded,
                            validator: (v) { if (v == null || v.isEmpty) return 'Email is required'; if (!v.contains('@')) return 'Enter a valid email'; return null; }),
                          const SizedBox(height: 16),
                          AppTextField(label: 'Phone number', controller: _phoneCtrl, keyboardType: TextInputType.phone, textInputAction: TextInputAction.next, prefixIcon: Icons.phone_outlined,
                            validator: (v) { if (v == null || v.trim().isEmpty) return 'Phone is required'; if (v.length < 10) return 'Enter a valid phone number'; return null; }),
                          const SizedBox(height: 16),
                          AppTextField(label: 'Password', controller: _passwordCtrl, obscureText: true, textInputAction: TextInputAction.next, prefixIcon: Icons.lock_outline_rounded,
                            validator: (v) { if (v == null || v.isEmpty) return 'Password is required'; if (v.length < 6) return 'Minimum 6 characters'; return null; }),
                          const SizedBox(height: 20),
                          Text('I am a', style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 10),
                          Row(
                            children: ['Owner', 'Tenant'].map((type) {
                              final selected = _occupancy == type;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _occupancy = type),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: EdgeInsets.only(right: type == 'Owner' ? 8 : 0),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: selected ? AppColors.primary.withValues(alpha: 0.15) : (isDark ? AppColors.darkSurfaceHigh : AppColors.lightSurfaceHigh),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: selected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder), width: selected ? 1.5 : 1),
                                    ),
                                    child: Text(type, textAlign: TextAlign.center,
                                      style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                                        color: selected ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('I have a registered car', style: Theme.of(context).textTheme.titleSmall),
                              Switch.adaptive(value: _hasCar, onChanged: (v) => setState(() => _hasCar = v),
                                activeThumbColor: Colors.white, activeTrackColor: AppColors.primary),
                            ],
                          ),
                          if (_hasCar) ...[
                            const SizedBox(height: 12),
                            AppTextField(label: 'Car number', hint: 'MH12AB1234', controller: _carCtrl,
                              textInputAction: TextInputAction.done, prefixIcon: Icons.directions_car_outlined,
                              validator: (v) {
                                if (!_hasCar) return null;
                                if (v == null || v.trim().isEmpty) return 'Car number is required';
                                if (!RegExp(r'^[A-Z]{2}\d{2}[A-Z]{1,2}\d{4}$').hasMatch(v.toUpperCase())) return 'Invalid format (e.g. MH12AB1234)';
                                return null;
                              }),
                          ],
                          const SizedBox(height: 24),
                          GradientButton(label: 'Create Account', onTap: _register, isLoading: _loading),
                        ],
                      ),
                    ),
                  ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go(AppRoutes.login),
                      child: RichText(text: TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(fontFamily: 'Inter', color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, fontSize: 14),
                        children: const [TextSpan(text: 'Sign in', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))],
                      )),
                    ),
                  ).animate(delay: 400.ms).fadeIn(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
