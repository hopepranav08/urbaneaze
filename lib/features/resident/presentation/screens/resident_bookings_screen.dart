import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/data_providers.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/gradient_button.dart';

class ResidentBookingsScreen extends ConsumerStatefulWidget {
  const ResidentBookingsScreen({super.key});

  @override
  ConsumerState<ResidentBookingsScreen> createState() => _ResidentBookingsScreenState();
}

class _ResidentBookingsScreenState extends ConsumerState<ResidentBookingsScreen> {
  String? _amenity;
  DateTime _date = DateTime.now();
  int? _slot;
  bool _saving = false;

  static const _amenityIcons = {
    'Swimming Pool': Icons.pool_rounded,
    'Gym': Icons.fitness_center_rounded,
    'Clubhouse': Icons.celebration_rounded,
    'Tennis Court': Icons.sports_tennis_rounded,
    'Badminton Court': Icons.sports_handball_rounded,
    'Park': Icons.park_rounded,
    'Banquet Hall': Icons.dining_rounded,
  };

  String get _dateKey => DateFormat('yyyy-MM-dd').format(_date);

  Future<void> _book() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null || _amenity == null || _slot == null) return;
    setState(() => _saving = true);
    await ref.read(dataServiceProvider).addBooking(user.societyCode, {
      'userId': user.uid,
      'userName': user.name,
      'flatNumber': user.flatNumber,
      'amenity': _amenity,
      'date': _dateKey,
      'startTime': _slot,
      'endTime': _slot! + 1,
      'societyCode': user.societyCode,
      'status': 'Confirmed',
    });
    setState(() {
      _saving = false;
      _slot = null;
    });
    if (mounted) showAppSnack(context, '$_amenity booked for ${DateFormat('d MMM').format(_date)}');
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final user = ref.watch(currentUserProvider).value;
    final society = ref.watch(societyProvider).value;
    final bookings = ref.watch(bookingsProvider).value ?? [];

    final amenities = society?.amenities ?? [];
    if (_amenity == null && amenities.isNotEmpty) _amenity = amenities.first;

    final dayBookings = bookings.where((b) => b.amenity == _amenity && b.date == _dateKey).toList();
    final bookedSlots = dayBookings.map((b) => b.startTime).toSet();
    final myBookings = bookings.where((b) => b.userId == user?.uid).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 18, 20, 110),
      children: [
        Text('Book an amenity', style: t.displaySmall),
        const SizedBox(height: 18),

        // ── Amenity selector ───────────────────────────────────────
        if (amenities.isEmpty)
          const EmptyState(
              icon: Icons.pool_outlined,
              title: 'No amenities configured',
              message: 'Ask your society admin to add amenities.',
              compact: true)
        else
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: amenities.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final a = amenities[i];
                final selected = a == _amenity;
                return GestureDetector(
                  onTap: () => setState(() {
                    _amenity = a;
                    _slot = null;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 92,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: selected ? AppColors.heroGradient() : null,
                      color: selected ? null : Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: selected ? Colors.transparent : Theme.of(context).colorScheme.outline),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_amenityIcons[a] ?? Icons.star_rounded,
                            color: selected ? Colors.white : AppColors.primary, size: 26),
                        const SizedBox(height: 8),
                        Text(a,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: selected ? Colors.white : t.bodyMedium!.color)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 20),

        // ── Date strip ─────────────────────────────────────────────
        const SectionHeader('Pick a day'),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 14,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final d = DateTime.now().add(Duration(days: i));
              final selected = DateUtils.isSameDay(d, _date);
              return GestureDetector(
                onTap: () => setState(() {
                  _date = d;
                  _slot = null;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 56,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: selected ? Colors.transparent : Theme.of(context).colorScheme.outline),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(DateFormat('E').format(d).toUpperCase(),
                          style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: selected ? Colors.white70 : t.bodySmall!.color)),
                      const SizedBox(height: 3),
                      Text('${d.day}',
                          style: GoogleFonts.sora(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: selected ? Colors.white : t.bodyLarge!.color)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // ── Time slots ─────────────────────────────────────────────
        const SectionHeader('Pick a slot'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(16, (i) {
            final hour = 6 + i;
            final booked = bookedSlots.contains(hour);
            final selected = _slot == hour;
            final label =
                '${hour > 12 ? hour - 12 : hour}${hour >= 12 ? 'pm' : 'am'}';
            return GestureDetector(
              onTap: booked
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      setState(() => _slot = hour);
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: booked
                      ? AppColors.tintOf(AppColors.danger, alpha: 0.08)
                      : selected
                          ? AppColors.primary
                          : Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: booked
                        ? AppColors.danger.withValues(alpha: 0.25)
                        : selected
                            ? Colors.transparent
                            : Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    decoration: booked ? TextDecoration.lineThrough : null,
                    color: booked
                        ? AppColors.danger.withValues(alpha: 0.6)
                        : selected
                            ? Colors.white
                            : t.bodyMedium!.color,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        GradientButton(
          label: _slot == null ? 'Select a slot' : 'Book $_amenity at ${_slot! > 12 ? _slot! - 12 : _slot} ${_slot! >= 12 ? 'PM' : 'AM'}',
          enabled: _slot != null,
          isLoading: _saving,
          onTap: _book,
        ),
        const SizedBox(height: 28),

        // ── My bookings ────────────────────────────────────────────
        const SectionHeader('My bookings'),
        if (myBookings.isEmpty)
          const EmptyState(icon: Icons.event_busy_rounded, title: 'No bookings yet', compact: true)
        else
          ...myBookings.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.tintOf(AppColors.primary),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(_amenityIcons[b.amenity] ?? Icons.star_rounded,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.amenity, style: t.titleMedium),
                            Text('${b.date} · ${b.timeRange}', style: t.bodySmall),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                        onPressed: () async {
                          final ok = await showConfirmSheet(
                            context,
                            title: 'Cancel booking?',
                            message: '${b.amenity} on ${b.date} will be released.',
                            confirmLabel: 'Cancel booking',
                            confirmColor: AppColors.danger,
                            icon: Icons.event_busy_rounded,
                          );
                          if (ok && context.mounted) {
                            await ref.read(dataServiceProvider).cancelBooking(b.societyCode, b.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }
}
