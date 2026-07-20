import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/primary_text_field.dart';
import '../../widgets/password_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/social_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _selectedCountry;
  double _passwordStrength = 0; // 0.0 - 1.0
  String _passwordStrengthLabel = 'Weak';
  bool _agreedToTerms = false;
  bool _isLoading = false;
  bool _showCountryError = false;

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

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
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
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!phoneRegex.hasMatch(value.trim().replaceAll(' ', ''))) {
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

  void _onPasswordChanged() {
    final value = _passwordController.text;
    double strength = 0;
    if (value.length >= 6) strength += 0.25;
    if (value.length >= 10) strength += 0.15;
    if (RegExp(r'[A-Z]').hasMatch(value)) strength += 0.2;
    if (RegExp(r'[0-9]').hasMatch(value)) strength += 0.2;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) strength += 0.2;
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

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthLabel = label;
    });
  }

  Color _strengthColor() {
    switch (_passwordStrengthLabel) {
      case 'Strong':
        return AppColors.success;
      case 'Medium':
        return AppColors.accent;
      default:
        return AppColors.error;
    }
  }

  Future<void> _showCountryPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
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
                  padding: EdgeInsets.all(AppSpacing.md),
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
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: AppColors.divider,
                    ),
                    itemBuilder: (context, index) {
                      final country = _countries[index];
                      return ListTile(
                        title: Text(country),
                        trailing: _selectedCountry == country
                            ? Icon(Icons.check, color: AppColors.primary)
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
    final isCountryValid = _selectedCountry != null && _selectedCountry!.isNotEmpty;

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

      // Per navigation flow: after successful signup, return to Login Screen.
      Navigator.pop(context);
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

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleGoogleSignup() {
    // TODO(auth): Integrate Google sign-up.
  }

  void _handleAppleSignup() {
    // TODO(auth): Integrate Apple sign-up.
  }

  void _navigateToLogin() {
    Navigator.pop(context);
  }

  void _handleNeedHelp() {
    // TODO(support): Navigate to help/support screen when available.
  }

  void _openTermsOfUse() {
    // TODO(legal): Navigate to Terms of Use screen when available.
  }

  void _openPrivacyPolicy() {
    // TODO(legal): Navigate to Privacy Policy screen when available.
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: size.height,
                maxWidth: 440,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.textPrimary,
                        ),
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                      TextButton(
                        onPressed: _handleNeedHelp,
                        child: Text(
                          'Need Help?',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(
                          child: Text(
                            'X',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              height: 1,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Excelerate',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          Text(
                            'Learn • Grow • Excel',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    'Create your account',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'Join Excelerate and start your learning journey.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  SocialButton(
                    provider: SocialProvider.google,
                    onPressed: _isLoading ? null : _handleGoogleSignup,
                  ),
                  SizedBox(height: AppSpacing.md),
                  SocialButton(
                    provider: SocialProvider.apple,
                    onPressed: _isLoading ? null : _handleAppleSignup,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.divider,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                        child: Text(
                          'OR',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.divider,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PrimaryTextField(
                          controller: _firstNameController,
                          labelText: 'First Name',
                          hintText: 'First Name',
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icons.person_outline,
                          validator: (value) => _validateRequired(value, 'First name'),
                        ),
                        SizedBox(height: AppSpacing.md),
                        PrimaryTextField(
                          controller: _lastNameController,
                          labelText: 'Last Name',
                          hintText: 'Last Name',
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icons.person_outline,
                          validator: (value) => _validateRequired(value, 'Last name'),
                        ),
                        SizedBox(height: AppSpacing.md),
                        PrimaryTextField(
                          controller: _emailController,
                          labelText: 'Email Address',
                          hintText: 'Email Address',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icons.mail_outline,
                          validator: _validateEmail,
                        ),
                        SizedBox(height: AppSpacing.md),
                        PrimaryTextField(
                          controller: _phoneController,
                          labelText: 'Phone Number',
                          hintText: 'Phone Number',
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icons.call_outlined,
                          validator: _validatePhone,
                        ),
                        SizedBox(height: AppSpacing.md),
                        _CountryField(
                          label: _selectedCountry ?? 'Country / Nationality',
                          isPlaceholder: _selectedCountry == null,
                          errorText: _showCountryError
                              ? 'Please select your country'
                              : null,
                          onTap: _showCountryPicker,
                        ),
                        SizedBox(height: AppSpacing.md),
                        PasswordField(
                          controller: _passwordController,
                          label: 'Password',
                          hintText: 'Password',
                          textInputAction: TextInputAction.next,
                          validator: _validatePassword,
                        ),
                        _PasswordStrengthMeter(
                          strength: _passwordStrength,
                          label: _passwordStrengthLabel,
                          color: _strengthColor(),
                          hasText: _passwordController.text.isNotEmpty,
                        ),
                        SizedBox(height: AppSpacing.md),
                        PasswordField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          hintText: 'Confirm Password',
                          textInputAction: TextInputAction.done,
                          validator: _validateConfirmPassword,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _agreedToTerms,
                          activeColor: AppColors.primary,
                          onChanged: (value) {
                            setState(() => _agreedToTerms = value ?? false);
                          },
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
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
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = _openTermsOfUse,
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = _openPrivacyPolicy,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Create Account',
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _handleCreateAccount,
                  ),
                  SizedBox(height: AppSpacing.md),
                  OutlinedButton(
                    onPressed: _isLoading ? null : _handleCancel,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      side: BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      GestureDetector(
                        onTap: _isLoading ? null : _navigateToLogin,
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
                  SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Read-only field styled to match PrimaryTextField, used for the
/// Country / Nationality picker since no dropdown widget exists yet
/// in the shared widgets folder.
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
                Icon(
                  Icons.public,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isPlaceholder
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      fontWeight: isPlaceholder ? FontWeight.normal : FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
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

/// Segmented password-strength indicator shown below the password field.
class _PasswordStrengthMeter extends StatelessWidget {
  final double strength;
  final String label;
  final Color color;
  final bool hasText;

  const _PasswordStrengthMeter({
    required this.strength,
    required this.label,
    required this.color,
    required this.hasText,
  });

  @override
  Widget build(BuildContext context) {
    const segmentCount = 5;
    final filledSegments = (strength * segmentCount).round();

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
                    color: isFilled ? color : AppColors.divider,
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
                    text: label,
                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
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