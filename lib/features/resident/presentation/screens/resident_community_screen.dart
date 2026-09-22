import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/announcement_model.dart';
import '../../../../shared/models/complaint_model.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/data_providers.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/status_badge.dart';

class ResidentCommunityScreen extends ConsumerStatefulWidget {
  const ResidentCommunityScreen({super.key});

  @override
  ConsumerState<ResidentCommunityScreen> createState() => _ResidentCommunityScreenState();
}

class _ResidentCommunityScreenState extends ConsumerState<ResidentCommunityScreen>
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
              Expanded(child: Text('Community', style: Theme.of(context).textTheme.displaySmall)),
            ],
          ),
        ),
        TabBar(
          controller: _tabs,
          tabs: const [Tab(text: 'Notices'), Tab(text: 'Complaints'), Tab(text: 'Neighbours')],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: const [_NoticesTab(), _ComplaintsTab(), _NeighboursTab()],
          ),
        ),
      ],
    );
  }
}

// ─── Notices ───────────────────────────────────────────────────────────
class _NoticesTab extends ConsumerWidget {
  const _NoticesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcements = ref.watch(announcementsProvider);
    return announcements.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyState(icon: Icons.wifi_off_rounded, title: 'Could not load', message: '$e'),
      data: (list) => list.isEmpty
          ? const EmptyState(
              icon: Icons.campaign_outlined,
              title: 'No notices yet',
              message: 'Society announcements will appear here.')
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) =>
                  _NoticeCard(a: list[i]).animate().fadeIn(delay: (i * 50).ms).slideY(begin: 0.08),
            ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.a});

  final AnnouncementModel a;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return GlassCard(
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarCircle(name: a.postedBy, size: 38, color: AppColors.secondary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.postedBy.isEmpty ? 'Society Admin' : a.postedBy, style: t.titleSmall),
                    Text(
                      DateFormat('d MMM yyyy, h:mm a')
                          .format(DateTime.fromMillisecondsSinceEpoch(a.timestamp)),
                      style: t.bodySmall!.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const RoleChip('admin'),
            ],
          ),
          const SizedBox(height: 12),
          Text(a.text, style: t.bodyMedium),
          if (a.isImage) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: a.fileUrl,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                    height: 180, color: Theme.of(context).colorScheme.surfaceContainerHighest),
                errorWidget: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ],
          if (a.isPdf) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => launchUrl(Uri.parse(a.fileUrl), mode: LaunchMode.externalApplication),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.tintOf(AppColors.danger, alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf_rounded, color: AppColors.danger, size: 22),
                    const SizedBox(width: 10),
                    Expanded(child: Text('View attachment', style: t.titleSmall)),
                    Icon(Icons.open_in_new_rounded, size: 16, color: t.bodySmall!.color),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Complaints ────────────────────────────────────────────────────────
class _ComplaintsTab extends ConsumerWidget {
  const _ComplaintsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final complaints = ref.watch(complaintsProvider);

    return Stack(
      children: [
        complaints.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => EmptyState(icon: Icons.wifi_off_rounded, title: 'Could not load', message: '$e'),
          data: (list) {
            final mine = list.where((c) => c.flatNumber == user?.flatNumber).toList();
            if (mine.isEmpty) {
              return const EmptyState(
                  icon: Icons.task_alt_rounded,
                  title: 'No complaints',
                  message: 'Something needs fixing? File a complaint and track it here.');
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 170),
              itemCount: mine.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _ComplaintCard(c: mine[i]),
            );
          },
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 104,
          child: GradientButton(
            label: 'File a complaint',
            icon: Icons.add_rounded,
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const _FileComplaintSheet(),
            ),
          ),
        ),
      ],
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  const _ComplaintCard({required this.c});

  final ComplaintModel c;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
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
                    style: t.bodySmall!.copyWith(fontSize: 11, fontWeight: FontWeight.w800)),
              ),
              const Spacer(),
              StatusBadge(resolved ? BadgeStatus.approved : BadgeStatus.pending, compact: true),
            ],
          ),
          const SizedBox(height: 10),
          Text(c.title, style: t.titleMedium),
          const SizedBox(height: 4),
          Text(c.message, style: t.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Text(
            DateFormat('d MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(c.timestamp)),
            style: t.bodySmall!.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _FileComplaintSheet extends ConsumerStatefulWidget {
  const _FileComplaintSheet();

  @override
  ConsumerState<_FileComplaintSheet> createState() => _FileComplaintSheetState();
}

class _FileComplaintSheetState extends ConsumerState<_FileComplaintSheet> {
  final _title = TextEditingController();
  final _message = TextEditingController();
  String _category = 'Maintenance';
  bool _saving = false;

  static const _categories = ['Maintenance', 'Plumbing', 'Electrical', 'Security', 'Cleanliness', 'Other'];

  @override
  void dispose() {
    _title.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null || _title.text.trim().isEmpty) return;
    setState(() => _saving = true);
    await ref.read(dataServiceProvider).fileComplaint(
          user.societyCode,
          ComplaintModel(
            id: '',
            title: _title.text.trim(),
            message: _message.text.trim(),
            name: user.name,
            flatNumber: user.flatNumber,
            category: _category,
            timestamp: 0,
          ),
        );
    if (mounted) {
      Navigator.pop(context);
      showAppSnack(context, 'Complaint filed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.tintOf(AppColors.primary, alpha: 0.4),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            Text('File a complaint', style: t.headlineSmall),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((c) {
                final selected = _category == c;
                return ChoiceChip(
                  label: Text(c),
                  selected: selected,
                  onSelected: (_) => setState(() => _category = c),
                  showCheckmark: false,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 12),
            TextField(
                controller: _message,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Describe the issue')),
            const SizedBox(height: 20),
            GradientButton(label: 'Submit complaint', isLoading: _saving, onTap: _submit),
          ],
        ),
      ),
    );
  }
}

// ─── Neighbours ────────────────────────────────────────────────────────
class _NeighboursTab extends ConsumerWidget {
  const _NeighboursTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(membersProvider);
    final t = Theme.of(context).textTheme;

    return members.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyState(icon: Icons.wifi_off_rounded, title: 'Could not load', message: '$e'),
      data: (list) => list.isEmpty
          ? const EmptyState(icon: Icons.groups_outlined, title: 'No members yet')
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final m = list[i];
                final name = (m['username'] ?? '').toString();
                final flat = (m['flatNumber'] ?? '').toString();
                final role = (m['role'] ?? 'member').toString();
                return GlassCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      AvatarCircle(name: name, size: 42),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: t.titleMedium),
                            if (flat.isNotEmpty) Text('Flat $flat', style: t.bodySmall),
                          ],
                        ),
                      ),
                      RoleChip(role),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
