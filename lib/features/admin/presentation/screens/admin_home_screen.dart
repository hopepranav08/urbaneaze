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

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final society = ref.watch(societyProvider).value;
    final members = ref.watch(membersProvider).value ?? [];
    final visitors = ref.watch(visitorsProvider).value ?? [];
    final complaints = ref.watch(complaintsProvider).value ?? [];
    final joinRequests = ref.watch(joinRequestsProvider).value ?? [];
    final sos = ref.watch(sosAlertsProvider).value ?? [];
    final t = Theme.of(context).textTheme;

    final today = DateTime.now();
    final todayVisitors = visitors.where((v) {
      final d = DateTime.fromMillisecondsSinceEpoch(v.timestamp);
      return DateUtils.isSameDay(d, today);
    }).length;
    final openComplaints =
        complaints.where((c) => c.status.toLowerCase() != 'resolved').length;
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
                  Text('Society overview', style: t.bodySmall),
                  Text(society?.societyName ?? '…',
                      style: GoogleFonts.sora(
                          fontSize: 22, fontWeight: FontWeight.w700, color: t.bodyLarge!.color)),
                ],
              ),
            ),
            const RoleChip('admin'),
          ],
        ).animate().fadeIn(duration: 350.ms),
        const SizedBox(height: 20),

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
                const PulsingDot(color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SOS — ${recentSos.first['name']} (Flat ${recentSos.first['flatNumber']})',
                          style: GoogleFonts.manrope(
                              fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                      Text('Raised ${_ago(recentSos.first['timestamp'])} · ${recentSos.first['phone'] ?? ''}',
                          style: GoogleFonts.manrope(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 1800.ms),
          const SizedBox(height: 16),
        ],

        // ── Stats grid ─────────────────────────────────────────────
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.55,
          children: [
            StatTile(
                icon: Icons.group_rounded,
                label: 'Members',
                value: members.length,
                color: AppColors.adminColor),
            StatTile(
                icon: Icons.emoji_people_rounded,
                label: "Today's visitors",
                value: todayVisitors,
                color: AppColors.guardColor),
            StatTile(
                icon: Icons.report_problem_rounded,
                label: 'Open complaints',
                value: openComplaints,
                color: AppColors.secondary),
            StatTile(
                icon: Icons.how_to_reg_rounded,
                label: 'Join requests',
                value: joinRequests.length,
                color: AppColors.primary),
          ],
        ).animate().fadeIn(delay: 100.ms, duration: 350.ms).slideY(begin: 0.1),
        const SizedBox(height: 24),

        // ── Latest visitor activity ────────────────────────────────
        const SectionHeader('Latest gate activity'),
        if (visitors.isEmpty)
          const EmptyState(icon: Icons.history_rounded, title: 'No visitor logs yet', compact: true)
        else
          ...visitors.take(6).map((v) => Padding(
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
                          color: v.isPending
                              ? AppColors.warning
                              : v.isApproved
                                  ? AppColors.success
                                  : AppColors.danger),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(v.name, style: t.titleMedium),
                            Text('${v.purpose} · Flat ${v.flat}', style: t.bodySmall),
                          ],
                        ),
                      ),
                      Text(
                        DateFormat('h:mm a')
                            .format(DateTime.fromMillisecondsSinceEpoch(v.timestamp)),
                        style: t.bodySmall!.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              )),
        const SizedBox(height: 12),

        // ── Society info ───────────────────────────────────────────
        const SectionHeader('Society'),
        GlassCard(
          borderRadius: 20,
          child: Column(
            children: [
              _InfoRow(Icons.qr_code_2_rounded, 'Society code', society?.societyCode ?? '—'),
              const SizedBox(height: 12),
              _InfoRow(Icons.apartment_rounded, 'Total flats', '${society?.numOfFlats ?? 0}'),
              const SizedBox(height: 12),
              _InfoRow(Icons.pool_rounded, 'Amenities',
                  society?.amenities.isEmpty ?? true ? 'None' : society!.amenities.join(', ')),
              const SizedBox(height: 12),
              _InfoRow(Icons.call_rounded, 'Contact', society?.contactNumber ?? '—'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text('Managed by ${user?.name ?? ''}',
              style: t.bodySmall!.copyWith(fontSize: 11)),
        ),
      ],
    );
  }

  static String _ago(dynamic ts) {
    final ms = (ts ?? 0) as num;
    final diff = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ms.toInt()));
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.adminColor),
        const SizedBox(width: 12),
        Text(label, style: t.bodySmall),
        const Spacer(),
        Flexible(child: Text(value, style: t.titleSmall, textAlign: TextAlign.right)),
      ],
    );
  }
}
