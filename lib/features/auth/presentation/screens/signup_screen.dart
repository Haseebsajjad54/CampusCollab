import 'package:campus_collab/app.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/config/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with TickerProviderStateMixin {
  late AnimationController _meshController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _meshController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _meshController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, provider, child) {
        final size = MediaQuery.of(context).size;
        final theme = Theme.of(context);
        final currentStep = provider.currentSignupStep;

        return Scaffold(
          body: Stack(
            children: [
              AnimatedBuilder(
                animation: _meshController,
                builder: (context, child) {
                  return CustomPaint(
                    size: size,
                    painter: MeshGradientPainter(_meshController.value),
                  );
                },
              ),
              Positioned.fill(
                child: Opacity(
                  opacity: 0.03,
                  child: Image.asset(
                    'assets/noise.png',
                    fit: BoxFit.cover,
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      _buildProgressIndicator(theme, provider),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              SizedBox(height: size.height * 0.05),
                              _buildHeader(theme, provider),
                              const SizedBox(height: 40),
                              if (currentStep == 0)
                                _buildAccountForm(theme, provider)
                              else if (currentStep == 1)
                                _buildEmailVerificationView(theme, provider)
                              else
                                _buildProfileForm(theme, provider),
                              const SizedBox(height: 24),
                              _buildNavigationButtons(theme, provider),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(ThemeData theme, AuthProvider provider) {
    final currentStep = provider.currentSignupStep;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _buildStepIndicator(theme, 0, currentStep, 'Account'),
          Expanded(
            child: Container(
              height: 2,
              color: currentStep >= 1 ? AppColors.primary : AppColors.border,
            ),
          ),
          _buildStepIndicator(theme, 1, currentStep, 'Verify'),
          Expanded(
            child: Container(
              height: 2,
              color: currentStep >= 2 ? AppColors.primary : AppColors.border,
            ),
          ),
          _buildStepIndicator(theme, 2, currentStep, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(ThemeData theme, int step, int currentStep, String label) {
    final isActive = currentStep >= step;
    final isCompleted = currentStep > step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppColors.primary : AppColors.surface,
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.border,
                width: 2,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, size: 20, color: Colors.white)
                  : Text(
                (step + 1).toString(),
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AuthProvider provider) {
    final currentStep = provider.currentSignupStep;
    String title = '';
    String subtitle = '';

    switch (currentStep) {
      case 0:
        title = 'Create Account';
        subtitle = 'Sign up to find your perfect project partners';
        break;
      case 1:
        title = 'Verify Your Email';
        subtitle = 'Please verify your email address to continue';
        break;
      case 2:
        title = 'Complete Profile';
        subtitle = 'Tell us more about yourself';
        break;
    }

    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppColors.glowShadow,
                ),
                child: const Icon(
                  Icons.people_alt_rounded,
                  size: 40,
                  color: AppColors.textPrimary,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds),
          child: Text(
            title,
            style: theme.textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountForm(ThemeData theme, AuthProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.glass, AppColors.glass.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: provider.signupFullNameController,
                  label: 'FULL NAME',
                  hint: 'Enter your full name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: provider.signupEmailController,
                  label: 'EMAIL',
                  hint: 'Enter your university email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: provider.signupPasswordController,
                  label: 'PASSWORD',
                  hint: 'Create a password',
                  icon: Icons.lock_outline,
                  obscureText: provider.obscureSignupPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      provider.obscureSignupPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: provider.toggleSignupPasswordVisibility,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: provider.confirmPasswordController,
                  label: 'CONFIRM PASSWORD',
                  hint: 'Re-enter your password',
                  icon: Icons.lock_outline,
                  obscureText: provider.obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      provider.obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: provider.toggleConfirmPasswordVisibility,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: provider.agreedToTerms,
                        onChanged: (value) => provider.setAgreedToTerms(value ?? false),
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => provider.setAgreedToTerms(!provider.agreedToTerms),
                        child: Text(
                          'I agree to the Terms & Conditions and Privacy Policy',
                          style: theme.textTheme.bodyMedium,
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

  Widget _buildEmailVerificationView(ThemeData theme, AuthProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.glass, AppColors.glass.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.email_outlined,
                    size: 50,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Verify Your Email',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'We\'ve sent a verification link to:',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  provider.pendingEmail ?? '',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.accentBlue, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'Important',
                            style: TextStyle(
                              color: AppColors.accentBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildVerificationInstruction(
                        '1. Check your inbox (and spam folder)',
                      ),
                      const SizedBox(height: 8),
                      _buildVerificationInstruction(
                        '2. Click the verification link in the email',
                      ),
                      const SizedBox(height: 8),
                      _buildVerificationInstruction(
                        '3. Return to the app to continue',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Resend Email Button
                OutlinedButton(
                  onPressed: provider.isLoading ? null : () async {
                    // Resend verification email
                    await provider.resendVerificationEmail(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Resend Verification Email'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileForm(ThemeData theme, AuthProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.glass, AppColors.glass.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: provider.studentIdController,
                  label: 'STUDENT ID',
                  hint: 'e.g., 23I-3076',
                  icon: Icons.badge,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: provider.departmentController,
                  label: 'DEPARTMENT',
                  hint: 'e.g., Computer Science',
                  icon: Icons.school,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: provider.yearOfStudy,
                  decoration: const InputDecoration(
                    labelText: 'YEAR OF STUDY',
                    prefixIcon: Icon(Icons.grade),
                  ),
                  items: [1, 2, 3, 4, 5].map((year) {
                    return DropdownMenuItem(
                      value: year,
                      child: Text('Year $year'),
                    );
                  }).toList(),
                  onChanged: (value) => provider.setYearOfStudy(value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: provider.cgpaController,
                  decoration: const InputDecoration(
                    labelText: 'CGPA',
                    hintText: 'e.g., 3.5',
                    prefixIcon: Icon(Icons.star),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => provider.setCgpaFromController(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: provider.bioController,
                  decoration: const InputDecoration(
                    labelText: 'BIO',
                    hintText: 'Tell us about yourself...',
                    prefixIcon: Icon(Icons.person),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Text(
                  'SELECT SKILLS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: provider.availableSkills.map((skill) {
                    final isSelected = provider.selectedSkills.contains(skill);
                    return FilterChip(
                      label: Text(skill),
                      selected: isSelected,
                      onSelected: (_) => provider.toggleSkill(skill),
                      backgroundColor: AppColors.surface,
                      selectedColor: AppColors.primary,
                      checkmarkColor: Colors.white,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'PREFERRED TEAM SIZE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: provider.preferredTeamSize.toDouble(),
                        min: 2,
                        max: 6,
                        divisions: 4,
                        label: provider.preferredTeamSize.toString(),
                        activeColor: AppColors.primary,
                        onChanged: (value) => provider.setPreferredTeamSize(value.round()),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        provider.preferredTeamSize.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: provider.availabilityStatus,
                  decoration: const InputDecoration(
                    labelText: 'AVAILABILITY STATUS',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'available', child: Text('Available')),
                    DropdownMenuItem(value: 'looking', child: Text('Looking for projects')),
                    DropdownMenuItem(value: 'busy', child: Text('Busy')),
                  ],
                  onChanged: (value) => provider.setAvailabilityStatus(value!),
                ),
                const SizedBox(height: 16),
                const Text(
                  'SOCIAL LINKS (OPTIONAL)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: provider.linkedinController,
                  label: 'LINKEDIN URL',
                  hint: 'https://linkedin.com/in/username',
                  icon: Icons.link,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: provider.githubController,
                  label: 'GITHUB URL',
                  hint: 'https://github.com/username',
                  icon: Icons.code,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: provider.phoneController,
                  label: 'PHONE NUMBER',
                  hint: '+92 300 1234567',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationInstruction(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 8),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 16,
              ),
              prefixIcon: Icon(icon, color: AppColors.textSecondary),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(ThemeData theme, AuthProvider provider) {
    final currentStep = provider.currentSignupStep;
    final isLoading = provider.isLoading;

    return Row(
      children: [
        if (currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : () {
                if (currentStep == 2) {
                  provider.previousSignupStep();
                } else {
                  provider.previousSignupStep();
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('BACK'),
            ),
          ),
        if (currentStep > 0) const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : () => _handleStepAction(provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(_getButtonText(currentStep)),
            ),
          ),
        ),
      ],
    );
  }

  String _getButtonText(int step) {
    switch (step) {
      case 0:
        return 'CREATE ACCOUNT';
      case 1:
        return 'I\'VE VERIFIED';
      default:
        return 'COMPLETE PROFILE';
    }
  }

  Future<void> _handleStepAction(AuthProvider provider) async {
    final currentStep = provider.currentSignupStep;

    if (currentStep == 0) {
      // Validate account info
      if (provider.signupFullNameController.text.isEmpty) {
        _showError('Please enter your full name');
        return;
      }
      if (provider.signupEmailController.text.isEmpty) {
        _showError('Please enter your email');
        return;
      }
      if (provider.signupPasswordController.text.isEmpty) {
        _showError('Please enter a password');
        return;
      }
      if (provider.signupPasswordController.text != provider.confirmPasswordController.text) {
        _showError('Passwords do not match');
        return;
      }
      if (!provider.agreedToTerms) {
        _showError('Please agree to the terms and conditions');
        return;
      }

      // Save data and create account
      provider.saveStep1Data();

      // Create the user account first (this will send verification email)
      final userCreated = await provider.createUserAccount();

      if (userCreated && mounted) {
        // Move to verification step
        provider.nextSignupStep();
      } else if (!userCreated && mounted) {
        _showError(provider.errorMessage ?? 'Failed to create account');
      }
      return;
    }

    if (currentStep == 1) {
      // Check if user has verified their email
      final isVerified = await provider.checkEmailVerification();

      if (isVerified && mounted) {
        // Move to profile completion step
        provider.nextSignupStep();
      } else if (!isVerified && mounted) {
        _showError('Please verify your email before continuing. Check your inbox and spam folder.');
      }
      return;
    }

    if (currentStep == 2) {
      // Validate and complete profile
      if (provider.studentIdController.text.isEmpty) {
        _showError('Please enter your student ID');
        return;
      }
      if (provider.departmentController.text.isEmpty) {
        _showError('Please enter your department');
        return;
      }

      final success = await provider.completeUserProfile();

      if (success && mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
      } else if (!success && mounted) {
        _showError(provider.errorMessage ?? 'Failed to complete profile');
      }
    }
  }
}

class MeshGradientPainter extends CustomPainter {
  final double animation;

  MeshGradientPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      final offset = animation * 2 * math.pi + (i * 2 * math.pi / 3);
      final center = Offset(
        size.width * 0.5 + math.cos(offset) * size.width * 0.3,
        size.height * 0.5 + math.sin(offset) * size.height * 0.3,
      );

      paint.shader = RadialGradient(
        center: Alignment.center,
        radius: 1.5,
        colors: [
          AppColors.primary.withOpacity(0.3 - i * 0.1),
          AppColors.primaryDark.withOpacity(0.2 - i * 0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.6));

      canvas.drawCircle(center, size.width * 0.6, paint);
    }

    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.background,
        AppColors.background.withOpacity(0.8),
        AppColors.background,
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(MeshGradientPainter oldDelegate) => true;
}