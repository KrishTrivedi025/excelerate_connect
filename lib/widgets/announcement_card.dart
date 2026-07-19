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

    return Card(
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        leading: CircleAvatar(
          backgroundColor: accent.withValues(alpha: 0.15),
          child: Icon(_iconFor(item.type), color: accent),
        ),
        title: Text(
          item.title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w700,
          ),
        ),
        subtitle: Text(
          item.body,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(_dateLabel(item.publishedAt), style: textTheme.labelSmall),
        isThreeLine: true,
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
