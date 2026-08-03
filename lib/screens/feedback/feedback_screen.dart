import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import '../../core/routes/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../widgets/floating_action_bar.dart';

class FeedbackScreen extends StatefulWidget {
  final Opportunity opportunity;

  const FeedbackScreen({super.key, required this.opportunity});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  // Index 0 is unused — the mood value ranges 1-5 so it can index straight
  // into these without an off-by-one.
  static const List<String> _moodCaptions = [
    '',
    'Not for me',
    'Could be better',
    'It was fine',
    'Really good',
    'Loved it',
  ];
  static const List<String> _moodEmojis = ['', '😞', '😕', '🙂', '😄', '🤩'];

  double _mood = 4;

  late final List<String> _chipOptions;
  final Set<String> _selectedChips = {};

  static const List<String> _recommendOptions = ['Yes', 'Maybe', 'No'];
  String _selectedRecommend = 'Yes';

  // User-draggable height for the comments field — same pattern as
  // Registration's "why apply" field.
  double _commentsHeight = 110;
  static const double _commentsMinHeight = 70;
  static const double _commentsMaxHeight = 320;

  bool _isSubmitting = false;
  bool _showSuccessPanel = false;

  // Drives both the auto-return navigation and the countdown ring drawn
  // around the success checkmark — one controller instead of a separate
  // Timer, so the visual countdown and the actual navigation can't drift
  // apart.
  late final AnimationController _successCountdown;

