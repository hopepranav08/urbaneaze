import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/visitor_model.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/data_providers.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/status_badge.dart';

class ResidentVisitorsScreen extends ConsumerStatefulWidget {
  const ResidentVisitorsScreen({super.key});

  @override
  ConsumerState<ResidentVisitorsScreen> createState() => _ResidentVisitorsScreenState();
}

class _ResidentVisitorsScreenState extends ConsumerState<ResidentVisitorsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final visitors = ref.watch(visitorsProvider);
    final preApprovals = ref.watch(preApprovalsProvider).value ?? [];
    final myFlat = user?.flatNumber ?? '';

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 18, 20, 8),
          child: Row(
            children: [
              Expanded(child: Text('Visitors', style: Theme.of(context).textTheme.displaySmall)),
              GestureDetector(
                onTap: () => _openPreApproveSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: AppColors.heroGradient(),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(children: [
                    const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text('Pre-approve',
                        style: GoogleFonts.manrope(
                            fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                  ]),
                ),
              ),
            ],
          ),
        ),
        TabBar(
          controller: _tabs,
          tabs: const [Tab(text: 'At the gate'), Tab(text: 'Pre-approved'), Tab(text: 'History')],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              // ── Pending ─────────────────────────────────────────────
              visitors.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => EmptyState(icon: Icons.wifi_off_rounded, title: 'Could not load', message: '$e'),
                data: (list) {
                  final pending = list.where((v) => v.isPending && v.flat == myFlat).toList();
                  if (pending.isEmpty) {
                    return const EmptyState(
                        icon: Icons.verified_user_outlined,
                        title: 'All clear',
                        message: 'No one is waiting for your approval.');
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
                    itemCount: pending.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _PendingCard(visitor: pending[i])
                        .animate()
                        .fadeIn(delay: (i * 60).ms)
                        .slideY(begin: 0.1),
                  );
                },
              ),
              // ── Pre-approved ────────────────────────────────────────
              preApprovals.isEmpty
                  ? const EmptyState(
                      icon: Icons.qr_code_2_rounded,
                      title: 'No pre-approvals',
                      message: 'Expecting a guest, delivery or cab?\nPre-approve them with a gate pass OTP.')
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
                      itemCount: preApprovals.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _PreApprovalCard(item: preApprovals[i]),
                    ),
              // ── History ─────────────────────────────────────────────
              visitors.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => EmptyState(icon: Icons.wifi_off_rounded, title: 'Could not load', message: '$e'),
                data: (list) {
                  final history = list.where((v) => v.flat == myFlat && !v.isPending).toList();
                  if (history.isEmpty) {
                    return const EmptyState(
                        icon: Icons.history_rounded, title: 'No visitor history yet');
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
                    itemCount: history.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _HistoryTile(visitor: history[i]),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openPreApproveSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _PreApproveSheet(),
    );
  }
}

class _PendingCard extends ConsumerWidget {
  const _PendingCard({required this.visitor});

  final VisitorModel visitor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final user = ref.watch(currentUserProvider).value;

    Future<void> act(String status) async {
      HapticFeedback.mediumImpact();
      await ref.read(dataServiceProvider).setVisitorStatus(
          user?.societyCode ?? '', visitor.id, status, user?.uid ?? '');
      if (context.mounted) {
        showAppSnack(context,
            status == AppConstants.statusApproved ? '${visitor.name} approved' : '${visitor.name} denied',
            error: status == AppConstants.statusDenied);
      }
    }

    return GlassCard(
      borderRadius: 22,
      child: Column(
        children: [
          Row(
            children: [
              AvatarCircle(name: visitor.name, imageUrl: visitor.imageUrl, size: 52, color: AppColors.warning),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(visitor.name, style: t.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      '${visitor.purpose}${visitor.hasCar ? '  ·  ${visitor.carNumber}' : ''}',
                      style: t.bodySmall,
                    ),
                    Text(
                      DateFormat('h:mm a').format(DateTime.fromMillisecondsSinceEpoch(visitor.timestamp)),
                      style: t.bodySmall!.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const PulsingDot(color: AppColors.warning),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  label: 'Deny',
                  height: 46,
                  borderRadius: 14,
                  gradient: AppColors.dangerGradient(),
                  icon: Icons.close_rounded,
                  onTap: () => act(AppConstants.statusDenied),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GradientButton(
                  label: 'Approve',
                  height: 46,
                  borderRadius: 14,
                  gradient: AppColors.approveGradient(),
                  icon: Icons.check_rounded,
                  onTap: () => act(AppConstants.statusApproved),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.visitor});

  final VisitorModel visitor;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return GlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          AvatarCircle(name: visitor.name, imageUrl: visitor.imageUrl, size: 42,
              color: visitor.isApproved ? AppColors.success : AppColors.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(visitor.name, style: t.titleMedium),
                Text(
                  '${visitor.purpose} · ${DateFormat('d MMM, h:mm a').format(DateTime.fromMillisecondsSinceEpoch(visitor.timestamp))}',
                  style: t.bodySmall,
                ),
              ],
            ),
          ),
          StatusBadge(StatusBadge.fromString(visitor.status), compact: true),
        ],
      ),
    );
  }
}

