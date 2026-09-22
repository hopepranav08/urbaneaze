import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/visitor_model.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/data_providers.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/gradient_button.dart';

class GuardEntryScreen extends ConsumerStatefulWidget {
  const GuardEntryScreen({super.key});

  @override
  ConsumerState<GuardEntryScreen> createState() => _GuardEntryScreenState();
}

class _GuardEntryScreenState extends ConsumerState<GuardEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _flat = TextEditingController();
  final _customPurpose = TextEditingController();
  final _carNumber = TextEditingController();
  final _otp = TextEditingController();
  String _purpose = 'Guest';
  bool _hasCar = false;
  bool _saving = false;

  static const _purposes = ['Guest', 'Delivery', 'Cab', 'Daily Help', 'Vendor', 'Other'];

  @override
  void dispose() {
    for (final c in [_name, _phone, _flat, _customPurpose, _carNumber, _otp]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    setState(() => _saving = true);
    await ref.read(dataServiceProvider).addVisitor(
          user.societyCode,
          VisitorModel(
            id: '',
            name: _name.text.trim(),
            phone: _phone.text.trim(),
            purpose: _purpose,
            customPurpose: _purpose == 'Other' ? _customPurpose.text.trim() : '',
            flat: _flat.text.trim().toUpperCase(),
            hasCar: _hasCar,
            carNumber: _hasCar ? _carNumber.text.trim().toUpperCase() : '',
            status: AppConstants.statusPending,
            watchmanId: user.uid,
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );
    setState(() => _saving = false);
    _formKey.currentState?.reset();
    for (final c in [_name, _phone, _flat, _customPurpose, _carNumber]) {
      c.clear();
    }
    setState(() => _hasCar = false);
    if (mounted) {
      FocusScope.of(context).unfocus();
      showAppSnack(context, 'Entry logged — resident notified');
    }
  }

  Future<void> _verifyOtp() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null || _otp.text.trim().length != 6) return;
    HapticFeedback.mediumImpact();
    final match =
        await ref.read(dataServiceProvider).redeemOtp(user.societyCode, _otp.text.trim());
    if (!mounted) return;
    if (match == null) {
      showAppSnack(context, 'Invalid or already used pass', error: true);
      return;
    }
    // Log the pre-approved visitor as an approved entry.
    await ref.read(dataServiceProvider).addVisitor(
          user.societyCode,
          VisitorModel(
            id: '',
            name: (match['visitorName'] ?? 'Pre-approved guest').toString(),
            phone: (match['visitorPhone'] ?? '').toString(),
            purpose: (match['purpose'] ?? 'Guest').toString(),
            flat: (match['flat'] ?? '').toString(),
            status: AppConstants.statusApproved,
            watchmanId: user.uid,
            residentId: (match['residentId'] ?? '').toString(),
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );
    _otp.clear();
    if (mounted) {
      showAppSnack(context, '${match['visitorName']} verified — allow entry to flat ${match['flat']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return ListView(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 18, 20, 110),
      children: [
        Text('Visitor entry', style: t.displaySmall),
        const SizedBox(height: 18),

        // ── Gate pass verification ─────────────────────────────────
        GlassCard(
          borderRadius: 22,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.qr_code_2_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('Verify gate pass OTP', style: t.titleMedium),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _otp,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: GoogleFonts.sora(
                          fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 4),
                      decoration: const InputDecoration(hintText: '6-digit OTP', counterText: ''),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 110,
                    child: GradientButton(
                        label: 'Verify', height: 52, borderRadius: 14, onTap: _verifyOtp),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Row(children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('OR LOG NEW VISITOR', style: t.labelSmall),
          ),
          const Expanded(child: Divider()),
        ]),
        const SizedBox(height: 18),

        // ── Manual entry form ──────────────────────────────────────
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Visitor name'),
                validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _flat,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(labelText: 'Flat no.'),
                      validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text('Purpose', style: t.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _purposes.map((p) {
                  return ChoiceChip(
                    label: Text(p),
                    selected: _purpose == p,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _purpose = p),
                  );
                }).toList(),
              ),
              if (_purpose == 'Other') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customPurpose,
                  decoration: const InputDecoration(labelText: 'Specify purpose'),
                ),
              ],
              const SizedBox(height: 14),
              GlassCard(
                borderRadius: 16,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.directions_car_rounded, size: 20, color: AppColors.guardColor),
                    const SizedBox(width: 10),
                    Expanded(child: Text('Visitor has a vehicle', style: t.bodyMedium)),
                    Switch(value: _hasCar, onChanged: (v) => setState(() => _hasCar = v)),
                  ],
                ),
              ),
              if (_hasCar) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _carNumber,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Vehicle number'),
                ),
              ],
              const SizedBox(height: 20),
              GradientButton(
                label: 'Log entry & notify resident',
                icon: Icons.notifications_active_rounded,
                gradient: AppColors.guardGradient(),
                isLoading: _saving,
                onTap: _submit,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
