import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/services/society_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/providers/auth_provider.dart';

class PendingApprovalScreen extends ConsumerStatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  ConsumerState<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends ConsumerState<PendingApprovalScreen> {
  StreamSubscription<String?>? _roleSub;

  @override
  void initState() {
    super.initState();
    _watchRole();
  }

  @override
  void dispose() {
    _roleSub?.cancel();
    super.dispose();
  }

  void _watchRole() {
    final uid = ref.read(currentUserProvider).value?.uid;
    if (uid == null) return;
    final svc = SocietyService();
    _roleSub = svc.watchUserRole(uid).listen((role) async {
      if (!mounted || role == AppConstants.rolePending) return;
      // Role changed — reload the fresh profile so the app sees the
      // updated role/flat everywhere, then route accordingly.
      final fresh = await ref.read(authServiceProvider).getSessionUser();
      if (fresh != null) {
        ref.read(currentUserProvider.notifier).updateUser(fresh);
        await ref.read(authServiceProvider).updateSession(fresh);
      }
      if (!mounted) return;
      if (role == AppConstants.roleMember || role == AppConstants.roleAdmin) {
        context.go(AppRoutes.residentHome);
      } else if (role == AppConstants.roleWatchman) {
        context.go(AppRoutes.guardHome);
      } else {
        // Request was rejected.
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Your join request was declined. You can try another society.')));
        context.go(AppRoutes.dashboardSelection);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hourglass_top_rounded, color: AppColors.warning, size: 60),
              )
                  .animate(onPlay: (ctrl) => ctrl.repeat(reverse: true))
                  .scale(begin: const Offset(1, 1), end: const Offset(1.08, 1.08), duration: 1200.ms, curve: Curves.easeInOut),

              const SizedBox(height: 32),

              Text('Waiting for Approval',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),

              const SizedBox(height: 12),

              Text(
                'Your request to join the society has been sent.\nYour admin will approve you shortly.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 300.ms).fadeIn(),

              const SizedBox(height: 24),

              if (user?.societyCode.isNotEmpty == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceHigh : AppColors.lightSurfaceHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.tag_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Society: ${user!.societyCode}',
                        style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 14),
                      ),
                    ],
                  ),
                ).animate(delay: 400.ms).fadeIn(),

              const SizedBox(height: 48),

              TextButton(
                onPressed: () async {
                  await ref.read(currentUserProvider.notifier).logout();
                  if (!context.mounted) return;
                  context.go(AppRoutes.login);
                },
                child: Text('Sign out',
                  style: TextStyle(fontFamily: 'Inter', color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
              ).animate(delay: 500.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}
