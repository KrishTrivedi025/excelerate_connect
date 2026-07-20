import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data/mock_data.dart';

const List<String> _kMonthAbbreviations = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Component Library 6.1 — reusable program card.
/// Vertical variant: Program Listing screen.
/// Horizontal variant (horizontal: true): Home screen "Programs" row.
class ProgramCard extends StatelessWidget {
  final Opportunity program;
  final VoidCallback onTap;
  final bool horizontal;

  const ProgramCard({
    super.key,
    required this.program,
    required this.onTap,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    return horizontal ? _buildHorizontal(context) : _buildVertical(context);
  }

  Widget _buildVertical(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  child: _ProgramThumbnail(program: program, width: 64, height: 64),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        program.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        program.shortDescription,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Icon(
                            _ProgramThumbnail._iconFor(program.type),
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              program.categoryLabel,
                              style: textTheme.labelSmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '4.8 (120)', // Static mock rating matching the picture layout
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.bookmark_border,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontal(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: 200,
      height: 140,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.card),
                ),
                child: _ProgramThumbnail(
                  program: program,
                  width: double.infinity,
                  height: 80,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      program.name,
                      style: textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _startDateLabel(program),
                      style: textTheme.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _startDateLabel(Opportunity program) {
    if (program.cohorts.isEmpty) return program.durationLabel;
    final date = program.cohorts.first.startDate;
    return 'Starts ${_kMonthAbbreviations[date.month - 1]} ${date.day}, ${date.year}';
  }
}

/// Renders [program.imageUrl] as an asset image. Week 2 asset files
/// (see spec Section 10) haven't been sourced yet, so this falls back to a
/// tinted icon placeholder instead of crashing when the asset is missing.
class _ProgramThumbnail extends StatelessWidget {
  final Opportunity program;
  final double width;
  final double height;

  const _ProgramThumbnail({
    required this.program,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.textField),
        child: Image.asset(
          program.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: AppColors.primaryLight.withValues(alpha: 0.25),
            alignment: Alignment.center,
            child: Icon(
              _iconFor(program.type),
              color: AppColors.primary,
              size: width < 80 ? 22 : 32,
            ),
          ),
        ),
      ),
    );
  }

  static IconData _iconFor(OpportunityType type) {
    switch (type) {
      case OpportunityType.internship:
        return Icons.work_outline;
      case OpportunityType.jobSimulation:
        return Icons.psychology;
      case OpportunityType.course:
        return Icons.lightbulb_outline;
      case OpportunityType.competition:
        return Icons.emoji_events;
      case OpportunityType.event:
        return Icons.event;
      case OpportunityType.masterclass:
        return Icons.school;
      case OpportunityType.career:
        return Icons.badge_outlined;
      case OpportunityType.engagement:
        return Icons.groups;
    }
  }
}
