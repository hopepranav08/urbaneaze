import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/data_providers.dart';
import '../providers/theme_provider.dart';
import 'common.dart';
import 'glass_card.dart';
import 'gradient_button.dart';

/// Profile screen shared by resident, admin and guard shells.
class ProfileView extends ConsumerWidget {
  const ProfileView({super.key, this.accentGradient});

  final Gradient? accentGradient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final society = ref.watch(societyProvider).value;
    final themeMode = ref.watch(themeModeProvider);
    final t = Theme.of(context).textTheme;

    return ListView(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 18, 20, 110),
      children: [
        Text('Profile', style: t.displaySmall),
        const SizedBox(height: 18),

        // ── Identity card ──────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: accentGradient ?? AppColors.heroGradient(),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              AvatarCircle(
                  name: user?.name ?? '',
                  imageUrl: user?.profileImageUrl ?? '',
                  size: 62,
                  color: Colors.white24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? '—',
                        style: GoogleFonts.sora(
                            fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(user?.email ?? '',
                        style: GoogleFonts.manrope(fontSize: 12.5, color: Colors.white70)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 6, children: [
                      RoleChip(user?.role ?? 'member'),
                      if ((user?.flatNumber ?? '').isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Flat ${user!.flatNumber}',
                              style: GoogleFonts.manrope(
                                  fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white)),
                        ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Society ────────────────────────────────────────────────
        GlassCard(
          borderRadius: 20,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.tintOf(AppColors.primary),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.location_city_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(society?.societyName ?? '—', style: t.titleMedium),
                    Text(society?.address ?? '', style: t.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Text(user?.societyCode ?? '',
                  style: GoogleFonts.sora(
                      fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // ── Appearance ─────────────────────────────────────────────
        const SectionHeader('Appearance'),
        GlassCard(
          borderRadius: 20,
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              for (final (mode, icon, label) in [
                (ThemeMode.light, Icons.light_mode_rounded, 'Light'),
                (ThemeMode.system, Icons.brightness_auto_rounded, 'Auto'),
                (ThemeMode.dark, Icons.dark_mode_rounded, 'Dark'),
              ])
                Expanded(
                  child: GestureDetector(
                    onTap: () => ref.read(themeModeProvider.notifier).setTheme(mode),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: themeMode == mode
                            ? AppColors.tintOf(AppColors.primary, alpha: 0.16)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: themeMode == mode ? AppColors.primary : Colors.transparent),
                      ),
                      child: Column(children: [
                        Icon(icon, size: 20,
                            color: themeMode == mode ? AppColors.primary : t.bodySmall!.color),
                        const SizedBox(height: 4),
                        Text(label,
                            style: t.bodySmall!.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: themeMode == mode ? AppColors.primary : null)),
                      ]),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // ── Details ────────────────────────────────────────────────
        const SectionHeader('My details'),
        GlassCard(
          borderRadius: 20,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _DetailTile(Icons.phone_rounded, 'Phone', user?.phone ?? '—'),
              const Divider(indent: 56),
              _DetailTile(Icons.directions_car_rounded, 'Car number', user?.carNumber ?? 'NA'),
              const Divider(indent: 56),
              _DetailTile(Icons.badge_rounded, 'Occupancy', user?.occupancy ?? '—'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GradientButton(
          label: 'Edit profile',
          icon: Icons.edit_rounded,
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const _EditProfileSheet(),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () async {
            final ok = await showConfirmSheet(
              context,
              title: 'Log out?',
              message: 'You can sign back in anytime.',
              confirmLabel: 'Log out',
              confirmColor: AppColors.danger,
              icon: Icons.logout_rounded,
            );
            if (!ok || !context.mounted) return;
            await ref.read(currentUserProvider.notifier).logout();
            if (context.mounted) context.go(AppRoutes.login);
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            foregroundColor: AppColors.danger,
            side: BorderSide(color: AppColors.danger.withValues(alpha: 0.4)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          icon: const Icon(Icons.logout_rounded, size: 19),
          label: const Text('Log out'),
        ),
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: t.bodyMedium)),
          Text(value, style: t.titleSmall),
        ],
      ),
    );
  }
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet();

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _car;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider).value;
    _name = TextEditingController(text: user?.name);
    _phone = TextEditingController(text: user?.phone);
    _car = TextEditingController(text: user?.carNumber == 'NA' ? '' : user?.carNumber);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _car.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null || _name.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final updated = user.copyWith(
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      carNumber: _car.text.trim().isEmpty ? 'NA' : _car.text.trim().toUpperCase(),
    );
    await FirebaseDatabase.instance
        .ref('${AppConstants.users}/${user.uid}')
        .update({'name': updated.name, 'phone': updated.phone, 'car': updated.carNumber});
    ref.read(currentUserProvider.notifier).updateUser(updated);
    await ref.read(authServiceProvider).updateSession(updated);
    if (mounted) {
      Navigator.pop(context);
      showAppSnack(context, 'Profile updated');
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
            Text('Edit profile', style: t.headlineSmall),
            const SizedBox(height: 16),
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone')),
            const SizedBox(height: 12),
            TextField(
                controller: _car,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Car number (optional)')),
            const SizedBox(height: 20),
            GradientButton(label: 'Save changes', isLoading: _saving, onTap: _save),
          ],
        ),
      ),
    );
  }
}
