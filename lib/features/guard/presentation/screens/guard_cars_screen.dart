import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/data_providers.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/gradient_button.dart';

class GuardCarsScreen extends ConsumerStatefulWidget {
  const GuardCarsScreen({super.key});

  @override
  ConsumerState<GuardCarsScreen> createState() => _GuardCarsScreenState();
}

class _GuardCarsScreenState extends ConsumerState<GuardCarsScreen> {
  final _rfid = TextEditingController();
  final _carNumber = TextEditingController();
  final _ownerName = TextEditingController();
  final _flat = TextEditingController();
  String _direction = 'in';
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_rfid, _carNumber, _ownerName, _flat]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _lookupTag() async {
    final society = ref.read(societyCodeProvider);
    final tag = _rfid.text.trim();
    if (tag.isEmpty) return;
    final data = await ref.read(dataServiceProvider).lookupRfid(society, tag);
    if (!mounted) return;
    if (data == null) {
      showAppSnack(context, 'Unknown tag — fill details to register it', error: true);
      return;
    }
    setState(() {
      _carNumber.text = (data['carNumber'] ?? '').toString();
      _ownerName.text = (data['ownerName'] ?? '').toString();
      _flat.text = (data['flatNumber'] ?? '').toString();
    });
  }

  Future<void> _logCar() async {
    final society = ref.read(societyCodeProvider);
    if (_carNumber.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final tag = _rfid.text.trim();
    if (tag.isNotEmpty) {
      // Register / refresh the tag mapping so next scan auto-fills.
      await ref.read(dataServiceProvider).assignRfid(society, tag, {
        'carNumber': _carNumber.text.trim().toUpperCase(),
        'ownerName': _ownerName.text.trim(),
        'flatNumber': _flat.text.trim().toUpperCase(),
      });
    }
    await ref.read(dataServiceProvider).addCarLog(society, {
      'rfidTag': tag,
      'carNumber': _carNumber.text.trim().toUpperCase(),
      'ownerName': _ownerName.text.trim(),
      'flatNumber': _flat.text.trim().toUpperCase(),
      'direction': _direction,
    });
    for (final c in [_rfid, _carNumber, _ownerName, _flat]) {
      c.clear();
    }
    setState(() => _saving = false);
    if (mounted) {
      FocusScope.of(context).unfocus();
      showAppSnack(context, 'Car ${_direction == 'in' ? 'entry' : 'exit'} logged');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final logs = ref.watch(carLogsProvider).value ?? [];

    return ListView(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 18, 20, 110),
      children: [
        Text('Car gate', style: t.displaySmall),
        const SizedBox(height: 18),

        GlassCard(
          borderRadius: 22,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _rfid,
                      decoration: const InputDecoration(labelText: 'RFID tag (scan or type)'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filledTonal(
                    onPressed: _lookupTag,
                    icon: const Icon(Icons.search_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _carNumber,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Car number'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ownerName,
                      decoration: const InputDecoration(labelText: 'Owner'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 110,
                    child: TextField(
                      controller: _flat,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(labelText: 'Flat'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (final (value, label, icon) in [
                    ('in', 'Entry', Icons.login_rounded),
                    ('out', 'Exit', Icons.logout_rounded),
                  ])
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _direction = value),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: EdgeInsets.only(right: value == 'in' ? 10 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _direction == value
                                ? AppColors.tintOf(
                                    value == 'in' ? AppColors.success : AppColors.secondary,
                                    alpha: 0.16)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _direction == value
                                  ? (value == 'in' ? AppColors.success : AppColors.secondary)
                                  : Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(icon,
                                  size: 18,
                                  color: value == 'in' ? AppColors.success : AppColors.secondary),
                              const SizedBox(width: 6),
                              Text(label, style: t.titleSmall),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              GradientButton(
                label: 'Log car ${_direction == 'in' ? 'entry' : 'exit'}',
                gradient: AppColors.guardGradient(),
                isLoading: _saving,
                onTap: _logCar,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SectionHeader('Recent car activity'),

        if (logs.isEmpty)
          const EmptyState(
              icon: Icons.directions_car_outlined, title: 'No car logs yet', compact: true)
        else
          ...logs.take(20).map((l) {
            final isIn = l['direction'] == 'in';
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                borderRadius: 18,
                padding: const EdgeInsets.all(13),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppColors.tintOf(isIn ? AppColors.success : AppColors.secondary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(isIn ? Icons.login_rounded : Icons.logout_rounded,
                          size: 18, color: isIn ? AppColors.success : AppColors.secondary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text((l['carNumber'] ?? '').toString(),
                              style: GoogleFonts.sora(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: t.bodyLarge!.color)),
                          Text(
                              '${l['ownerName'] ?? ''}${(l['flatNumber'] ?? '').toString().isEmpty ? '' : ' · Flat ${l['flatNumber']}'}',
                              style: t.bodySmall),
                        ],
                      ),
                    ),
                    Text(
                      DateFormat('h:mm a').format(DateTime.fromMillisecondsSinceEpoch(
                          ((l['timestamp'] ?? 0) as num).toInt())),
                      style: t.bodySmall!.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
