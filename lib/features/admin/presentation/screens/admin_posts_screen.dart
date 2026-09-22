import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/data_providers.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/gradient_button.dart';

class AdminPostsScreen extends ConsumerStatefulWidget {
  const AdminPostsScreen({super.key});

  @override
  ConsumerState<AdminPostsScreen> createState() => _AdminPostsScreenState();
}

class _AdminPostsScreenState extends ConsumerState<AdminPostsScreen> {
  final _text = TextEditingController();
  bool _posting = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null || _text.text.trim().isEmpty) return;
    setState(() => _posting = true);
    await ref
        .read(dataServiceProvider)
        .postAnnouncement(user.societyCode, _text.text.trim(), user.name);
    _text.clear();
    setState(() => _posting = false);
    if (mounted) {
      FocusScope.of(context).unfocus();
      showAppSnack(context, 'Notice published');
    }
  }

  @override
  Widget build(BuildContext context) {
    final announcements = ref.watch(announcementsProvider);
    final society = ref.watch(societyCodeProvider);
    final t = Theme.of(context).textTheme;

    return ListView(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 18, 20, 110),
      children: [
        Text('Notices', style: t.displaySmall),
        const SizedBox(height: 18),

        // ── Composer ───────────────────────────────────────────────
        GlassCard(
          borderRadius: 22,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Post a new notice', style: t.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: _text,
                maxLines: 4,
                minLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Write something for your society…',
                ),
              ),
              const SizedBox(height: 14),
              GradientButton(
                label: 'Publish',
                icon: Icons.send_rounded,
                height: 48,
                gradient: AppColors.adminGradient(),
                isLoading: _posting,
                onTap: _post,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SectionHeader('Published'),

        announcements.when(
          loading: () => const Center(
              child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
          error: (e, _) =>
              EmptyState(icon: Icons.wifi_off_rounded, title: 'Could not load', message: '$e'),
          data: (list) => list.isEmpty
              ? const EmptyState(
                  icon: Icons.campaign_outlined, title: 'Nothing published yet', compact: true)
              : Column(
                  children: list
                      .map((a) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GlassCard(
                              borderRadius: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          DateFormat('d MMM yyyy, h:mm a').format(
                                              DateTime.fromMillisecondsSinceEpoch(a.timestamp)),
                                          style: t.bodySmall!.copyWith(fontSize: 11),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          final ok = await showConfirmSheet(
                                            context,
                                            title: 'Delete notice?',
                                            message: 'This cannot be undone.',
                                            confirmLabel: 'Delete',
                                            confirmColor: AppColors.danger,
                                            icon: Icons.delete_outline_rounded,
                                          );
                                          if (ok && context.mounted) {
                                            await ref
                                                .read(dataServiceProvider)
                                                .deleteAnnouncement(society, a.id);
                                          }
                                        },
                                        child: const Icon(Icons.delete_outline_rounded,
                                            size: 19, color: AppColors.danger),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(a.text, style: t.bodyMedium),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ),
        ),
      ],
    );
  }
}