  @override
  void initState() {
    super.initState();
    // Chips reflect the actual course, not a hardcoded list — falls back to
    // Mentorship/Community if the course has fewer than 4 listed skills so
    // the row never looks sparse.
    final options = widget.opportunity.skills
        .map((s) => s.name)
        .take(6)
        .toList();
    for (final filler in const ['Mentorship', 'Community']) {
      if (options.length >= 4) break;
      if (!options.contains(filler)) options.add(filler);
    }
    _chipOptions = options;

    _successCountdown =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed && mounted) {
              _returnToPrograms();
            }
          });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _commentsController.dispose();
    _successCountdown.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    FocusScope.of(context).unfocus();

    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) return;

    setState(() => _isSubmitting = true);

    try {
      // TODO(feedback): Replace with the real submit-feedback API call.
      // Payload: { mood: _mood.round(), helpedWith: _selectedChips.toList(),
      //   name: _nameController.text.trim(), email: _emailController.text.trim(),
      //   comments: _commentsController.text.trim(), recommend: _selectedRecommend }
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _showSuccessPanel = true;
      });
      _successCountdown.forward(from: 0);
    } finally {
      if (mounted && _isSubmitting) setState(() => _isSubmitting = false);
    }
  }

  void _returnToPrograms() {
    if (!mounted) return;
    // Drops Program Details and this screen off the stack, keeping Home
    // beneath so the system back button still behaves normally.
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRouter.programListing,
      (route) => route.settings.name == AppRouter.home,
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    final palette = context.palette;
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: palette.fieldFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.textField),
        borderSide: BorderSide(color: palette.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.textField),
        borderSide: BorderSide(color: palette.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.textField),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.textField),
        borderSide: BorderSide(color: palette.errorText),
      ),
    );
  }

  Widget _buildChip(String label) {
    final isSelected = _selectedChips.contains(label);
    final palette = context.palette;
    return GestureDetector(
      onTap: () => setState(() {
        if (isSelected) {
          _selectedChips.remove(label);
        } else {
          _selectedChips.add(label);
        }
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? palette.selectedSurface : palette.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.textField),
          border: Border.all(
            color: isSelected ? AppColors.primary : palette.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: palette.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendPill(String label) {
    final isSelected = _selectedRecommend == label;
    final palette = context.palette;
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(
          right: label == _recommendOptions.last ? 0 : 10,
        ),
        child: GestureDetector(
          onTap: () => setState(() => _selectedRecommend = label),
          child: Container(
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? palette.selectedSurface : palette.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.textField),
              border: Border.all(
                color: isSelected ? AppColors.primary : palette.divider,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: palette.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodCard() {
    final index = _mood.round().clamp(1, 5);
    final palette = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.divider),
      ),
      child: Column(
        children: [
          // Drop a Lordicon-exported Lottie file at
          // assets/icons/mood_{1..5}.json to replace the emoji fallback —
          // same pattern as the course badge and nav bar icons.
          SizedBox(
            width: 64,
            height: 64,
            child: Lottie.asset(
              'assets/icons/mood_$index.json',
              width: 64,
              height: 64,
              fit: BoxFit.contain,
              repeat: false,
              errorBuilder: (context, error, stackTrace) => Text(
                _moodEmojis[index],
                style: const TextStyle(fontSize: 44),
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
            child: Text(
              _moodCaptions[index],
              key: ValueKey<int>(index),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: palette.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 8,
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: palette.divider,
              thumbShape: _RingThumbShape(
                fill: palette.thumbSurface,
                shadow: palette.shadowStrong,
              ),
              overlayColor: AppColors.primary.withValues(alpha: 0.12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTickMarkColor: Colors.transparent,
              inactiveTickMarkColor: Colors.transparent,
            ),
            child: Slider(
              min: 1,
              max: 5,
              divisions: 4,
              value: _mood,
              onChanged: (value) {
                final rounded = value.roundToDouble();
                if (rounded != _mood) HapticFeedback.selectionClick();
                setState(() => _mood = rounded);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Not great',
                  style: TextStyle(
                    fontSize: 11,
                    color: palette.textSecondary,
                  ),
                ),
                Text(
                  'Loved it',
                  style: TextStyle(
                    fontSize: 11,
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: viewInsets.bottom),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 4,
                ),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            overlayColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 32),
                          ),
                          onPressed: () {},
                          child: Text(
                            'Need Help?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: palette.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'How did it go?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your honest take helps us make the next cohort better.',
                        style: TextStyle(
                          fontSize: 13,
                          color: palette.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Selected course card — same shell as Registration's.
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: palette.surfaceAlt,
                          borderRadius: BorderRadius.circular(
                            AppRadius.textField,
                          ),
                          border: Border.all(color: palette.divider),
                          boxShadow: [
                            BoxShadow(
                              // This is a SHADOW, not text — palette.shadowSoft,
                              // not textPrimary (which flips to near-white in
                              // dark mode and would produce a pale glow here).
                              color: palette.shadowSoft,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: Lottie.asset(
                                'assets/icons/course_badge.json',
                                width: 22,
                                height: 22,
                                fit: BoxFit.contain,
                                repeat: false,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.auto_stories_outlined,
                                      size: 20,
                                      color: palette.textPrimary,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'COURSE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                      color: palette.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    widget.opportunity.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: palette.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // How was it? — mood slider
                      const Text(
                        'How was it?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildMoodCard(),
                      const SizedBox(height: 18),

                      // What helped you most?
                      Row(
                        children: [
                          const Text(
                            'What helped you the most? ',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '(optional)',
                            style: TextStyle(
                              fontSize: 12,
                              color: palette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _chipOptions.map(_buildChip).toList(),
                      ),
                      const SizedBox(height: 18),

                      // Would you recommend it?
                      const Text(
                        'Would you recommend it?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: _recommendOptions
                            .map(_buildRecommendPill)
                            .toList(),
                      ),
                      const SizedBox(height: 18),

                      // Your details
                      Text(
                        'Your Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Name',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(fontSize: 13),
                        decoration: _fieldDecoration('Enter your name'),
                        validator: (val) => (val == null || val.trim().isEmpty)
                            ? 'Please tell us your name'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Email Address',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(fontSize: 13),
                        decoration: _fieldDecoration('Enter your email'),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'We need an email to follow up';
                          }
                          if (!_emailRegex.hasMatch(val.trim())) {
                            return "That doesn't look like a valid email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Comments — expandable, same pattern as Registration.
                      Row(
                        children: [
                          const Text(
                            'Anything else you want to tell us? ',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '(optional)',
                            style: TextStyle(
                              fontSize: 12,
                              color: palette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Stack(
                        children: [
                          SizedBox(
                            height: _commentsHeight,
                            child: TextFormField(
                              controller: _commentsController,
                              maxLines: null,
                              expands: true,
                              maxLength: 300,
                              textAlignVertical: TextAlignVertical.top,
                              style: const TextStyle(fontSize: 13),
                              decoration:
                                  _fieldDecoration(
                                    'What stood out — good or bad?',
                                  ).copyWith(
                                    counterText: '',
                                    contentPadding: const EdgeInsets.fromLTRB(
                                      14,
                                      12,
                                      28,
                                      18,
                                    ),
                                  ),
                            ),
                          ),
                          Positioned(
                            right: 6,
                            bottom: 6,
                            // Listener + raw pointer events, not
                            // GestureDetector.onPanUpdate — this handle sits
                            // inside a vertically-scrolling
                            // SingleChildScrollView and would otherwise lose
                            // the vertical-drag gesture arena to it.
                            child: Listener(
                              onPointerMove: (event) {
                                setState(() {
                                  _commentsHeight =
                                      (_commentsHeight + event.delta.dy).clamp(
                                        _commentsMinHeight,
                                        _commentsMaxHeight,
                                      );
                                });
                              },
                              child: MouseRegion(
                                cursor: SystemMouseCursors.resizeUpDown,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Transform.rotate(
                                    angle: -0.785398,
                                    child: Icon(
                                      Icons.drag_handle_rounded,
                                      size: 14,
                                      color: palette.textSecondary.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _commentsController,
                            builder: (context, value, _) => Text(
                              '${value.text.length}/300',
                              style: TextStyle(
                                fontSize: 11,
                                color: context.palette.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Submit button lives in the floating action bar
                      // below — this just reserves clearance so the last
                      // field doesn't sit underneath it.
                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Placed before the backdrop/success panel below (and hidden via
          // `visible` once the panel shows) so it can never paint on top of
          // them — Stack paints later children over earlier ones.
          FloatingActionBar(
            visible: !_showSuccessPanel,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Submit Feedback',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          // Dimmed backdrop behind the success panel.
          IgnorePointer(
            ignoring: !_showSuccessPanel,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: _showSuccessPanel ? 1 : 0,
              child: Container(color: palette.scrim),
            ),
          ),

          // Auto-dismissing (5s) success panel — slides up, then
          // _returnToPrograms (scheduled in _submitFeedback) sends the user
          // back to Program Listing on its own; no button needed.
          _SuccessPanel(
            visible: _showSuccessPanel,
            courseName: widget.opportunity.name,
            countdown: _successCountdown,
          ),
        ],
      ),
    );
  }
}

/// Ring-style slider thumb — white fill, orange stroke, soft drop shadow.
/// The stock [RoundSliderThumbShape] is a flat filled circle; this is the
/// one place this screen intentionally departs from a built-in shape.
class _RingThumbShape extends SliderComponentShape {
  // paint() below has no BuildContext, so the fill/shadow colors have to be
  // handed in from the caller (which does have one) rather than read via
  // context.palette here.
  final Color fill;
  final Color shadow;

  const _RingThumbShape({required this.fill, required this.shadow});

  static const double _radius = 13;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(_radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    canvas.drawShadow(
      Path()..addOval(Rect.fromCircle(center: center, radius: _radius)),
      shadow,
      3,
      false,
    );
    canvas.drawCircle(center, _radius, Paint()..color = fill);
    canvas.drawCircle(
      center,
      _radius - 1.25,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }
}

class _SuccessPanel extends StatelessWidget {
  final bool visible;
  final String courseName;
  final Animation<double> countdown;

  const _SuccessPanel({
    required this.visible,
    required this.courseName,
    required this.countdown,
  });

  @override
  Widget build(BuildContext context) {
    const panelHeight = 220.0;
    final palette = context.palette;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      left: 0,
      right: 0,
      bottom: visible ? 0 : -panelHeight,
      height: panelHeight,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            color: palette.surfaceAlt,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: palette.shadowStrong,
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // The checkmark sits inside a ring that drains clockwise
                // over the 5-second countdown, driven by the same
                // AnimationController that triggers the auto-return — so
                // the user can see how long they have before it happens,
                // without a literal ticking digit.
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: countdown,
                        // Stack only gives non-positioned children loose
                        // constraints, so without this explicit SizedBox the
                        // indicator shrinks to its own 36px default — smaller
                        // than the 48px checkmark circle in front of it, and
                        // therefore fully hidden behind it.
                        builder: (context, child) => SizedBox(
                          width: 64,
                          height: 64,
                          child: CircularProgressIndicator(
                            value: 1 - countdown.value,
                            strokeWidth: 3,
                            strokeCap: StrokeCap.round,
                            // The only cue the panel is about to auto-dismiss
                            // — must stay visible against surfaceAlt, not
                            // fade into it the way divider would in dark
                            // mode.
                            backgroundColor: palette.progressTrack,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.check,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Thanks for the feedback!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'We\'ve passed your notes on to the $courseName team.\nTaking you back to programs...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
