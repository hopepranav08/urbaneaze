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

class JoinSocietyScreen extends ConsumerStatefulWidget {
  const JoinSocietyScreen({super.key});

  @override
  ConsumerState<JoinSocietyScreen> createState() => _JoinSocietyScreenState();
}

class _JoinSocietyScreenState extends ConsumerState<JoinSocietyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _flatCtrl = TextEditingController();
  bool _isWatchman = false;
  bool _loading = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _flatCtrl.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = ref.read(currentUserProvider).value!;
      final code = _codeCtrl.text.trim().toUpperCase();
      final flat = _isWatchman ? '' : _flatCtrl.text.trim().toUpperCase();
      await ref.read(societyServiceProvider).joinSociety(
        societyCode: code,
        user: user,
        flatNumber: flat,
        isWatchman: _isWatchman,
      );
      // Keep the in-memory user in sync so the waiting screen shows the
      // right society and the role-watcher uses fresh data.
      ref.read(currentUserProvider.notifier).updateUser(
            user.copyWith(role: 'pending', societyCode: code, flatNumber: flat),
          );
      if (!mounted) return;
      context.go(AppRoutes.pendingApproval);
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
              const SizedBox(height: 40),
              Text('Join Society',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
              ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.3, end: 0),
              const SizedBox(height: 8),
              Text('Enter the society code given by your admin',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ).animate(delay: 150.ms).fadeIn(),
              const SizedBox(height: 40),
              GlassCard(
                padding: const EdgeInsets.all(24),
                borderRadius: 20,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        label: 'Society code',
                        hint: 'e.g. ABC123',
                        controller: _codeCtrl,
                        textInputAction: _isWatchman ? TextInputAction.done : TextInputAction.next,
                        prefixIcon: Icons.tag_rounded,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Society code is required';
                          if (v.trim().length < 4) return 'Invalid code';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('I am a security guard (watchman)', style: Theme.of(context).textTheme.titleSmall),
                          Switch.adaptive(
                            value: _isWatchman,
                            onChanged: (v) => setState(() => _isWatchman = v),
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppColors.guardColor,
                          ),
                        ],
                      ),
                      if (!_isWatchman) ...[
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Flat number',
                          hint: 'e.g. A-101',
                          controller: _flatCtrl,
                          textInputAction: TextInputAction.done,
                          prefixIcon: Icons.door_front_door_outlined,
                          validator: (v) {
                            if (_isWatchman) return null;
                            if (v == null || v.trim().isEmpty) return 'Flat number is required';
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 24),
                      GradientButton(
                        label: 'Request to Join',
                        onTap: _join,
                        isLoading: _loading,
                        gradient: LinearGradient(colors: _isWatchman ? AppColors.guardGradientColors : AppColors.heroGradientColors),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
