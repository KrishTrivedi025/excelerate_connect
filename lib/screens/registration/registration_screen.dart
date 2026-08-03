import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../widgets/floating_action_bar.dart';

class RegistrationScreen extends StatefulWidget {
  final Opportunity opportunity;

  const RegistrationScreen({super.key, required this.opportunity});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _whyApplyController = TextEditingController();

  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static const List<String> _introducedOptions = [
    'Social Media',
    'Friend or Colleague',
    'College / Campus Event',
    'Search Engine',
    'Email Newsletter / Blog',
    'Other',
  ];

  DateTime? _selectedDOB;
  String? _selectedGender;
  String? _howIntroduced;

  bool _isSubmitting = false;

  // DOB and "how introduced" are custom pickers, not TextFormFields, so they
  // don't get Form's automatic validator/error styling — these track
  // whether a submit attempt has happened while they're still empty, so the
  // fields can show the same red-border treatment Sign-Up's country picker
  // uses instead of relying solely on a SnackBar the user might miss.
  bool _dobTouchedInvalid = false;
  bool _introducedTouchedInvalid = false;

  // User-draggable height for the "Why do you want to apply" field.
  double _commentsHeight = 110;
  static const double _commentsMinHeight = 70;
  static const double _commentsMaxHeight = 320;

  bool _showSuccessPanel = false;

  // Drives both the auto-return navigation and the countdown ring drawn
  // around the success checkmark — one controller instead of a separate
  // Timer, so the visual countdown and the actual navigation can't drift
  // apart.
  late final AnimationController _successCountdown;

