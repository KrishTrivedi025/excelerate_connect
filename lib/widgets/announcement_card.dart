import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data/mock_data.dart';

const List<String> _kMonthAbbreviations = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Component Library 6.2 — Home screen "Announcements" list item.
class AnnouncementCard extends StatelessWidget {
  final Announcement item;
  final VoidCallback onTap;

  const AnnouncementCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = _accentFor(item.type);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 3,
            spreadRadius: 0.5,
            offset: const Offset(3, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: accent.withValues(alpha: 0.15),
                      child: Icon(_iconFor(item.type), color: accent),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.body,
                            style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(_dateLabel(item.publishedAt), style: textTheme.labelSmall),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 34,
                        child: OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Apply Now — coming soon')),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.button),
                            ),
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          child: const Text('Apply Now'),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: SizedBox(
                        height: 34,
                        child: ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.knowMoreAction,
                            foregroundColor: Colors.white,
                            elevation: 6,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.button),
                            ),
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          child: const Text('Know More'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _dateLabel(DateTime date) {
    return '${_kMonthAbbreviations[date.month - 1]} ${date.day}';
  }

  static Color _accentFor(AnnouncementType type) {
    switch (type) {
      case AnnouncementType.general:
      case AnnouncementType.opportunity:
        return AppColors.primary;
      case AnnouncementType.system:
        return AppColors.accent;
      case AnnouncementType.urgent:
        return AppColors.error;
    }
  }

  static IconData _iconFor(AnnouncementType type) {
    switch (type) {
      case AnnouncementType.general:
        return Icons.campaign_outlined;
      case AnnouncementType.opportunity:
        return Icons.celebration_outlined;
      case AnnouncementType.system:
        return Icons.build_circle_outlined;
      case AnnouncementType.urgent:
        return Icons.priority_high;
    }
  }
}
