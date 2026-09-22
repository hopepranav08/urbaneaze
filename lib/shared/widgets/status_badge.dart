import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum BadgeStatus { pending, approved, denied, active, inactive }

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key, this.compact = false});

  final BadgeStatus status;
  final bool compact;

  static BadgeStatus fromString(String s) {
    switch (s.toLowerCase()) {
      case 'approved':
        return BadgeStatus.approved;
      case 'denied':
      case 'rejected':
        return BadgeStatus.denied;
      case 'active':
        return BadgeStatus.active;
      case 'inactive':
        return BadgeStatus.inactive;
      default:
        return BadgeStatus.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (status) {
      BadgeStatus.pending => (
        'Pending',
        AppColors.warning,
        AppColors.warning.withValues(alpha: 0.12),
      ),
      BadgeStatus.approved => (
        'Approved',
        AppColors.success,
        AppColors.success.withValues(alpha: 0.12),
      ),
      BadgeStatus.denied => (
        'Denied',
        AppColors.danger,
        AppColors.danger.withValues(alpha: 0.12),
      ),
      BadgeStatus.active => (
        'Active',
        AppColors.primary,
        AppColors.primary.withValues(alpha: 0.12),
      ),
      BadgeStatus.inactive => (
        'Inactive',
        AppColors.darkTextMuted,
        AppColors.darkTextMuted.withValues(alpha: 0.12),
      ),
    };

    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
          : const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