  @override
  void initState() {
    super.initState();
    _successCountdown =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..addStatusListener((status) {
            // Registration pops with `true` once the panel's countdown
            // finishes — Program Details reads that to swap in the
            // Feedback button.
            if (status == AnimationStatus.completed && mounted) {
              Navigator.of(context).pop(true);
            }
          });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _whyApplyController.dispose();
    _successCountdown.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final DateTime initial = _selectedDOB ?? DateTime(2002, 5, 15);
    // No custom `builder:` here — AppTheme's own datePickerTheme (light and
    // dark) already styles this correctly. The previous builder forced
    // ThemeData.light(), which gave a full-screen white calendar
    // regardless of app theme and dropped Poppins/AppPalette from the
    // picker's subtree entirely.
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDOB = picked;
        _dobTouchedInvalid = false;
      });
    }
  }

  /// Shared bottom-sheet chooser used by both the Gender and "How were you
  /// introduced" fields — same selectable-list-with-checkmark UI, just
  /// parameterized by title/options/selected/onSelect so the two pickers
  /// don't duplicate this layout.
  void _openOptionSelector({
    required String title,
    required List<String> options,
    required String? selected,
    required ValueChanged<String> onSelect,
  }) {
    // A previously-focused text field can silently regain focus once this
    // sheet closes, popping the keyboard back open — Flutter restores the
    // base route's last-focused node by default once the sheet's route is
    // gone, regardless of how it was dismissed (option tap, the close
    // button, or system back). Plain unfocus() only clears the *current*
    // focus; it doesn't stop that restoration, since the scope still
    // remembers which descendant to hand focus back to. Requesting focus on
    // a disconnected, one-off FocusNode instead means there is no longer a
    // text field on record for anything to restore focus to.
    FocusScope.of(context).requestFocus(FocusNode());
    final palette = context.palette;

    showModalBottomSheet(
      context: context,
      backgroundColor: palette.surfaceAlt,
      // Without this, the sheet is capped to Flutter's default bottom-sheet
      // height and its content isn't scrollable — a 6-option list (or any
      // list, on a shorter screen) overflows instead of scrolling.
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.hero),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: palette.textSecondary,
                        ),
                        onPressed: () => Navigator.of(sheetContext).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: options.map((option) {
                          final isSelected = selected == option;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? palette.selectedSurface
                                  : palette.surfaceAlt,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : palette.divider,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppRadius.textField,
                              ),
                            ),
                            // ListTile paints its ink splash/background on the
                            // nearest Material ancestor — without this, the
                            // colored Container above hides those effects.
                            child: Material(
                              type: MaterialType.transparency,
                              borderRadius: BorderRadius.circular(
                                AppRadius.textField,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: ListTile(
                                title: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: palette.textPrimary,
                                  ),
                                ),
                                trailing: isSelected
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: AppColors.primary,
                                      )
                                    : null,
                                onTap: () {
                                  onSelect(option);
                                  Navigator.of(sheetContext).pop();
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      if (mounted) FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  void _openGenderSelector() {
    _openOptionSelector(
      title: 'Select Gender',
      options: const ['Male', 'Female', 'Non-binary', 'Prefer not to say'],
      selected: _selectedGender,
      onSelect: (value) => setState(() => _selectedGender = value),
    );
  }

  void _openIntroducedSelector() {
    _openOptionSelector(
      title: 'How were you introduced?',
      options: _introducedOptions,
      selected: _howIntroduced,
      onSelect: (value) => setState(() {
        _howIntroduced = value;
        _introducedTouchedInvalid = false;
      }),
    );
  }

  Future<void> _submitRegistration() async {
    FocusScope.of(context).unfocus();

    final isFormValid = _formKey.currentState?.validate() ?? false;
    final isDobValid = _selectedDOB != null;
    final isIntroducedValid =
        _howIntroduced != null && _howIntroduced!.isNotEmpty;

    setState(() {
      _dobTouchedInvalid = !isDobValid;
      _introducedTouchedInvalid = !isIntroducedValid;
    });

    if (!isFormValid) return;

    if (!isDobValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          // Explicit white text — snackBarTheme.contentTextStyle is tuned
          // for the default inverseSurface background, not this red fill.
          content: Text(
            'Please select your Date of Birth',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!isIntroducedValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select how you were introduced to this opportunity',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // TODO(registration): Replace with actual registration API call.
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _showSuccessPanel = true;
      });
      _successCountdown.forward(from: 0);
    } finally {
      if (mounted && _isSubmitting) {
        setState(() => _isSubmitting = false);
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final dobFormatted = _selectedDOB == null
        ? 'Select your date of birth'
        : '${_selectedDOB!.month}/${_selectedDOB!.day}/${_selectedDOB!.year}';
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
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
                        'Course Registration',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enter your details below to register for your selected course.',
                        style: TextStyle(
                          fontSize: 13,
                          color: palette.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Selected course card — reflects the real Opportunity
                      // passed in via navigation arguments.
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
                              // A SHADOW, not text — palette.shadowSoft, not
                              // textPrimary (which flips to near-white in
                              // dark mode).
                              color: palette.shadowSoft,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Plain dark line icon, no background badge/tint —
                            // matches the bottom nav bar's own icon style.
                            // Drop a Lordicon-exported Lottie file at
                            // assets/icons/course_badge.json to replace the
                            // fallback glyph below, same pattern as the nav
                            // bar's icons.
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
                      const SizedBox(height: 14),

                      // FIELD 1: Full Name — brightness-independent text, no
                      // color set (inherits from bodyMedium), so this one
                      // stays const throughout.
                      const Text(
                        'Full Name',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              style: const TextStyle(fontSize: 13),
                              decoration: _fieldDecoration('First Name'),
                              validator: (val) =>
                                  (val == null || val.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              style: const TextStyle(fontSize: 13),
                              decoration: _fieldDecoration('Last Name'),
                              validator: (val) =>
                                  (val == null || val.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // FIELD 2: Date of Birth
                      const Text(
                        'Date of Birth',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _pickDateOfBirth,
                        child: Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: palette.fieldFill,
                            borderRadius: BorderRadius.circular(
                              AppRadius.textField,
                            ),
                            border: Border.all(
                              color: _dobTouchedInvalid
                                  ? palette.errorText
                                  : palette.divider,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dobFormatted,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _selectedDOB == null
                                      ? palette.textSecondary
                                      : palette.textPrimary,
                                ),
                              ),
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: palette.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_dobTouchedInvalid)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 4),
                          child: Text(
                            'Please select your date of birth',
                            style: TextStyle(
                              color: palette.errorText,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 14),

                      // FIELD 3: Email Address
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
                            return 'Email is required';
                          }
                          if (!_emailRegex.hasMatch(val.trim())) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // FIELD 4: Gender (optional)
                      const Text(
                        'Gender (optional)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _openGenderSelector,
                        child: Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: palette.fieldFill,
                            borderRadius: BorderRadius.circular(
                              AppRadius.textField,
                            ),
                            border: Border.all(color: palette.divider),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedGender ?? 'Select gender',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _selectedGender == null
                                      ? palette.textSecondary
                                      : palette.textPrimary,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 18,
                                color: palette.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // FIELD 5: How were you introduced? (required)
                      RichText(
                        text: TextSpan(
                          text: 'How were you introduced to this opportunity? ',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: palette.textPrimary,
                          ),
                          children: [
                            TextSpan(
                              text: '*',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: palette.errorText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _openIntroducedSelector,
                        child: Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: palette.fieldFill,
                            borderRadius: BorderRadius.circular(
                              AppRadius.textField,
                            ),
                            border: Border.all(
                              color: _introducedTouchedInvalid
                                  ? palette.errorText
                                  : palette.divider,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _howIntroduced ?? 'Select source',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _howIntroduced == null
                                      ? palette.textSecondary
                                      : palette.textPrimary,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 18,
                                color: palette.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_introducedTouchedInvalid)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 4),
                          child: Text(
                            'Please select how you were introduced',
                            style: TextStyle(
                              color: palette.errorText,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 14),

                      // FIELD 6: Why do you want to apply? (optional, resizable)
                      const Text(
                        'Why do you want to apply for this course?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Stack(
                        children: [
                          SizedBox(
                            height: _commentsHeight,
                            child: TextFormField(
                              controller: _whyApplyController,
                              maxLines: null,
                              expands: true,
                              maxLength: 300,
                              textAlignVertical: TextAlignVertical.top,
                              style: const TextStyle(fontSize: 13),
                              decoration:
                                  _fieldDecoration(
                                    'Tell us about your goals and motivation...',
                                  ).copyWith(
                                    // Built-in counter needs its own reserved row
                                    // below the field — not available once the
                                    // field expands to fill a fixed-height box.
                                    // A custom counter is rendered below instead.
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
                            // Listener + raw pointer events instead of
                            // GestureDetector.onPanUpdate — this handle sits
                            // inside a vertically-scrolling SingleChildScrollView,
                            // and a plain vertical-drag GestureDetector loses
                            // the gesture arena to the ancestor Scrollable
                            // (both want the same vertical drag), so
                            // onPanUpdate never fires. Listener observes raw
                            // pointer moves regardless of arena resolution.
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
                            valueListenable: _whyApplyController,
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
                      // Register button lives in the floating action bar
                      // below (see FloatingActionBar in the Stack) — this
                      // just reserves clearance so the last field doesn't
                      // sit underneath it.
                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // No leading icon here (unlike Program Details' bookmark) — this
          // bar is just the single primary action. Placed *before* the
          // backdrop/success panel below (and hidden via `visible` once the
          // panel shows) so it can never paint on top of them — Stack
          // paints later children over earlier ones, and this used to be
          // last, which is exactly what caused it to visibly overlap the
          // success panel.
          FloatingActionBar(
            visible: !_showSuccessPanel,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitRegistration,
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
                      'Register',
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

          // Auto-dismissing (5s) success panel — slides up from the bottom,
          // then Navigator.pop(true) (scheduled in _submitRegistration)
          // returns to Program Details on its own; no manual button needed.
          _SuccessPanel(
            visible: _showSuccessPanel,
            opportunityName: widget.opportunity.name,
            countdown: _successCountdown,
          ),
        ],
      ),
    );
  }
}

class _SuccessPanel extends StatelessWidget {
  final bool visible;
  final String opportunityName;
  final Animation<double> countdown;

  const _SuccessPanel({
    required this.visible,
    required this.opportunityName,
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
                            // — must stay visible against surfaceAlt.
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
                  'Registered!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You\'re all set for $opportunityName.\nTaking you back to the course...',
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
