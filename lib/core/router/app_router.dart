import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/dashboard_selection_screen.dart';
import '../../features/auth/presentation/screens/society_registration_screen.dart';
import '../../features/auth/presentation/screens/join_society_screen.dart';
import '../../features/auth/presentation/screens/pending_approval_screen.dart';
import '../../features/resident/presentation/screens/resident_shell.dart';
import '../../features/admin/presentation/screens/admin_shell.dart';
import '../../features/guard/presentation/screens/guard_shell.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const dashboardSelection = '/select-dashboard';
  static const societyRegistration = '/society-registration';
  static const joinSociety = '/join-society';
  static const pendingApproval = '/pending-approval';
  static const residentHome = '/resident';
  static const adminHome = '/admin';
  static const guardHome = '/guard';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (_, _) => _fade(const SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (_, _) => _slide(const OnboardingScreen()),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (_, _) => _slide(const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (_, _) => _slide(const RegisterScreen()),
      ),
      GoRoute(
        path: AppRoutes.dashboardSelection,
        pageBuilder: (_, _) => _slide(const DashboardSelectionScreen()),
      ),
      GoRoute(
        path: AppRoutes.societyRegistration,
        pageBuilder: (_, _) => _slide(const SocietyRegistrationScreen()),
      ),
      GoRoute(
        path: AppRoutes.joinSociety,
        pageBuilder: (_, _) => _slide(const JoinSocietyScreen()),
      ),
      GoRoute(
        path: AppRoutes.pendingApproval,
        pageBuilder: (_, _) => _fade(const PendingApprovalScreen()),
      ),
      GoRoute(
        path: AppRoutes.residentHome,
        pageBuilder: (_, _) => _fade(const ResidentShell()),
      ),
      GoRoute(
        path: AppRoutes.adminHome,
        pageBuilder: (_, _) => _fade(const AdminShell()),
      ),
      GoRoute(
        path: AppRoutes.guardHome,
        pageBuilder: (_, _) => _fade(const GuardShell()),
      ),
    ],
  );
});

CustomTransitionPage _fade(Widget child) => CustomTransitionPage(
  child: child,
  transitionsBuilder: (_, anim, _, c) =>
      FadeTransition(opacity: anim, child: c),
  transitionDuration: const Duration(milliseconds: 250),
);

CustomTransitionPage _slide(Widget child) => CustomTransitionPage(
  child: child,
  transitionsBuilder: (_, anim, _, c) {
    final offset = Tween(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(position: offset, child: c),
    );
  },
  transitionDuration: const Duration(milliseconds: 280),
);
