import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/data_providers.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/status_badge.dart';

class GuardHomeScreen extends ConsumerWidget {
  const GuardHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final society = ref.watch(societyProvider).value;
    final visitors = ref.watch(visitorsProvider).value ?? [];
    final carLogs = ref.watch(carLogsProvider).value ?? [];
    final sos = ref.watch(sosAlertsProvider).value ?? [];
    final t = Theme.of(context).textTheme;

    final today = DateTime.now();
    bool isToday(num ts) =>
        DateUtils.isSameDay(DateTime.fromMillisecondsSinceEpoch(ts.toInt()), today);

    final todayVisitors = visitors.where((v) => isToday(v.timestamp)).toList();
    final pending = visitors.where((v) => v.isPending).toList();
    final todayCars = carLogs.where((c) => isToday((c['timestamp'] ?? 0) as num)).length;
    final recentSos = sos.where((s) {
      final ts = (s['timestamp'] ?? 0) as num;
      return DateTime.now().millisecondsSinceEpoch - ts < 24 * 3600 * 1000;
    }).toList();

    return ListView(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 18, 20, 110),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('On duty', style: t.bodySmall),
                  Text(user?.name ?? '…',
                      style: GoogleFonts.sora(
                          fontSize: 22, fontWeight: FontWeight.w700, color: t.bodyLarge!.color)),
                ],
              ),
            ),
            const PulsingDot(),
            const SizedBox(width: 6),
            Text('Live', style: t.bodySmall!.copyWith(color: AppColors.success)),
          ],
        ).animate().fadeIn(duration: 350.ms),
        const SizedBox(height: 6),
        Text(society?.societyName ?? '', style: t.bodySmall),
        const SizedBox(height: 18),

        // ── SOS banner ─────────────────────────────────────────────
        if (recentSos.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.dangerGradient(),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.sos_rounded, color: Colors.white, size: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'SOS from ${recentSos.first['name']} — Flat ${recentSos.first['flatNumber']}',
                    style: GoogleFonts.manrope(
                        fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ],
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 1500.ms),
          const SizedBox(height: 16),
        ],

        // ── Today stats ────────────────────────────────────────────
        Row(children: [
          Expanded(
              child: SizedBox(
                  height: 104,
                  child: StatTile(
                      icon: Icons.emoji_people_rounded,
                      label: 'Visitors today',
                      value: todayVisitors.length,
                      color: AppColors.guardColor))),
          const SizedBox(width: 12),
          Expanded(
              child: SizedBox(
                  height: 104,
                  child: StatTile(
                      icon: Icons.hourglass_top_rounded,
                      label: 'Awaiting approval',
                      value: pending.length,
                      color: AppColors.warning))),
          const SizedBox(width: 12),
          Expanded(
              child: SizedBox(
                  height: 104,
                  child: StatTile(
                      icon: Icons.directions_car_rounded,
                      label: 'Cars today',
                      value: todayCars,
                      color: AppColors.primary))),
        ]).animate().fadeIn(delay: 80.ms, duration: 350.ms).slideY(begin: 0.1),
        const SizedBox(height: 24),

        // ── Live approval monitor ──────────────────────────────────
        const SectionHeader('Waiting for resident approval'),
        if (pending.isEmpty)
          const EmptyState(
              icon: Icons.verified_user_outlined,
              title: 'No one waiting',
              message: 'Visitors you log will appear here until the resident responds.',
              compact: true)
        else
          ...pending.map((v) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(13),
                  child: Row(
                    children: [
                      const PulsingDot(color: AppColors.warning),
                      const SizedBox(width: 10),
                      AvatarCircle(name: v.name, imageUrl: v.imageUrl, size: 40, color: AppColors.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(v.name, style: t.titleMedium),
                            Text('Flat ${v.flat} · ${v.purpose}', style: t.bodySmall),
                          ],
                        ),
                      ),
                      const StatusBadge(BadgeStatus.pending, compact: true),
                    ],
                  ),
                ),
              )),
        const SizedBox(height: 14),

        // ── Today's log ────────────────────────────────────────────
        const SectionHeader("Today's entries"),
        if (todayVisitors.isEmpty)
          const EmptyState(icon: Icons.history_rounded, title: 'No entries yet today', compact: true)
        else
          ...todayVisitors.take(10).map((v) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(13),
                  child: Row(
                    children: [
                      AvatarCircle(
                          name: v.name,
                          imageUrl: v.imageUrl,
                          size: 40,
                          color: v.isApproved
                              ? AppColors.success
                              : v.isPending
                                  ? AppColors.warning
                                  : AppColors.danger),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(v.name, style: t.titleMedium),
                            Text(
                                'Flat ${v.flat} · ${DateFormat('h:mm a').format(DateTime.fromMillisecondsSinceEpoch(v.timestamp))}',
                                style: t.bodySmall),
                          ],
                        ),
                      ),
                      StatusBadge(StatusBadge.fromString(v.status), compact: true),
                    ],
                  ),
                ),
              )),
      ],
    );
  }
}
