import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/data_providers.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/gradient_button.dart';

class GuardReportsScreen extends ConsumerStatefulWidget {
  const GuardReportsScreen({super.key});

  @override
  ConsumerState<GuardReportsScreen> createState() => _GuardReportsScreenState();
}

class _GuardReportsScreenState extends ConsumerState<GuardReportsScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  String _severity = 'Low';
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null || _title.text.trim().isEmpty) return;
    setState(() => _saving = true);
    await ref.read(dataServiceProvider).addSecurityReport(user.societyCode, {
      'title': _title.text.trim(),
      'description': _description.text.trim(),
      'severity': _severity,
      'watchmanId': user.uid,
      'watchmanName': user.name,
    });
    _title.clear();
    _description.clear();
    setState(() {
      _severity = 'Low';
      _saving = false;
    });
    if (mounted) {
      FocusScope.of(context).unfocus();
      showAppSnack(context, 'Report filed — admin notified');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final reports = ref.watch(securityReportsProvider).value ?? [];

    return ListView(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 18, 20, 110),
      children: [
        Text('Security reports', style: t.displaySmall),
        const SizedBox(height: 18),

        GlassCard(
          borderRadius: 22,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('File a report', style: t.titleMedium),
              const SizedBox(height: 12),
              TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 12),
              TextField(
                  controller: _description,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'What happened?')),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (final (sev, color) in [
                    ('Low', AppColors.success),
                    ('Medium', AppColors.warning),
                    ('High', AppColors.danger),
                  ])
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _severity = sev),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: EdgeInsets.only(right: sev != 'High' ? 10 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: _severity == sev ? AppColors.tintOf(color, alpha: 0.16) : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: _severity == sev
                                    ? color
                                    : Theme.of(context).colorScheme.outline),
                          ),
                          child: Center(
                            child: Text(sev,
                                style: t.titleSmall!.copyWith(
                                    color: _severity == sev ? color : null)),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              GradientButton(
                label: 'Submit report',
                gradient: AppColors.guardGradient(),
                isLoading: _saving,
                onTap: _submit,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SectionHeader('Previous reports'),

        if (reports.isEmpty)
          const EmptyState(icon: Icons.gpp_good_outlined, title: 'No reports filed', compact: true)
        else
          ...reports.map((r) {
            final severity = (r['severity'] ?? 'Low').toString();
            final color = switch (severity) {
              'High' => AppColors.danger,
              'Medium' => AppColors.warning,
              _ => AppColors.success,
            };
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
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
                          DateFormat('d MMM, h:mm a').format(DateTime.fromMillisecondsSinceEpoch(
                              ((r['timestamp'] ?? 0) as num).toInt())),
                          style: t.bodySmall!.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text((r['title'] ?? '').toString(), style: t.titleMedium),
                    const SizedBox(height: 4),
                    Text((r['description'] ?? '').toString(), style: t.bodySmall),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
