import 'package:flutter/material.dart';

import '../../core/routes/app_router.dart';
import '../../core/theme/app_theme.dart';

/// Feedback screen for a completed course.
/// Matches the finalized premium preview: mood selector, star rating,
/// "helped you most" chips, name/email/comments, recommendation pills,
/// anonymous checkbox, gradient submit button.
///
/// On submit, the form STAYS on screen (it does not get replaced/cleared
/// immediately) and a quarter-screen bottom sheet slides up from the
/// bottom with a dimmed background overlay showing the success state
/// (green check, "Submitted!", helper line, and a "Back to Programs"
/// button that navigates back to the program listing screen).
class FeedbackScreen extends StatefulWidget {
  final String courseName;

  const FeedbackScreen({
    super.key,
    this.courseName = 'Flutter for Beginners',
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  static const List<String> _moods = ['😍', '😊', '🙂', '😐', '😞'];
  int _selectedMood = 2;

  int _starRating = 4;

  static const List<String> _helpChips = [
    'Flutter Basics',
    'UI Design',
    'Projects',
    'Assignments',
    'Mentorship',
    'Community',
  ];
  final Set<String> _selectedChips = {};

  static const List<String> _recommendOptions = ['Yes', 'Maybe', 'No'];
  String _selectedRecommend = 'Yes';

  bool _anonymous = false;
  bool _isLoading = false;

  // Controls the dimmed overlay + quarter-screen bottom sheet.
  bool _showSuccessSheet = false;

  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _commentsController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO(feedback-api): Replace with the real submit-feedback API call.
      // Payload example:
      // {
      //   mood: _moods[_selectedMood],
      //   rating: _starRating,
      //   helpedWith: _selectedChips.toList(),
      //   name: _anonymous ? null : _nameController.text.trim(),
      //   email: _anonymous ? null : _emailController.text.trim(),
      //   comments: _commentsController.text.trim(),
      //   recommend: _selectedRecommend,
      //   anonymous: _anonymous,
      // }
      await Future<void>.delayed(const Duration(milliseconds: 1400));

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _showSuccessSheet = true; // slide up the quarter-screen sheet
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleBackToPrograms() {
    setState(() => _showSuccessSheet = false);
    Navigator.pushReplacementNamed(context, AppRouter.programListing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F5),
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative floating background shapes.
            Positioned(
              top: -60,
              right: -60,
              child: _Blob(
                size: 180,
                colors: [
                  AppColors.primaryLight.withValues(alpha: 0.35),
                  AppColors.primary.withValues(alpha: 0.35),
                ],
              ),
            ),
            Positioned(
              bottom: 140,
              left: -40,
              child: _Blob(
                size: 110,
                colors: [
                  const Color(0xFFFFD9B3).withValues(alpha: 0.6),
                  Colors.transparent,
                ],
              ),
            ),
            AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                final dy = (_floatController.value - 0.5) * 20;
                return Stack(
                  children: [
                    Positioned(
                      top: 110 + dy,
                      left: 20,
                      child: const Opacity(
                        opacity: 0.5,
                        child: Text('📘', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                    Positioned(
                      top: 260 - dy,
                      right: 24,
                      child: const Opacity(
                        opacity: 0.5,
                        child: Text('✏️', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                    Positioned(
                      bottom: 160 + dy,
                      left: 16,
                      child: const Opacity(
                        opacity: 0.5,
                        child: Text('🎓', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Form stays on screen underneath the sheet — it is never
            // swapped out or cleared when the success sheet appears.
            _buildFormState(context),

            // Dimmed background overlay (fades in behind the sheet).
            IgnorePointer(
              ignoring: !_showSuccessSheet,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: _showSuccessSheet ? 1 : 0,
                child: Container(color: Colors.black.withValues(alpha: 0.5)),
              ),
            ),

            // Quarter-screen bottom sheet success state.
            _buildSuccessSheet(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFormState(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('form'),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: AppSpacing.base),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Need Help?',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              SizedBox(height: AppSpacing.base),
              _HeaderBadge(emoji: '🎓'),
              SizedBox(height: AppSpacing.base),
              Text(
                'How was your learning journey?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 22,
                      color: AppColors.textPrimary,
                    ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                'Your feedback on ${widget.courseName} helps us improve '
                'future learning experiences.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              SizedBox(height: AppSpacing.xl),
              Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'How do you feel?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Row(
                      children: List.generate(_moods.length, (index) {
                        final isSelected = _selectedMood == index;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right:
                                  index == _moods.length - 1 ? 0 : AppSpacing.sm,
                            ),
                            child: _MoodButton(
                              emoji: _moods[index],
                              isSelected: isSelected,
                              onTap: () => setState(() => _selectedMood = index),
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    Text(
                      'Rate this course',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: AppSpacing.lg,
                        horizontal: AppSpacing.lg,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.textPrimary.withValues(alpha: 0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final filled = index < _starRating;
                          return Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _starRating = index + 1),
                              child: Icon(
                                Icons.star_rounded,
                                size: 32,
                                color: filled
                                    ? AppColors.primary
                                    : const Color(0xFFF0DCC5),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    Text(
                      'What helped you the most?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: _helpChips.map((label) {
                        final isSelected = _selectedChips.contains(label);
                        return _SelectableChip(
                          label: label,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedChips.remove(label);
                              } else {
                                _selectedChips.add(label);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    Text(
                      'Your Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    _CardTextField(
                      label: 'Name',
                      controller: _nameController,
                      validator: _validateName,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: AppSpacing.md),
                    _CardTextField(
                      label: 'Email Address',
                      controller: _emailController,
                      validator: _validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Text(
                          'Comments ',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                        ),
                        Text(
                          '(Optional)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    _CardTextField(
                      label: null,
                      controller: _commentsController,
                      maxLines: 4,
                      hintText: 'Tell us what you loved or what we can improve...',
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                    ),
                    SizedBox(height: AppSpacing.xl),
                    Text(
                      'Would you recommend this course to your friends?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Row(
                      children: _recommendOptions.map((option) {
                        final isSelected = _selectedRecommend == option;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: option == _recommendOptions.last
                                  ? 0
                                  : AppSpacing.sm,
                            ),
                            child: _RecommendOption(
                              label: option,
                              isSelected: isSelected,
                              onTap: () =>
                                  setState(() => _selectedRecommend = option),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _AnonCheckbox(
                          value: _anonymous,
                          onChanged: (value) =>
                              setState(() => _anonymous = value),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Submit anonymously',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xl),
                    _GradientSubmitButton(
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _handleSubmit,
                    ),
                    SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Quarter-screen bottom sheet shown after a successful submit.
  /// Slides up from the bottom over the (still visible, dimmed) form —
  /// it does NOT take over the whole screen.
  Widget _buildSuccessSheet(BuildContext context) {
    // 30% of screen height on taller phones, but never below what the
    // content (icon + title + subtitle + button + padding) actually needs —
    // on short screens the plain 30% figure clips/overflows the button.
    final sheetHeight = (MediaQuery.of(context).size.height * 0.30)
        .clamp(280.0, double.infinity);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      left: 0,
      right: 0,
      bottom: _showSuccessSheet ? 0 : -sheetHeight,
      height: sheetHeight,
      child: IgnorePointer(
        ignoring: !_showSuccessSheet,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFEEDE4),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x26141414),
                blurRadius: 30,
                offset: Offset(0, -10),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.check, size: 24, color: Colors.white),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Submitted!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Your feedback helps us create a better learning experience for everyone.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _handleBackToPrograms,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23),
                        ),
                      ),
                      child: const Text(
                        'Back to Programs',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Decorative blurred circle used as a background accent.
class _Blob extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _Blob({required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}

/// Gradient rounded badge shown at the top of the form (education icon).
class _HeaderBadge extends StatelessWidget {
  final String emoji;

  const _HeaderBadge({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.primary],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 30)),
    );
  }
}

/// Single emoji mood button, highlighted when selected.
class _MoodButton extends StatelessWidget {
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodButton({
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: isSelected
            ? Matrix4.identity().scaledByDouble(1.08, 1.08, 1.08, 1)
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.textPrimary.withValues(alpha: 0.06),
              blurRadius: isSelected ? 18 : 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(emoji, style: const TextStyle(fontSize: 22)),
      ),
    );
  }
}

/// Selectable pill chip used for the "helped you most" section.
class _SelectableChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isSelected
              ? LinearGradient(
                  colors: [AppColors.primaryLight, AppColors.primary],
                )
              : null,
          color: isSelected ? null : AppColors.surface,
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.divider,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Card-styled text field with a small uppercase label inside the card,
/// used for Name / Email / Comments to match the premium design exactly.
class _CardTextField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;

  const _CardTextField({
    required this.label,
    required this.controller,
    this.validator,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: AppSpacing.xs),
          ],
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            maxLines: maxLines,
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(color: AppColors.textSecondary),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

/// Single-select pill option used for the recommendation question.
class _RecommendOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RecommendOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF1E6) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Custom rounded checkbox for "Submit anonymously".
class _AnonCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AnonCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: value ? null : AppColors.surface,
          gradient: value
              ? LinearGradient(
                  colors: [AppColors.primaryLight, AppColors.primary],
                )
              : null,
          border: Border.all(
            color: value ? Colors.transparent : AppColors.divider,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: value
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : null,
      ),
    );
  }
}

/// Gradient submit button with a loading spinner state.
class _GradientSubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const _GradientSubmitButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryLight,
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: onPressed,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Submit Feedback →',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15.5,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}