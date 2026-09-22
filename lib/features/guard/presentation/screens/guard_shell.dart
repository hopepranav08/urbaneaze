import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/data_providers.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/profile_view.dart';
import '../../../resident/presentation/screens/resident_shell.dart' show GlassNavBar, NavItem;
import 'guard_home_screen.dart';
import 'guard_entry_screen.dart';
import 'guard_cars_screen.dart';
import 'guard_reports_screen.dart';

class GuardShell extends ConsumerStatefulWidget {
  const GuardShell({super.key});

  @override
  ConsumerState<GuardShell> createState() => _GuardShellState();
}

class _GuardShellState extends ConsumerState<GuardShell> {
  int _tab = 0;

  static const _items = [
    NavItem(Icons.shield_outlined, Icons.shield_rounded, 'Post'),
    NavItem(Icons.person_add_alt_outlined, Icons.person_add_alt_1_rounded, 'Entry'),
    NavItem(Icons.directions_car_outlined, Icons.directions_car_rounded, 'Cars'),
    NavItem(Icons.report_gmailerrorred_outlined, Icons.report_rounded, 'Reports'),
    NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final pending = ref.watch(visitorsProvider).value?.where((v) => v.isPending).length ?? 0;

    return Scaffold(
      extendBody: true,
      body: MeshBackground(
        accent: AppColors.guardColor,
        child: IndexedStack(
          index: _tab,
          children: [
            const GuardHomeScreen(),
            const GuardEntryScreen(),
            const GuardCarsScreen(),
            const GuardReportsScreen(),
            ProfileView(accentGradient: AppColors.guardGradient()),
          ],
        ),
      ),
      bottomNavigationBar: GlassNavBar(
        items: _items,
        current: _tab,
        accent: AppColors.guardColor,
        badges: {0: pending},
        onTap: (i) {
          HapticFeedback.selectionClick();
          setState(() => _tab = i);
        },
      ),
    );
  }
}
