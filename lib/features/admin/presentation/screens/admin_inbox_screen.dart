import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/data_providers.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/status_badge.dart';

class AdminInboxScreen extends ConsumerStatefulWidget {
  const AdminInboxScreen({super.key});

  @override
  ConsumerState<AdminInboxScreen> createState() => _AdminInboxScreenState();
}

class _AdminInboxScreenState extends ConsumerState<AdminInboxScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 18, 20, 8),
          child: Row(
            children: [
              Expanded(child: Text('Inbox', style: Theme.of(context).textTheme.displaySmall)),
            ],
          ),
        ),
        TabBar(
          controller: _tabs,
          tabs: const [Tab(text: 'Complaints'), Tab(text: 'Security'), Tab(text: 'SOS')],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: const [_ComplaintsInbox(), _SecurityReports(), _SosHistory()],
          ),
        ),
      ],
    );
  }
}

class _ComplaintsInbox extends ConsumerWidget {
  const _ComplaintsInbox();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complaints = ref.watch(complaintsProvider);
    final society = ref.watch(societyCodeProvider);
    final t = Theme.of(context).textTheme;

    return complaints.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyState(icon: Icons.wifi_off_rounded, title: 'Could not load', message: '$e'),
      data: (list) => list.isEmpty
          ? const EmptyState(
              icon: Icons.task_alt_rounded,
              title: 'Inbox zero',
              message: 'Resident complaints will land here.')
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final c = list[i];
                final resolved = c.status.toLowerCase() == 'resolved';
                return GlassCard(
                  borderRadius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.tintOf(AppColors.sand, alpha: 0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(c.category,
                                style: t.bodySmall!
                                    .copyWith(fontSize: 11, fontWeight: FontWeight.w800)),
                          ),
                          const Spacer(),
                          StatusBadge(resolved ? BadgeStatus.approved : BadgeStatus.pending,
                              compact: true),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(c.title, style: t.titleMedium),
                      const SizedBox(height: 4),
                      Text(c.message, style: t.bodySmall),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${c.name} · Flat ${c.flatNumber} · ${DateFormat('d MMM').format(DateTime.fromMillisecondsSinceEpoch(c.timestamp))}',
                              style: t.bodySmall!.copyWith(fontSize: 11),
                            ),
                          ),
                          if (!resolved)
                            TextButton.icon(
                              onPressed: () async {
                                await ref
                                    .read(dataServiceProvider)
                                    .setComplaintStatus(society, c.id, 'Resolved');
                                if (context.mounted) showAppSnack(context, 'Marked resolved');
                              },
                              icon: const Icon(Icons.check_circle_outline_rounded, size: 17),
                              label: const Text('Resolve'),
                              style: TextButton.styleFrom(foregroundColor: AppColors.success),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _SecurityReports extends ConsumerWidget {
  const _SecurityReports();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(securityReportsProvider);
    final t = Theme.of(context).textTheme;

    return reports.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyState(icon: Icons.wifi_off_rounded, title: 'Could not load', message: '$e'),
      data: (list) => list.isEmpty
          ? const EmptyState(
              icon: Icons.gpp_good_outlined,
              title: 'No security reports',
              message: 'Reports filed by guards appear here.')
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final r = list[i];
                final severity = (r['severity'] ?? 'Low').toString();
                final color = switch (severity) {
                  'High' => AppColors.danger,
                  'Medium' => AppColors.warning,
                  _ => AppColors.success,
                };
                return GlassCard(
                  borderRadius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.tintOf(color),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: color.withValues(alpha: 0.3)),
                            ),
                            child: Text(severity,
                                style: t.bodySmall!.copyWith(
                                    fontSize: 11, fontWeight: FontWeight.w800, color: color)),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat('d MMM, h:mm a').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    ((r['timestamp'] ?? 0) as num).toInt())),
                            style: t.bodySmall!.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text((r['title'] ?? '').toString(), style: t.titleMedium),
                      const SizedBox(height: 4),
                      Text((r['description'] ?? '').toString(), style: t.bodySmall),
                      const SizedBox(height: 8),
                      Text('Filed by ${r['watchmanName'] ?? 'Guard'}',
                          style: t.bodySmall!.copyWith(fontSize: 11)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _SosHistory extends ConsumerWidget {
  const _SosHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sos = ref.watch(sosAlertsProvider);
    final t = Theme.of(context).textTheme;

    return sos.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyState(icon: Icons.wifi_off_rounded, title: 'Could not load', message: '$e'),
      data: (list) => list.isEmpty
          ? const EmptyState(
              icon: Icons.health_and_safety_outlined,
              title: 'No SOS alerts',
              message: 'Emergency alerts raised by residents appear here.')
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final s = list[i];
                return GlassCard(
                  borderRadius: 20,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.tintOf(AppColors.danger),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.sos_rounded, color: AppColors.danger, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${s['name']} · Flat ${s['flatNumber']}', style: t.titleMedium),
                            Text((s['phone'] ?? '').toString(), style: t.bodySmall),
                          ],
                        ),
                      ),
                      Text(
                        DateFormat('d MMM\nh:mm a').format(DateTime.fromMillisecondsSinceEpoch(
                            ((s['timestamp'] ?? 0) as num).toInt())),
                        style: t.bodySmall!.copyWith(fontSize: 11),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
