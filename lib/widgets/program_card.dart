import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data/mock_data.dart';

const List<String> _kMonthAbbreviations = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Navy blue used only for the Apply Now button (border/text) on the
/// Program Listing card — a deliberate, scoped exception to the app's
/// orange theme, matching the reference design. Not used anywhere else.
const Color _kListingActionColor = Color(0xFF1E3A5F);

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
    final rewardEntries = _rewardEntries(program.rewards ?? const []);
    final visibleSkills = program.skills.take(2).toList();
    final extraSkillCount = program.skills.length - visibleSkills.length;
    final role = program.role;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                      child: ProgramThumbnail(program: program, width: 52, height: 52),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            program.name,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (role != null && role.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              'Your Role: $role',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.bookmark_border,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.star, size: 13, color: Colors.amber),
                    const SizedBox(width: 3),
                    Text(
                      '4.8 (120)', // Static mock rating matching the picture layout
                      style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Icon(Icons.schedule, size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text(
                      program.durationLabel,
                      style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: 6,
                  children: [
                    ...rewardEntries.map(
                      (e) => _IconLabelChip(icon: e.icon, label: e.label),
                    ),
                    if (program.scholarship > 0)
                      _IconLabelChip(
                        icon: Icons.savings_outlined,
                        label: program.scholarshipDisplay,
                      ),
                    ...visibleSkills.map(
                      (s) => _IconLabelChip(icon: _skillIcon(s.name), label: s.name),
                    ),
                    if (extraSkillCount > 0)
                      _IconLabelChip(icon: null, label: '+$extraSkillCount'),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Registration — coming soon'),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _kListingActionColor,
                            side: const BorderSide(color: _kListingActionColor),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.button),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('Apply Now'),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.knowMoreAction,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.button),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
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
                child: ProgramThumbnail(
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

/// Icon + reward category, classified by keyword from the raw reward string.
/// Mapping confirmed against the reference design: shield = Badge,
/// graduation cap = Scholarship, sun icon = Certificate.
class _RewardEntry {
  final IconData icon;
  final String label;
  const _RewardEntry(this.icon, this.label);
}

List<_RewardEntry> _rewardEntries(List<String> rewards) {
  final seen = <String>{};
  final entries = <_RewardEntry>[];
  for (final reward in rewards) {
    final lower = reward.toLowerCase();
    IconData icon;
    String label;
    if (lower.contains('badge')) {
      icon = Icons.shield_outlined;
      label = 'Badge';
    } else if (lower.contains('scholarship')) {
      icon = Icons.school_outlined;
      label = 'Scholarship';
    } else if (lower.contains('cert')) {
      icon = Icons.wb_sunny_outlined;
      label = 'Certificate';
    } else {
      icon = Icons.star_outline;
      label = reward;
    }
    if (seen.add(label)) {
      entries.add(_RewardEntry(icon, label));
    }
  }
  return entries;
}

/// Skill icon, matching the reference's named mapping (critical thinking =
/// gear, creative thinking = bulb, communication = speaker, leadership =
/// people) with a generic fallback for skills outside that set.
IconData _skillIcon(String skillName) {
  final lower = skillName.toLowerCase();
  if (lower.contains('critical')) return Icons.settings_outlined;
  if (lower.contains('creative')) return Icons.lightbulb_outline;
  if (lower.contains('communicat')) return Icons.campaign_outlined;
  if (lower.contains('leadership')) return Icons.groups_outlined;
  return Icons.check_circle_outline;
}

/// Small compact icon + label chip used for the rewards/scholarship/skills
/// row on the redesigned listing card.
class _IconLabelChip extends StatelessWidget {
  final IconData? icon;
  final String label;

  const _IconLabelChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10.5,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

/// Renders [program.imageUrl] as an asset image. Week 2 asset files
/// (see spec Section 10) haven't been sourced yet, so this falls back to a
/// tinted icon placeholder instead of crashing when the asset is missing.
class ProgramThumbnail extends StatelessWidget {
  final Opportunity program;
  final double width;
  final double height;

  const ProgramThumbnail({
    super.key,
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
