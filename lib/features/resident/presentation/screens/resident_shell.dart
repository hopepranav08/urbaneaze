import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/data_providers.dart';
import '../../../../shared/widgets/common.dart';
import 'resident_home_screen.dart';
import 'resident_visitors_screen.dart';
import 'resident_bookings_screen.dart';
import 'resident_community_screen.dart';
import 'resident_profile_screen.dart';

class NavItem {
  const NavItem(this.icon, this.activeIcon, this.label);
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class ResidentShell extends ConsumerStatefulWidget {
  const ResidentShell({super.key});

  @override
  ConsumerState<ResidentShell> createState() => _ResidentShellState();
}

class _ResidentShellState extends ConsumerState<ResidentShell> {
  int _tab = 0;

  static const _items = [
    NavItem(Icons.cottage_outlined, Icons.cottage_rounded, 'Home'),
    NavItem(Icons.emoji_people_outlined, Icons.emoji_people_rounded, 'Visitors'),
    NavItem(Icons.event_available_outlined, Icons.event_available_rounded, 'Book'),
    NavItem(Icons.forum_outlined, Icons.forum_rounded, 'Community'),
    NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final myFlat = ref.watch(currentUserProvider).value?.flatNumber ?? '';
    final pendingCount = ref
            .watch(visitorsProvider)
            .value
            ?.where((v) => v.isPending && v.flat == myFlat)
            .length ??
        0;

    return Scaffold(
      extendBody: true,
      body: MeshBackground(
        child: IndexedStack(
          index: _tab,
          children: const [
            ResidentHomeScreen(),
            ResidentVisitorsScreen(),
            ResidentBookingsScreen(),
            ResidentCommunityScreen(),
            ResidentProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: GlassNavBar(
        items: _items,
        current: _tab,
        badges: {1: pendingCount},
        onTap: (i) {
          HapticFeedback.selectionClick();
          setState(() => _tab = i);
        },
      ),
    );
  }
}

/// Floating frosted-glass bottom navigation, shared by all three shells.
class GlassNavBar extends StatelessWidget {
  const GlassNavBar({
    super.key,
    required this.items,
    required this.current,
    required this.onTap,
    this.badges = const {},
    this.accent = AppColors.primary,
  });

  final List<NavItem> items;
  final int current;
  final ValueChanged<int> onTap;
  final Map<int, int> badges;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).padding.bottom + 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: isDark ? AppColors.glassDark : AppColors.glassLight,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
              ),
            ),
            child: Row(
              children: List.generate(items.length, (i) {
                final item = items[i];
                final active = i == current;
                final badge = badges[i] ?? 0;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOut,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                color: active ? AppColors.tintOf(accent, alpha: 0.18) : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                active ? item.activeIcon : item.icon,
                                size: 23,
                                color: active
                                    ? accent
                                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                              ),
                            ),
                            if (badge > 0)
                              Positioned(
                                top: -3,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.danger,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$badge',
                                    style: GoogleFonts.manrope(
                                        fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 220),
                          style: GoogleFonts.manrope(
                            fontSize: active ? 11 : 10.5,
                            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                            color: active
                                ? accent
                                : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                          ),
                          child: Text(item.label),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
