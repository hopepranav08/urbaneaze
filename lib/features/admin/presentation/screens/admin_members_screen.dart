import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/data_providers.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/gradient_button.dart';

class AdminMembersScreen extends ConsumerStatefulWidget {
  const AdminMembersScreen({super.key});

  @override
  ConsumerState<AdminMembersScreen> createState() => _AdminMembersScreenState();
}

class _AdminMembersScreenState extends ConsumerState<AdminMembersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requests = ref.watch(joinRequestsProvider).value ?? [];

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 18, 20, 8),
          child: Row(
            children: [
              Expanded(child: Text('Members', style: Theme.of(context).textTheme.displaySmall)),
            ],
          ),
        ),
        TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: requests.isEmpty ? 'Requests' : 'Requests (${requests.length})'),
            const Tab(text: 'All members'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: const [_RequestsTab(), _MembersTab()],
          ),
        ),
      ],
    );
  }
}

class _RequestsTab extends ConsumerWidget {
  const _RequestsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(joinRequestsProvider);
    final society = ref.watch(societyCodeProvider);
    final t = Theme.of(context).textTheme;

    return requests.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyState(icon: Icons.wifi_off_rounded, title: 'Could not load', message: '$e'),
      data: (list) => list.isEmpty
          ? const EmptyState(
              icon: Icons.how_to_reg_outlined,
              title: 'No pending requests',
              message: 'New residents and guards who request to join appear here.')
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final req = list[i];
                final name = (req['userName'] ?? '').toString();
                final role = (req['role'] ?? 'member').toString();
                final flat = (req['flatNumber'] ?? '').toString();
                return GlassCard(
                  borderRadius: 22,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          AvatarCircle(name: name, size: 48, color: AppColors.adminColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: t.titleLarge),
                                Text(flat.isEmpty ? 'Security guard' : 'Flat $flat',
                                    style: t.bodySmall),
                              ],
                            ),
                          ),
                          RoleChip(role),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: GradientButton(
                              label: 'Reject',
                              height: 44,
                              borderRadius: 14,
                              gradient: AppColors.dangerGradient(),
                              onTap: () async {
                                HapticFeedback.mediumImpact();
                                await ref.read(dataServiceProvider).rejectJoinRequest(req);
                                if (context.mounted) showAppSnack(context, '$name rejected', error: true);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GradientButton(
                              label: 'Approve',
                              height: 44,
                              borderRadius: 14,
                              gradient: AppColors.approveGradient(),
                              onTap: () async {
                                HapticFeedback.mediumImpact();
                                await ref.read(dataServiceProvider).approveJoinRequest(society, req);
                                if (context.mounted) showAppSnack(context, '$name approved');
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: (i * 60).ms).slideY(begin: 0.1);
              },
            ),
    );
  }
}

class _MembersTab extends ConsumerStatefulWidget {
  const _MembersTab();

  @override
  ConsumerState<_MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends ConsumerState<_MembersTab> {
  String _query = '';
  String _roleFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final members = ref.watch(membersProvider);
    final society = ref.watch(societyCodeProvider);
    final t = Theme.of(context).textTheme;

    return members.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyState(icon: Icons.wifi_off_rounded, title: 'Could not load', message: '$e'),
      data: (list) {
        var filtered = list.where((m) {
          final name = (m['username'] ?? '').toString().toLowerCase();
          final flat = (m['flatNumber'] ?? '').toString().toLowerCase();
          final role = (m['role'] ?? '').toString();
          final matchesQuery =
              _query.isEmpty || name.contains(_query) || flat.contains(_query);
          final matchesRole = _roleFilter == 'all' || role == _roleFilter;
          return matchesQuery && matchesRole;
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: TextField(
                onChanged: (v) => setState(() => _query = v.toLowerCase()),
                decoration: const InputDecoration(
                  hintText: 'Search name or flat…',
                  prefixIcon: Icon(Icons.search_rounded, size: 20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  for (final (value, label) in [
                    ('all', 'All'),
                    ('member', 'Residents'),
                    ('watchman', 'Guards'),
                    ('admin', 'Admins'),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: _roleFilter == value,
                        showCheckmark: false,
                        onSelected: (_) => setState(() => _roleFilter = value),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const EmptyState(icon: Icons.person_search_rounded, title: 'No matches')
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final m = filtered[i];
                        final name = (m['username'] ?? '').toString();
                        final flat = (m['flatNumber'] ?? '').toString();
                        final role = (m['role'] ?? 'member').toString();
                        return GlassCard(
                          borderRadius: 18,
                          padding: const EdgeInsets.all(13),
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
                              if (role != 'admin')
                                IconButton(
                                  icon: const Icon(Icons.person_remove_outlined,
                                      size: 19, color: AppColors.danger),
                                  onPressed: () async {
                                    final ok = await showConfirmSheet(
                                      context,
                                      title: 'Remove $name?',
                                      message: 'They will lose access to this society.',
                                      confirmLabel: 'Remove',
                                      confirmColor: AppColors.danger,
                                      icon: Icons.person_remove_rounded,
                                    );
                                    if (ok && context.mounted) {
                                      await ref
                                          .read(dataServiceProvider)
                                          .removeMember(society, m['id'] as String);
                                    }
                                  },
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
