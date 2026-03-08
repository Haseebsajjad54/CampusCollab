import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/config/theme/app_colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with TickerProviderStateMixin {
  late AnimationController _meshController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;

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
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Animated mesh background
          AnimatedBuilder(
            animation: _meshController,
            builder: (context, child) {
              return CustomPaint(
                size: size,
                painter: MeshGradientPainter(_meshController.value),
              );
            },
          ),

          // Noise overlay
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

          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.12),

                    // Header: Logo & App Name
                    _buildHeader(theme),

                    const SizedBox(height: 40),

                    // Glass card with signup form
                    _buildSignUpCard(theme),

                    const SizedBox(height: 24),

                    // Already have an account
                    _buildSignInLink(theme),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
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
            'PartnerFind',
            style: theme.textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Connect. Collaborate. Create.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpCard(ThemeData theme) {
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
                Text('Create Account', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('Sign up to find your perfect project partners',
                    style: theme.textTheme.bodyMedium),

                const SizedBox(height: 32),

                // Full Name
                _buildTextField(
                  controller: _fullNameController,
                  label: 'FULL NAME',
                  hint: 'Enter your full name',
                  icon: Icons.person_outline,
                ),

                const SizedBox(height: 20),

                // Email
                _buildTextField(
                  controller: _emailController,
                  label: 'EMAIL',
                  hint: 'Enter your university email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 20),

                // Password
                _buildTextField(
                  controller: _passwordController,
                  label: 'PASSWORD',
                  hint: 'Create a password',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),

                const SizedBox(height: 20),

                // Confirm Password
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'CONFIRM PASSWORD',
                  hint: 'Re-enter your password',
                  icon: Icons.lock_outline,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),

                const SizedBox(height: 24),

                // Terms
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreedToTerms,
                        onChanged: (value) =>
                            setState(() => _agreedToTerms = value ?? false),
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                        child: Text(
                          'I agree to the Terms & Conditions and Privacy Policy',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      gradient: _isLoading ? null : AppColors.primaryGradient,
                      color: _isLoading ? AppColors.surface : null,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _isLoading
                          ? null
                          : [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading ? null : _handleSignUp,
                        borderRadius: BorderRadius.circular(16),
                        child: Center(
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : Text(
                            'SIGN UP',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInLink(ThemeData theme) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Already have an account? ', style: theme.textTheme.bodyMedium),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              'Sign In',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSignUp() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2)); // simulate API call

    setState(() => _isLoading = false);

    // navigate to home or email verification
  }
}

// Same MeshGradientPainter as in LoginScreen
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
