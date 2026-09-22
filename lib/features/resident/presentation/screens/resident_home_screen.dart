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

class ResidentHomeScreen extends ConsumerWidget {
  const ResidentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final society = ref.watch(societyProvider).value;
    final visitors = ref.watch(visitorsProvider).value ?? [];
    final announcements = ref.watch(announcementsProvider).value ?? [];
    final bookings = ref.watch(bookingsProvider).value ?? [];
    final t = Theme.of(context).textTheme;

    final myFlat = user?.flatNumber ?? '';
    final pending = visitors.where((v) => v.isPending && v.flat == myFlat).toList();
    final myBookings = bookings.where((b) => b.userId == user?.uid).length;
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : (hour < 17 ? 'Good afternoon' : 'Good evening');

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 18, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Greeting row ─────────────────────────────────────
                Row(
                  children: [
                    AvatarCircle(name: user?.name ?? '', imageUrl: user?.profileImageUrl ?? '', size: 48),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(greeting, style: t.bodySmall),
                          Text(user?.name ?? '—',
                              style: GoogleFonts.sora(
                                  fontSize: 20, fontWeight: FontWeight.w700, color: t.bodyLarge!.color)),
                        ],
                      ),
                    ),
                    _SosButton(),
                  ],
                ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.1),
                const SizedBox(height: 18),

                // ── Society hero card ────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.heroGradient(),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDeep.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('YOUR SOCIETY',
                                style: GoogleFonts.manrope(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.4,
                                    color: Colors.white70)),
                            const SizedBox(height: 6),
                            Text(society?.societyName ?? '…',
                                style: GoogleFonts.sora(
                                    fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white)),
                            const SizedBox(height: 4),
                            Text('Flat $myFlat  ·  ${society?.societyCode ?? ''}',
                                style: GoogleFonts.manrope(
                                    fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_city_rounded, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 80.ms, duration: 350.ms).slideY(begin: 0.12),
                const SizedBox(height: 16),

                // ── Stats row ────────────────────────────────────────
                Row(children: [
                  Expanded(
                      child: SizedBox(
                          height: 108,
                          child: StatTile(
                              icon: Icons.emoji_people_rounded,
                              label: 'At the gate',
                              value: pending.length,
                              color: AppColors.warning))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: SizedBox(
                          height: 108,
                          child: StatTile(
                              icon: Icons.campaign_rounded,
                              label: 'Notices',
                              value: announcements.length,
                              color: AppColors.secondary))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: SizedBox(
                          height: 108,
                          child: StatTile(
                              icon: Icons.event_available_rounded,
                              label: 'My bookings',
                              value: myBookings,
                              color: AppColors.primary))),
                ]).animate().fadeIn(delay: 160.ms, duration: 350.ms).slideY(begin: 0.12),
                const SizedBox(height: 22),

                // ── Pending visitor (if any) ─────────────────────────
                if (pending.isNotEmpty) ...[
                  const SectionHeader('Waiting at the gate'),
                  GlassCard(
                    borderRadius: 20,
                    child: Row(
                      children: [
                        const PulsingDot(color: AppColors.warning),
                        const SizedBox(width: 10),
                        AvatarCircle(name: pending.first.name, imageUrl: pending.first.imageUrl, size: 42, color: AppColors.warning),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(pending.first.name, style: t.titleMedium),
                              Text(pending.first.purpose, style: t.bodySmall),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: t.bodySmall!.color),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 22),
                ],

                // ── Quick actions ────────────────────────────────────
                const SectionHeader('Quick actions'),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid.count(
            crossAxisCount: 4,
            mainAxisSpacing: 14,
            crossAxisSpacing: 12,
            childAspectRatio: 0.78,
            children: const [
              _QuickAction(Icons.person_add_alt_1_rounded, 'Pre-approve', AppColors.primary),
              _QuickAction(Icons.report_problem_rounded, 'Complaint', AppColors.secondary),
              _QuickAction(Icons.pool_rounded, 'Amenity', AppColors.sand),
              _QuickAction(Icons.cleaning_services_rounded, 'Daily help', AppColors.adminColor),
              _QuickAction(Icons.directions_car_rounded, 'Car logs', AppColors.guardColor),
              _QuickAction(Icons.storefront_rounded, 'Vendors', AppColors.success),
              _QuickAction(Icons.payments_rounded, 'Payments', AppColors.primaryDeep),
              _QuickAction(Icons.groups_rounded, 'Neighbours', AppColors.danger),
            ],
          ),
        ),

        // ── Latest notice ──────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader('Latest notice'),
                if (announcements.isEmpty)
                  const EmptyState(
                      icon: Icons.campaign_outlined,
                      title: 'No notices yet',
                      message: 'Announcements from your society will appear here.',
                      compact: true)
                else
                  GlassCard(
                    borderRadius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.tintOf(AppColors.secondary),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.campaign_rounded, size: 18, color: AppColors.secondary),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(announcements.first.postedBy, style: t.titleSmall)),
                            Text(
                              DateFormat('d MMM').format(
                                  DateTime.fromMillisecondsSinceEpoch(announcements.first.timestamp)),
                              style: t.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(announcements.first.text,
                            style: t.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends ConsumerWidget {
  const _QuickAction(this.icon, this.label, this.color);

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.tintOf(color, alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Icon(icon, color: color, size: 25),
          ),
          const SizedBox(height: 7),
          Text(label,
              style: t.bodySmall!.copyWith(fontSize: 11, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9));
  }
}

class _SosButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final ok = await showConfirmSheet(
          context,
          title: 'Raise SOS alert?',
          message: 'Society admin and security will be alerted immediately.',
          confirmLabel: 'Send SOS',
          confirmColor: AppColors.danger,
          icon: Icons.sos_rounded,
        );
        if (!ok || !context.mounted) return;
        final user = ref.read(currentUserProvider).value;
        if (user == null) return;
        await ref.read(dataServiceProvider).raiseSos(user.societyCode, {
          'name': user.name,
          'flatNumber': user.flatNumber,
          'phone': user.phone,
        });
        if (context.mounted) showAppSnack(context, 'SOS sent — help is on the way');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: AppColors.dangerGradient(),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: AppColors.danger.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5)),
          ],
        ),
        child: Text('SOS',
            style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
      ),
    );
  }
}
