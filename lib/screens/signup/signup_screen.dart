import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/routes/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/bottom_wave.dart';
import '../../widgets/password_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/primary_text_field.dart';
import '../../widgets/social_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Class-level so validators don't rebuild RegExps on every keystroke.
  static final RegExp _emailRegex =
      RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
  static final RegExp _phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');

  static const List<String> _countries = [
    'India',
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    'Germany',
    'Singapore',
    'United Arab Emirates',
    'South Africa',
    'New Zealand',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _selectedCountry;
  bool _agreedToTerms = false;
  bool _isLoading = false;
  bool _showCountryError = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!_phoneRegex.hasMatch(value.trim().replaceAll(' ', ''))) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _showCountryPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.hero),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'Select Country / Nationality',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: _countries.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      color: AppColors.divider,
                    ),
                    itemBuilder: (context, index) {
                      final country = _countries[index];
                      return ListTile(
                        title: Text(country),
                        trailing: _selectedCountry == country
                            ? const Icon(Icons.check, color: AppColors.primary)
                            : null,
                        onTap: () => Navigator.pop(context, country),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedCountry = selected;
        _showCountryError = false;
      });
    }
  }

  Future<void> _handleCreateAccount() async {
    FocusScope.of(context).unfocus();

    final isFormValid = _formKey.currentState?.validate() ?? false;
    final isCountryValid =
        _selectedCountry != null && _selectedCountry!.isNotEmpty;

    setState(() => _showCountryError = !isCountryValid);

    if (!isFormValid || !isCountryValid) {
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms of Use and Privacy Policy'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO(auth): Replace with actual account creation call.
      await Future<void>.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Spec Section 4.2 / Navigation Map: successful sign-up lands on Home.
      Navigator.pushReplacementNamed(context, AppRouter.home);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account creation failed. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — coming soon'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        margin: const EdgeInsets.only(
          bottom: BottomWave.height + AppSpacing.md,
          left: AppSpacing.lg,
          right: AppSpacing.lg,
        ),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: const IgnorePointer(
        child: BottomWave(color: AppColors.wave),
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: _SignupBody(
                  formKey: _formKey,
                  firstNameController: _firstNameController,
                  lastNameController: _lastNameController,
                  emailController: _emailController,
                  phoneController: _phoneController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  selectedCountry: _selectedCountry,
                  showCountryError: _showCountryError,
                  agreedToTerms: _agreedToTerms,
                  isLoading: _isLoading,
                  onValidateRequired: _validateRequired,
                  onValidateEmail: _validateEmail,
                  onValidatePhone: _validatePhone,
                  onValidatePassword: _validatePassword,
                  onValidateConfirmPassword: _validateConfirmPassword,
                  onPickCountry: _showCountryPicker,
                  onToggleTerms: (value) {
                    setState(
                      () => _agreedToTerms = value ?? false,
                    );
                  },
                  onGoogleTap: () => _showComingSoon('Google sign-up'),
                  onAppleTap: () => _showComingSoon('Apple sign-up'),
                  onTermsTap: () => _showComingSoon('Terms of Use'),
                  onPrivacyTap: () => _showComingSoon('Privacy Policy'),
                  onSubmit: _handleCreateAccount,
                  onCancel: _navigateToLogin,
                  onSignInTap: _navigateToLogin,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The whole scrollable form, extracted so the parent State's build() stays
/// short. Doesn't change behavior — it just makes the tree easier to read.
class _SignupBody extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String? selectedCountry;
  final bool showCountryError;
  final bool agreedToTerms;
  final bool isLoading;
  final String? Function(String?, String) onValidateRequired;
  final String? Function(String?) onValidateEmail;
  final String? Function(String?) onValidatePhone;
  final String? Function(String?) onValidatePassword;
  final String? Function(String?) onValidateConfirmPassword;
  final VoidCallback onPickCountry;
  final ValueChanged<bool?> onToggleTerms;
  final VoidCallback onGoogleTap;
  final VoidCallback onAppleTap;
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final VoidCallback onSignInTap;

  const _SignupBody({
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.selectedCountry,
    required this.showCountryError,
    required this.agreedToTerms,
    required this.isLoading,
    required this.onValidateRequired,
    required this.onValidateEmail,
    required this.onValidatePhone,
    required this.onValidatePassword,
    required this.onValidateConfirmPassword,
    required this.onPickCountry,
    required this.onToggleTerms,
    required this.onGoogleTap,
    required this.onAppleTap,
    required this.onTermsTap,
    required this.onPrivacyTap,
    required this.onSubmit,
    required this.onCancel,
    required this.onSignInTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xl),
        // Logo alone, large, left-aligned above "Create your account" —
        // the wordmark is baked into the logo image itself, so no
        // separate "Excelerate" text/tagline is needed next to it (no
        // back arrow — Android system back and the "Sign In" link at the
        // bottom still cover navigation). Align (not Center) is
        // deliberate: the parent Column stretches its children by
        // default, which would otherwise force this fixed-width box to
        // full width and re-center it despite the explicit size.
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 240,
            height: 72,
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              // The box's aspect ratio doesn't exactly match the image's
              // real one, so BoxFit.contain leaves a bit of horizontal
              // slack — without this, the image content centers within
              // that slack instead of hugging the box's left edge, which
              // is what made it look not-quite-left-aligned despite the
              // outer Align above already being correct.
              alignment: Alignment.centerLeft,
              errorBuilder: (context, error, stackTrace) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'X',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Excelerate',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Create your account',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Join Excelerate and start your learning journey.',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SocialButton(
          provider: SocialProvider.google,
          onPressed: isLoading ? null : onGoogleTap,
        ),
        const SizedBox(height: AppSpacing.md),
        SocialButton(
          provider: SocialProvider.apple,
          onPressed: isLoading ? null : onAppleTap,
        ),
        const SizedBox(height: AppSpacing.lg),
        const _OrDivider(),
        const SizedBox(height: AppSpacing.lg),
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PrimaryTextField(
                controller: firstNameController,
                labelText: 'First Name',
                hintText: 'First Name',
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.person_outline,
                validator: (v) => onValidateRequired(v, 'First name'),
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryTextField(
                controller: lastNameController,
                labelText: 'Last Name',
                hintText: 'Last Name',
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.person_outline,
                validator: (v) => onValidateRequired(v, 'Last name'),
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryTextField(
                controller: emailController,
                labelText: 'Email Address',
                hintText: 'Email Address',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.mail_outline,
                validator: onValidateEmail,
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryTextField(
                controller: phoneController,
                labelText: 'Phone Number',
                hintText: 'Phone Number',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.call_outlined,
                validator: onValidatePhone,
              ),
              const SizedBox(height: AppSpacing.md),
              _CountryField(
                label: selectedCountry ?? 'Country / Nationality',
                isPlaceholder: selectedCountry == null,
                errorText: showCountryError
                    ? 'Please select your country'
                    : null,
                onTap: onPickCountry,
              ),
              const SizedBox(height: AppSpacing.md),
              PasswordField(
                controller: passwordController,
                label: 'Password',
                hintText: 'Password',
                textInputAction: TextInputAction.next,
                validator: onValidatePassword,
              ),
              _PasswordStrengthMeter(controller: passwordController),
              const SizedBox(height: AppSpacing.md),
              PasswordField(
                controller: confirmPasswordController,
                label: 'Confirm Password',
                hintText: 'Confirm Password',
                textInputAction: TextInputAction.done,
                validator: onValidateConfirmPassword,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _TermsRow(
          value: agreedToTerms,
          onChanged: onToggleTerms,
          onTapTerms: onTermsTap,
          onTapPrivacy: onPrivacyTap,
        ),
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(
          label: 'Create Account',
          isLoading: isLoading,
          onPressed: isLoading ? null : onSubmit,
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(
          onPressed: isLoading ? null : onCancel,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            side: const BorderSide(color: AppColors.divider),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            GestureDetector(
              onTap: isLoading ? null : onSignInTap,
              child: Text(
                'Sign In',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            'OR',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
      ],
    );
  }
}

/// Read-only field styled to match PrimaryTextField, opens a bottom sheet
/// with the country list.
class _CountryField extends StatelessWidget {
  final String label;
  final bool isPlaceholder;
  final String? errorText;
  final VoidCallback onTap;

  const _CountryField({
    required this.label,
    required this.isPlaceholder,
    required this.errorText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.textField),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.textField),
              border: Border.all(
                color: errorText != null
                    ? AppColors.error
                    : AppColors.divider,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.public,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isPlaceholder
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      fontWeight:
                          isPlaceholder ? FontWeight.normal : FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              errorText!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

/// Checkbox + rich text on one baseline. Uses CrossAxisAlignment.center and
/// a compact tap-target checkbox so the two align cleanly.
class _TermsRow extends StatefulWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTapTerms;
  final VoidCallback onTapPrivacy;

  const _TermsRow({
    required this.value,
    required this.onChanged,
    required this.onTapTerms,
    required this.onTapPrivacy,
  });

  @override
  State<_TermsRow> createState() => _TermsRowState();
}

class _TermsRowState extends State<_TermsRow> {
  // Recognizers persist across rebuilds so we don't leak them each frame.
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = widget.onTapTerms;
    _privacyRecognizer = TapGestureRecognizer()..onTap = widget.onTapPrivacy;
  }

  @override
  void didUpdateWidget(covariant _TermsRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _termsRecognizer.onTap = widget.onTapTerms;
    _privacyRecognizer.onTap = widget.onTapPrivacy;
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: widget.value,
          activeColor: AppColors.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
          onChanged: widget.onChanged,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms of Use',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: _termsRecognizer,
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: _privacyRecognizer,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Own StatefulWidget listening to the password controller directly so
/// keystrokes rebuild only this small meter, not the whole signup form.
class _PasswordStrengthMeter extends StatefulWidget {
  final TextEditingController controller;

  const _PasswordStrengthMeter({required this.controller});

  @override
  State<_PasswordStrengthMeter> createState() =>
      _PasswordStrengthMeterState();
}

class _PasswordStrengthMeterState extends State<_PasswordStrengthMeter> {
  static final RegExp _hasUpper = RegExp(r'[A-Z]');
  static final RegExp _hasDigit = RegExp(r'[0-9]');
  static final RegExp _hasSymbol = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');

  double _strength = 0;
  String _label = 'Weak';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_recalculate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_recalculate);
    super.dispose();
  }

  void _recalculate() {
    final value = widget.controller.text;
    double strength = 0;
    if (value.length >= 6) strength += 0.25;
    if (value.length >= 10) strength += 0.15;
    if (_hasUpper.hasMatch(value)) strength += 0.2;
    if (_hasDigit.hasMatch(value)) strength += 0.2;
    if (_hasSymbol.hasMatch(value)) strength += 0.2;
    strength = strength.clamp(0.0, 1.0);

    String label;
    if (value.isEmpty) {
      label = 'Weak';
      strength = 0;
    } else if (strength < 0.4) {
      label = 'Weak';
    } else if (strength < 0.75) {
      label = 'Medium';
    } else {
      label = 'Strong';
    }

    if (strength != _strength || label != _label) {
      setState(() {
        _strength = strength;
        _label = label;
      });
    }
  }

  Color get _color {
    switch (_label) {
      case 'Strong':
        return AppColors.success;
      case 'Medium':
        return AppColors.accent;
      default:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    const segmentCount = 5;
    final filledSegments = (_strength * segmentCount).round();
    final hasText = widget.controller.text.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(segmentCount, (index) {
              final isFilled = index < filledSegments;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index == segmentCount - 1 ? 0 : 4,
                  ),
                  height: 4,
                  decoration: BoxDecoration(
                    color: isFilled ? _color : AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          if (hasText) ...[
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                text: 'Password strength: ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                children: [
                  TextSpan(
                    text: _label,
                    style: TextStyle(
                      color: _color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
