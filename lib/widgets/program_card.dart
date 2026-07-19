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
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProgramThumbnail(program: program, width: 100, height: 100),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.name,
                      style: textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _startDateLabel(program),
                      style: textTheme.labelSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      program.shortDescription,
                      style: textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _CategoryChip(label: program.categoryLabel),
                  ],
                ),
              ),
            ],
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

class _CategoryChip extends StatelessWidget {
  final String label;
  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
      labelStyle: Theme.of(context)
          .textTheme
          .labelSmall
          ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
    );
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
