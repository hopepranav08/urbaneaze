import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/data_providers.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/profile_view.dart';
import '../../../resident/presentation/screens/resident_shell.dart' show GlassNavBar, NavItem;
import 'admin_home_screen.dart';
import 'admin_members_screen.dart';
import 'admin_posts_screen.dart';
import 'admin_inbox_screen.dart';

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  int _tab = 0;

  static const _items = [
    NavItem(Icons.space_dashboard_outlined, Icons.space_dashboard_rounded, 'Home'),
    NavItem(Icons.group_outlined, Icons.group_rounded, 'Members'),
    NavItem(Icons.campaign_outlined, Icons.campaign_rounded, 'Notices'),
    NavItem(Icons.inbox_outlined, Icons.inbox_rounded, 'Inbox'),
    NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final joinRequests = ref.watch(joinRequestsProvider).value?.length ?? 0;
    final openComplaints = ref
            .watch(complaintsProvider)
            .value
            ?.where((c) => c.status.toLowerCase() != 'resolved')
            .length ??
        0;

    return Scaffold(
      extendBody: true,
      body: MeshBackground(
        accent: AppColors.adminColor,
        child: IndexedStack(
          index: _tab,
          children: [
            const AdminHomeScreen(),
            const AdminMembersScreen(),
            const AdminPostsScreen(),
            const AdminInboxScreen(),
            ProfileView(accentGradient: AppColors.adminGradient()),
          ],
        ),
      ),
      bottomNavigationBar: GlassNavBar(
        items: _items,
        current: _tab,
        accent: AppColors.adminColor,
        badges: {1: joinRequests, 3: openComplaints},
        onTap: (i) {
          HapticFeedback.selectionClick();
          setState(() => _tab = i);
        },
      ),
    );
  }
}
