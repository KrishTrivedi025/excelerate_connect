import 'package:flutter/material.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../services/opportunity_service.dart';
import '../../widgets/branded_loader.dart';
import '../../widgets/error_retry_card.dart';
import '../../widgets/floating_action_bar.dart';
import '../../widgets/program_card.dart' show ProgramThumbnail;

class ProgramDetailsScreen extends StatefulWidget {
  final Opportunity opportunity;

  // Set when this screen is opened right after a successful registration
  // made via the "Apply Now" shortcut on Program Listing (which registers
  // without visiting Details first) — shows Give Feedback immediately
  // instead of Register Now, matching what Details already does when the
  // user registers by opening it directly.
  final bool initiallyRegistered;

  const ProgramDetailsScreen({
    super.key,
    required this.opportunity,
    this.initiallyRegistered = false,
  });

  @override
  State<ProgramDetailsScreen> createState() => _ProgramDetailsScreenState();
}

class _ProgramDetailsScreenState extends State<ProgramDetailsScreen> {
  // primary is brand-invariant and stays a plain const. textSecondary and
  // divider flip between themes, so unlike before they can't be static
  // const anymore — they're instance getters resolved off context instead
  // (available in every method below since they're all on this State).
  static const _primary = AppColors.primary;
  Color get _textSecondary => context.palette.textSecondary;
  Color get _divider => context.palette.divider;

  late bool _isFavorited;
  late bool _hasRegistered;

  // Re-fetched fresh every time this screen opens, rather than trusting the
  // (possibly stale) copy handed over via navigation — so an admin edit to
  // this program shows up without needing the list re-fetched too.
  late Future<Opportunity> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.opportunity.isFavorited;
    _hasRegistered = widget.initiallyRegistered;
    _fetchDetails();
  }

  void _fetchDetails() {
    _detailsFuture = OpportunityService.fetchOpportunityById(
      widget.opportunity.id,
    );
  }

  void _toggleFavorite() {
    setState(() => _isFavorited = !_isFavorited);
  }

  Future<void> _onRegister() async {
    // RegistrationScreen pops with `true` once it auto-dismisses its
    // success panel — that's the signal to swap this button to Feedback.
    final result = await Navigator.of(
      context,
    ).pushNamed(AppRouter.registration, arguments: widget.opportunity);
    if (result == true && mounted) {
      setState(() => _hasRegistered = true);
    }
  }

  void _onGiveFeedback() {
    Navigator.of(
      context,
    ).pushNamed(AppRouter.feedback, arguments: widget.opportunity);
  }

  Widget _metaChip(String label) {
    final palette = context.palette;
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: palette.onInfoSurface,
        ),
      ),
      backgroundColor: palette.infoSurface,
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
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: context.palette.textPrimary,
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
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: AppColors.success,
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
                style: TextStyle(fontSize: 12, color: _textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  /// Bordered/separated card section — used for "Upcoming Project Dates"
  /// and the "{Program Name} Completed" section per the reference design.
  Widget _borderedSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_sectionTitle(title), const SizedBox(height: 14), child],
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
      backgroundColor: context.palette.surfaceAlt,
      shape: StadiumBorder(side: BorderSide(color: _divider)),
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
        // NOT palette.background — the scaffold below uses that same old
        // #FAFAFA hex for a different purpose (the page itself). Chips need
        // their own elevated tone or they'd vanish into the page in dark
        // mode.
        color: context.palette.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _primary),
          const SizedBox(width: 6),
          Text(
            skill.name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  /// Fixed, shared "Supported By" logo — the same Saint Louis University
  /// image on every program's details page, regardless of that program's
  /// own sponsor data. Confirmed with the user: this is not per-sponsor.
  Widget _sponsorLogo() {
    // slu_logo.png has no alpha channel — opaque art on a near-white
    // ground. Full-bleed edge-to-edge (the previous OverflowBox treatment)
    // turns that into a stark white band across a dark page. Constraining
    // it to a framed card instead — with a plate matching the asset's own
    // ground — reads as a deliberate partner-logo lockup in both themes,
    // and removes the seam entirely in dark mode.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          color: context.palette.logoPlate,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Image.asset(
            'assets/images/slu_logo.png',
            fit: BoxFit.contain,
            height: 90,
            errorBuilder: (context, error, stackTrace) => Center(
              child: Text(
                'Saint Louis University',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Opportunity>(
      future: _detailsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: context.palette.background,
            body: const Center(child: BrandedLoader(width: 110)),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: context.palette.background,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ErrorRetryCard(
                  message: snapshot.error.toString(),
                  onRetry: () => setState(_fetchDetails),
                ),
              ),
            ),
          );
        }

        return _buildContent(context, snapshot.data!);
      },
    );
  }

  Widget _buildContent(BuildContext context, Opportunity opportunity) {
    final cohort = opportunity.cohorts.isNotEmpty
        ? opportunity.cohorts.first
        : null;
    final rewards = opportunity.rewards ?? const [];
    final skills = opportunity.skills;
    final totalSkillPoints = skills.fold<int>(0, (sum, s) => sum + s.points);
    final roles = opportunity.rolesAndResponsibilities ?? const [];
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
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
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: palette.textPrimary,
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
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: palette.textPrimary,
                    ),
                  ),
                  if (roles.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      "What You'll Do",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _bulletList(roles),
                  ],
                  const SizedBox(height: 24),

                  // 6. Key facts row.
                  Row(
                    children: [
                      Expanded(
                        child: _factItem(
                          Icons.schedule,
                          'Duration',
                          opportunity.durationLabel,
                        ),
                      ),
                      Expanded(
                        child: _factItem(
                          Icons.savings_outlined,
                          'Scholarship',
                          opportunity.scholarshipDisplay,
                        ),
                      ),
                      Expanded(
                        child: _factItem(
                          Icons.payments_outlined,
                          'Fee',
                          opportunity.feeDisplay,
                        ),
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
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
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
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
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
                  // trust_seal.png has no alpha channel either, but the
                  // artwork is already circular with a heavy ring — a
                  // circular plate matching its ground disappears entirely
                  // instead of showing a square seam.
                  Center(
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: palette.logoPlate,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Image.asset(
                        'assets/images/trust_seal.png',
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _primary.withValues(alpha: 0.1),
                          ),
                          child: const Icon(
                            Icons.verified_outlined,
                            size: 56,
                            color: _primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statCallout(
                        'Scholarship',
                        opportunity.scholarshipDisplay,
                      ),
                      _statCallout('Skill Points', '$totalSkillPoints'),
                    ],
                  ),
                ],
              ),
            ),
            FloatingActionBar(
              leading: IconButton(
                onPressed: _toggleFavorite,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    _isFavorited ? Icons.bookmark : Icons.bookmark_border,
                    key: ValueKey(_isFavorited),
                    color: _isFavorited ? _primary : palette.textPrimary,
                  ),
                ),
              ),
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasRegistered
                        ? AppColors.success
                        : _primary,
                    foregroundColor: AppColors.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _hasRegistered ? _onGiveFeedback : _onRegister,
                  child: Text(
                    _hasRegistered ? 'Give Feedback' : 'Register Now',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
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
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: _primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: _textSecondary),
        ),
      ],
    );
  }

  static String _dateLabel(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
