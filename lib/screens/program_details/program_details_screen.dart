import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../widgets/program_card.dart' show ProgramThumbnail;

class ProgramDetailsScreen extends StatefulWidget {
  final Opportunity opportunity;

  const ProgramDetailsScreen({super.key, required this.opportunity});

  @override
  State<ProgramDetailsScreen> createState() => _ProgramDetailsScreenState();
}

class _ProgramDetailsScreenState extends State<ProgramDetailsScreen> {
  // Sourced from AppColors instead of hardcoded so this screen follows the
  // app's actual brand color, not just the original spec value.
  static const _primary = AppColors.primary;
  static const _textSecondary = AppColors.textSecondary;
  static const _divider = AppColors.divider;

  late bool _isFavorited;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.opportunity.isFavorited;
  }

  void _toggleFavorite() {
    setState(() => _isFavorited = !_isFavorited);
  }

  void _onRegister() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF4CAF50),
                  size: 64,
                  key: ValueKey('registered_icon'),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Registered!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'You are all set for ${widget.opportunity.name}.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: _textSecondary),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).popUntil(
                      (route) => route.settings.name == '/programs' || route.isFirst,
                    );
                  },
                  child: const Text(
                    'Back to Programs',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _metaChip(String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      backgroundColor: const Color(0xFFE3F2FD),
      shape: const StadiumBorder(),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF212121),
      ),
    );
  }

  Widget _bulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(Icons.circle, size: 6, color: _primary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  /// Checkbox-style list for Eligibility, per the reference design.
  Widget _checklist(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, size: 18, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  /// Icon + label pair for a key fact (Duration, Scholarship, Fee, Location).
  Widget _factItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: _primary),
            const SizedBox(width: 6),
            // Expanded + wrapping (rather than a single fixed-width line)
            // so longer labels like "Last Date To Apply" don't overflow
            // when this sits in a narrow Expanded column.
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12, color: _textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }

  /// Bordered/separated card section — used for "Upcoming Project Dates"
  /// and the "{Program Name} Completed" section per the reference design.
  Widget _borderedSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(title),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  /// Rewards icon mapping resolved from the reference design: shield =
  /// Badge, graduation cap = Scholarship, sun icon = Certificate.
  Widget _rewardChip(String label) {
    final lower = label.toLowerCase();
    IconData icon;
    String displayLabel;
    if (lower.contains('badge')) {
      icon = Icons.shield_outlined;
      displayLabel = 'Badge';
    } else if (lower.contains('scholarship')) {
      icon = Icons.school_outlined;
      displayLabel = 'Scholarship';
    } else if (lower.contains('cert')) {
      icon = Icons.wb_sunny_outlined;
      displayLabel = 'Certificate';
    } else {
      icon = Icons.star_outline;
      displayLabel = label;
    }
    return Chip(
      avatar: Icon(icon, size: 16, color: _primary),
      label: Text(displayLabel, style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.white,
      shape: StadiumBorder(side: const BorderSide(color: _divider)),
      visualDensity: VisualDensity.compact,
    );
  }

  /// Skill icon mapping: critical thinking = gear, creative thinking = bulb,
  /// communication = speaker, leadership = people; generic fallback for any
  /// other skill name.
  Widget _skillChip(Skill skill) {
    final lower = skill.name.toLowerCase();
    IconData icon;
    if (lower.contains('critical')) {
      icon = Icons.settings_outlined;
    } else if (lower.contains('creative')) {
      icon = Icons.lightbulb_outline;
    } else if (lower.contains('communicat')) {
      icon = Icons.campaign_outlined;
    } else if (lower.contains('leadership')) {
      icon = Icons.groups_outlined;
    } else {
      icon = Icons.check_circle_outline;
    }
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _primary),
          const SizedBox(width: 6),
          Text(skill.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  /// Fixed, shared "Supported By" logo — the same Saint Louis University
  /// image on every program's details page, regardless of that program's
  /// own sponsor data. Confirmed with the user: this is not per-sponsor.
  Widget _sponsorLogo() {
    // Breaks out of the page's 20px side padding so the logo spans the
    // full device width edge-to-edge, sized to its real aspect ratio
    // (~3:1) so it scales up cleanly instead of being squeezed into a
    // short fixed-height box.
    //
    // Both Container's margin and Padding's padding assert their values
    // are non-negative, so neither can be used for this "wider than my
    // parent" effect. OverflowBox lets a child be laid out wider than its
    // parent allows — but OverflowBox itself sizes to fill whatever
    // constraints IT is given, and this section sits inside a vertical
    // scroll view, which hands down an unbounded height. So OverflowBox
    // needs an outer SizedBox to give its own reported size a finite
    // height; the min/maxWidth below only override the child's width.
    final screenWidth = MediaQuery.sizeOf(context).width;
    final logoHeight = screenWidth * 724 / 2172;
    return SizedBox(
      height: logoHeight,
      width: double.infinity,
      child: OverflowBox(
        minWidth: screenWidth,
        maxWidth: screenWidth,
        alignment: Alignment.center,
        child: Image.asset(
          'assets/images/slu_logo.png',
          width: screenWidth,
          height: logoHeight,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Text(
              'Saint Louis University',
              style: TextStyle(fontWeight: FontWeight.w700, color: _textSecondary),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final opportunity = widget.opportunity;
    final cohort = opportunity.cohorts.isNotEmpty ? opportunity.cohorts.first : null;
    final rewards = opportunity.rewards ?? const [];
    final skills = opportunity.skills;
    final totalSkillPoints = skills.fold<int>(0, (sum, s) => sum + s.points);
    final roles = opportunity.rolesAndResponsibilities ?? const [];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        bottom: false,
        child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Small icon/logo + program name, side by side — no
                // separate hero image section.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ProgramThumbnail(
                        program: opportunity,
                        width: 48,
                        height: 48,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        opportunity.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF212121),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 2. Meta / key-point chips.
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _metaChip(opportunity.categoryLabel),
                    _metaChip(opportunity.durationLabel),
                    _metaChip(opportunity.locationLabel),
                    _metaChip(opportunity.feeDisplay),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Supported By — same fixed Saint Louis University logo
                // on every program's page, not tied to that program's own
                // sponsor field.
                _sectionTitle('Supported By'),
                const SizedBox(height: 12),
                _sponsorLogo(),
                const SizedBox(height: 24),

                // 5. About this program + What You'll Do.
                _sectionTitle('About this program'),
                const SizedBox(height: 12),
                Text(
                  opportunity.fullDescription ?? opportunity.shortDescription,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Color(0xFF212121),
                  ),
                ),
                if (roles.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    "What You'll Do",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  _bulletList(roles),
                ],
                const SizedBox(height: 24),

                // 6. Key facts row.
                Row(
                  children: [
                    Expanded(
                      child: _factItem(Icons.schedule, 'Duration', opportunity.durationLabel),
                    ),
                    Expanded(
                      child: _factItem(
                        Icons.savings_outlined,
                        'Scholarship',
                        opportunity.scholarshipDisplay,
                      ),
                    ),
                    Expanded(
                      child: _factItem(Icons.payments_outlined, 'Fee', opportunity.feeDisplay),
                    ),
                    Expanded(
                      child: _factItem(
                        Icons.location_on_outlined,
                        'Location',
                        opportunity.locationLabel,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 7. Upcoming Project Dates — its own bordered section.
                if (cohort != null) ...[
                  _borderedSection(
                    title: 'Upcoming Project Dates',
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _factItem(
                            Icons.event_busy_outlined,
                            'Last Date To Apply',
                            _dateLabel(cohort.lastDateToApply),
                          ),
                        ),
                        Expanded(
                          child: _factItem(
                            Icons.play_circle_outline,
                            'Experience Start Date',
                            _dateLabel(cohort.startDate),
                          ),
                        ),
                        if (cohort.endDate != null)
                          Expanded(
                            child: _factItem(
                              Icons.flag_outlined,
                              'End Date',
                              _dateLabel(cohort.endDate!),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // 8. Eligibility — checkbox style.
                if (opportunity.eligibility.isNotEmpty) ...[
                  _sectionTitle('Eligibility'),
                  const SizedBox(height: 12),
                  _checklist(opportunity.eligibility),
                  const SizedBox(height: 24),
                ],

                // 9. "{Program Name} Completed" — Rewards + Skills.
                if (rewards.isNotEmpty || skills.isNotEmpty) ...[
                  _borderedSection(
                    title: '${opportunity.name} Completed',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (rewards.isNotEmpty) ...[
                          const Text(
                            'Rewards',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: rewards.map(_rewardChip).toList(),
                          ),
                        ],
                        if (rewards.isNotEmpty && skills.isNotEmpty)
                          const SizedBox(height: 18),
                        if (skills.isNotEmpty) ...[
                          const Text(
                            'Skills',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 40,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              children: skills.map(_skillChip).toList(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // 10. Trust seal — one shared generic image, plus stats.
                Center(
                  child: Image.asset(
                    'assets/images/trust_seal.png',
                    width: 140,
                    height: 140,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _primary.withValues(alpha: 0.1),
                      ),
                      child: const Icon(Icons.verified_outlined, size: 56, color: _primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statCallout('Scholarship', opportunity.scholarshipDisplay),
                    _statCallout('Skill Points', '$totalSkillPoints'),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: _divider)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _toggleFavorite,
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Icon(
                          _isFavorited ? Icons.favorite : Icons.favorite_border,
                          key: ValueKey(_isFavorited),
                          color: _isFavorited ? const Color(0xFFF44336) : const Color(0xFF212121),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _onRegister,
                          child: const Text(
                            'Register Now',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _statCallout(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _primary),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: _textSecondary)),
      ],
    );
  }

  static String _dateLabel(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
