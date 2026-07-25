import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';

class RegistrationScreen extends StatefulWidget {
  final Opportunity opportunity;

  const RegistrationScreen({super.key, required this.opportunity});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
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

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _whyApplyController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final DateTime initial = _selectedDOB ?? DateTime(2002, 5, 15);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.hero)),
      ),
      builder: (sheetContext) {
        return SafeArea(
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...options.map((option) {
                  final isSelected = selected == option;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.wave.withValues(alpha: 0.4)
                          : Colors.white,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.divider,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.textField),
                    ),
                    child: ListTile(
                      title: Text(
                        option,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppColors.primary)
                          : null,
                      onTap: () {
                        onSelect(option);
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
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
          content: Text('Please select your Date of Birth'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!isIntroducedValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select how you were introduced to this opportunity'),
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
      _showConfirmationDialog();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.hero)),
        title: const Text(
          'Registration Confirmed!',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student: ${_firstNameController.text} ${_lastNameController.text}',
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Course: ${widget.opportunity.name}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Email: ${_emailController.text}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            if (_howIntroduced != null) ...[
              const SizedBox(height: 4),
              Text(
                'Source: $_howIntroduced',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Close the dialog, then pop the registration screen itself —
              // this returns to Program Details, which is exactly what was
              // underneath when this screen was pushed. No further
              // navigation call needed; Program Details is already there.
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Done',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.textField),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.textField),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.textField),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.textField),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dobFormatted = _selectedDOB == null
        ? 'Select your date of birth'
        : '${_selectedDOB!.month}/${_selectedDOB!.day}/${_selectedDOB!.year}';

    return Scaffold(
      backgroundColor: AppColors.background,
      // Unlike Login/Sign-Up's fixed bottom wave, this screen's form is tall
      // enough (6 fields incl. a multiline one) that it needs to actually
      // resize/scroll with the keyboard rather than staying pinned — so,
      // deliberately, true here.
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: AppColors.textPrimary,
                              size: 18,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            // Back arrow just pops — returns to whichever
                            // Program Details screen this was pushed from.
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Need Help?',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Course Registration',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Enter your details below to register for your selected course.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),

                      // Selected course bar — reflects the real Opportunity
                      // passed in via navigation arguments, not a hardcoded
                      // title.
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.wave.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(AppRadius.textField),
                          border: Border.all(
                            color: AppColors.primaryLight.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Course: ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                widget.opportunity.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // FIELD 1: Full Name
                      const Text(
                        'Full Name',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 46,
                              child: TextFormField(
                                controller: _firstNameController,
                                style: const TextStyle(fontSize: 13),
                                decoration: _fieldDecoration('First Name'),
                                validator: (val) =>
                                    (val == null || val.trim().isEmpty) ? 'Required' : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 46,
                              child: TextFormField(
                                controller: _lastNameController,
                                style: const TextStyle(fontSize: 13),
                                decoration: _fieldDecoration('Last Name'),
                                validator: (val) =>
                                    (val == null || val.trim().isEmpty) ? 'Required' : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // FIELD 2: Date of Birth
                      const Text(
                        'Date of Birth',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _pickDateOfBirth,
                        child: Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.textField),
                            border: Border.all(
                              color: _dobTouchedInvalid
                                  ? AppColors.error
                                  : AppColors.divider,
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
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_dobTouchedInvalid)
                        const Padding(
                          padding: EdgeInsets.only(top: 6, left: 4),
                          child: Text(
                            'Please select your date of birth',
                            style: TextStyle(color: AppColors.error, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 14),

                      // FIELD 3: Email Address
                      const Text(
                        'Email Address',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 46,
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(fontSize: 13),
                          decoration: _fieldDecoration('Enter your email'),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Email is required';
                            if (!_emailRegex.hasMatch(val.trim())) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 14),

                      // FIELD 4: Gender (optional)
                      const Text(
                        'Gender (optional)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _openGenderSelector,
                        child: Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.textField),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedGender ?? 'Select gender',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _selectedGender == null
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // FIELD 5: How were you introduced? (required)
                      RichText(
                        text: const TextSpan(
                          text: 'How were you introduced to this opportunity? ',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          children: [
                            TextSpan(
                              text: '*',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.textField),
                            border: Border.all(
                              color: _introducedTouchedInvalid
                                  ? AppColors.error
                                  : AppColors.divider,
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
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_introducedTouchedInvalid)
                        const Padding(
                          padding: EdgeInsets.only(top: 6, left: 4),
                          child: Text(
                            'Please select how you were introduced',
                            style: TextStyle(color: AppColors.error, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 14),

                      // FIELD 6: Why do you want to apply? (optional, multiline)
                      const Text(
                        "Why do you want to apply for this course?",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _whyApplyController,
                        maxLines: 4,
                        minLines: 2,
                        maxLength: 300,
                        style: const TextStyle(fontSize: 13),
                        decoration:
                            _fieldDecoration('Tell us about your goals and motivation...'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 100,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned.fill(child: CustomPaint(painter: _BottomWavePainter())),
                  Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitRegistration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 4,
                          shadowColor: AppColors.primary.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.button),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Register',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Decorative bottom wave, matching the peach wave used on Login/Sign-Up —
/// painted directly rather than reusing [BottomWave] since this one has a
/// different curve shape (single asymmetric cubic vs. the shared widget's
/// double-quad shape) per the original design.
class _BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.wave
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.35);
    path.cubicTo(
      size.width * 0.25,
      size.height * 0.15,
      size.width * 0.65,
      size.height * 0.65,
      size.width,
      size.height * 0.25,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