class _PreApprovalCard extends ConsumerWidget {
  const _PreApprovalCard({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final used = item['isUsed'] == true;
    final otp = (item['otp'] ?? '').toString();

    return GlassCard(
      borderRadius: 20,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.tintOf(used ? AppColors.success : AppColors.primary),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              switch ((item['purpose'] ?? '').toString()) {
                'Delivery' => Icons.local_shipping_rounded,
                'Cab' => Icons.local_taxi_rounded,
                'Daily Help' => Icons.cleaning_services_rounded,
                _ => Icons.person_rounded,
              },
              color: used ? AppColors.success : AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text((item['visitorName'] ?? 'Guest').toString(), style: t.titleMedium),
                Text('${item['purpose']} · ${item['date'] ?? ''}', style: t.bodySmall),
              ],
            ),
          ),
          if (used)
            const StatusBadge(BadgeStatus.approved, compact: true)
          else
            GestureDetector(
              onTap: () =>
                  Share.share('UrbanEaze gate pass for ${item['visitorName']}: OTP $otp'),
              child: Column(
                children: [
                  Text(otp,
                      style: GoogleFonts.sora(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: AppColors.primary)),
                  Text('share pass', style: t.bodySmall!.copyWith(fontSize: 10)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PreApproveSheet extends ConsumerStatefulWidget {
  const _PreApproveSheet();

  @override
  ConsumerState<_PreApproveSheet> createState() => _PreApproveSheetState();
}

class _PreApproveSheetState extends ConsumerState<_PreApproveSheet> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  String _purpose = 'Guest';
  DateTime _date = DateTime.now();
  bool _saving = false;
  String? _otp;

  static const _purposes = [
    ('Guest', Icons.person_rounded),
    ('Delivery', Icons.local_shipping_rounded),
    ('Cab', Icons.local_taxi_rounded),
    ('Daily Help', Icons.cleaning_services_rounded),
  ];

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null || _name.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final otp = await ref.read(dataServiceProvider).createPreApproval(user.societyCode, {
      'residentId': user.uid,
      'flat': user.flatNumber,
      'visitorName': _name.text.trim(),
      'visitorPhone': _phone.text.trim(),
      'purpose': _purpose,
      'date': DateFormat('d MMM yyyy').format(_date),
    });
    setState(() {
      _saving = false;
      _otp = otp;
    });
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
        child: _otp != null ? _otpView(t) : _formView(t),
      ),
    );
  }

  Widget _otpView(TextTheme t) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.tintOf(AppColors.success), shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, color: AppColors.success, size: 32),
        ),
        const SizedBox(height: 14),
        Text('Gate pass created', style: t.headlineSmall),
        const SizedBox(height: 4),
        Text('Share this OTP with ${_name.text.trim()}', style: t.bodySmall),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.tintOf(AppColors.primary),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Text(_otp!,
              style: GoogleFonts.sora(
                  fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: 8, color: AppColors.primary)),
        ),
        const SizedBox(height: 20),
        GradientButton(
          label: 'Share pass',
          icon: Icons.share_rounded,
          onTap: () =>
              Share.share('UrbanEaze gate pass for ${_name.text.trim()}: OTP $_otp'),
        ),
        const SizedBox(height: 10),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
      ],
    );
  }

  Widget _formView(TextTheme t) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40, height: 4,
          decoration: BoxDecoration(
              color: AppColors.tintOf(AppColors.primary, alpha: 0.4),
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 18),
        Text('Pre-approve a visitor', style: t.headlineSmall),
        const SizedBox(height: 18),
        Row(
          children: _purposes.map((p) {
            final selected = _purpose == p.$1;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _purpose = p.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.tintOf(AppColors.primary, alpha: 0.16) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: selected ? AppColors.primary : Theme.of(context).colorScheme.outline),
                  ),
                  child: Column(
                    children: [
                      Icon(p.$2, size: 20, color: selected ? AppColors.primary : t.bodySmall!.color),
                      const SizedBox(height: 4),
                      Text(p.$1.split(' ').first,
                          style: t.bodySmall!.copyWith(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: selected ? AppColors.primary : null)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        TextField(controller: _name, decoration: const InputDecoration(labelText: 'Visitor name')),
        const SizedBox(height: 12),
        TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Phone (optional)')),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _date,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 30)),
            );
            if (picked != null) setState(() => _date = picked);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 18, color: t.bodySmall!.color),
                const SizedBox(width: 10),
                Text(DateFormat('EEEE, d MMM').format(_date), style: t.bodyMedium),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        GradientButton(label: 'Generate gate pass', isLoading: _saving, onTap: _submit),
      ],
    );
  }
}
