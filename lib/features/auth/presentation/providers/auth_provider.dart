import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../shared/services/conectivity.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
  unverified,
  uncompleted,
  verified,
  completed,
}

class AuthProvider extends ChangeNotifier {
  final SignUpUseCase signUpUseCase;
  final SignInUseCase signInUseCase;
  final SignOutUseCase signOutUseCase;
  final SupabaseClient client;
  final AuthLocalDataSource authLocalDataSource;

  AppUser? _user;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  String? _pendingEmail;
  bool _isEmailSent = false;

  // Signup step management
  int _currentSignupStep = 0;

  // Login state
  bool _obscureLoginPassword = true;

  // Signup form data
  final Map<String, dynamic> _signupFormData = {};

  // Signup UI state
  bool _obscureSignupPassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  int _yearOfStudy = 1;
  double _cgpa = 0.0;
  int _preferredTeamSize = 3;
  String _availabilityStatus = 'available';
  List<String> _selectedSkills = [];
  List<String> _availableSkills = [];

  // Text controllers (managed by provider)
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  final TextEditingController forgotEmailController = TextEditingController();
  final TextEditingController signupFullNameController = TextEditingController();
  final TextEditingController signupEmailController = TextEditingController();
  final TextEditingController signupPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController linkedinController = TextEditingController();
  final TextEditingController githubController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cgpaController = TextEditingController();

  AuthProvider({
    required this.signUpUseCase,
    required this.signInUseCase,
    required this.signOutUseCase,
    required this.client,
    required this.authLocalDataSource,
  }) {
    _loadSkills();
  }

  // Getters
  AppUser? get user => _user;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _user != null;
  bool get isEmailSent => _isEmailSent;
  String? get pendingEmail => _pendingEmail;
  int get currentSignupStep => _currentSignupStep;
  bool get obscureLoginPassword => _obscureLoginPassword;
  bool get obscureSignupPassword => _obscureSignupPassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get agreedToTerms => _agreedToTerms;
  int get yearOfStudy => _yearOfStudy;
  double get cgpa => _cgpa;
  int get preferredTeamSize => _preferredTeamSize;
  String get availabilityStatus => _availabilityStatus;
  List<String> get selectedSkills => _selectedSkills;
  List<String> get availableSkills => _availableSkills;

  Map<String, dynamic> get signupFormData => _signupFormData;

  // Setters with notifyListeners
  void toggleLoginPasswordVisibility() {
    _obscureLoginPassword = !_obscureLoginPassword;
    notifyListeners();
  }

  void toggleSignupPasswordVisibility() {
    _obscureSignupPassword = !_obscureSignupPassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  void setAgreedToTerms(bool value) {
    _agreedToTerms = value;
    notifyListeners();
  }

  // In AuthProvider, add this method for CGPA
  void setCgpaFromController() {
    final value = double.tryParse(cgpaController.text) ?? 0.0;
    if (_cgpa != value) {
      _cgpa = value;
      notifyListeners();
    }
  }

// For dropdown fields - only notify when value actually changes
  void setYearOfStudy(int value) {
    if (_yearOfStudy != value) {
      _yearOfStudy = value;
      notifyListeners();
    }
  }

  void setPreferredTeamSize(int value) {
    if (_preferredTeamSize != value) {
      _preferredTeamSize = value;
      notifyListeners();
    }
  }

  void setAvailabilityStatus(String value) {
    if (_availabilityStatus != value) {
      _availabilityStatus = value;
      notifyListeners();
    }
  }

// For skill toggles - already fine
  void toggleSkill(String skill) {
    if (_selectedSkills.contains(skill)) {
      _selectedSkills.remove(skill);
    } else {
      _selectedSkills.add(skill);
    }
    notifyListeners();
  }

  void setEmailSent(bool value) {
    _isEmailSent = value;
    notifyListeners();
  }

  void nextSignupStep() {
    _currentSignupStep++;
    notifyListeners();
  }

  void previousSignupStep() {
    if (_currentSignupStep > 0) {
      _currentSignupStep--;
      notifyListeners();
    }
  }

  void resetSignupStep() {
    _currentSignupStep = 0;
    _isEmailSent = false;
    _pendingEmail = null;
    _clearSignupForm();
    notifyListeners();
  }

  void _clearSignupForm() {
    _signupFormData.clear();
    _selectedSkills.clear();
    _yearOfStudy = 1;
    _cgpa = 0.0;
    _preferredTeamSize = 3;
    _availabilityStatus = 'available';
    _agreedToTerms = false;

    // Clear controllers
    signupFullNameController.clear();
    signupEmailController.clear();
    signupPasswordController.clear();
    confirmPasswordController.clear();
    studentIdController.clear();
    departmentController.clear();
    bioController.clear();
    linkedinController.clear();
    githubController.clear();
    phoneController.clear();
    cgpaController.clear();
  }

  void saveStep1Data() {
    _signupFormData['fullName'] = signupFullNameController.text.trim();
    _signupFormData['email'] = signupEmailController.text.trim();
    _signupFormData['password'] = signupPasswordController.text;
    _pendingEmail = signupEmailController.text.trim();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _loadSkills() async {
    try {
      final response = await client.from('skills').select('name');
      _availableSkills = response.map<String>((s) => s['name'] as String).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading skills: $e');
    }
  }

  // In AuthProvider, add these methods:

  Future<bool> createUserAccount() async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final email = _signupFormData['email'];
      final password = _signupFormData['password'];
      final fullName = _signupFormData['fullName'];

      // Sign up the user (this sends verification email automatically)
      final signUpResult = await signUpUseCase.call(
        email: email,
        password: password,
        fullName: fullName,
      );

      _user = signUpResult;
      _pendingEmail = email;

      _status = AuthStatus.unverified;
      notifyListeners();
      return true;

    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkEmailVerification() async {
    try {
      // Refresh user session to check verification status
      await client.auth.refreshSession();
      final user = client.auth.currentUser;

      if (user != null && user.emailConfirmedAt != null) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> completeUserProfile() async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final user = client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final profileData = {
        'id': user.id,
        'email': user.email,
        'full_name': _signupFormData['fullName'],
        'student_id': studentIdController.text.trim(),
        'department': departmentController.text.trim(),
        'year_of_study': _yearOfStudy,
        'cgpa': _cgpa,
        'bio': bioController.text.trim().isEmpty ? null : bioController.text.trim(),
        'linkedin_url': linkedinController.text.trim().isEmpty ? null : linkedinController.text.trim(),
        'github_url': githubController.text.trim().isEmpty ? null : githubController.text.trim(),
        'phone_number': phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        'availability_status': _availabilityStatus,
        'preferred_team_size': _preferredTeamSize,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await client.from('profiles').insert(profileData).select().single();

      if (_selectedSkills.isNotEmpty) {
        await _addSkills(user.id, _selectedSkills);
      }

      // Cache user data
      if (_user != null) {
        await authLocalDataSource.cacheUser(UserModel.fromEntity(_user!));
      }

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;

    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  // In AuthProvider
  Future<void> resendVerificationEmail(BuildContext context) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final email = _pendingEmail ?? _signupFormData['email'];
      await client.auth.resend(email: email, type: OtpType.email);

      _status = AuthStatus.unverified;
      notifyListeners();

      // Use the passed context
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification email resent! Check your inbox.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      _errorMessage = _parseError(e);
      notifyListeners();

      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage ?? 'Failed to resend verification email'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<bool> signIn() async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final email = loginEmailController.text.trim();
      final password = loginPasswordController.text;

      final result = await signInUseCase.call(email, password).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Connection timeout.'),
      );

      _user = result;

      if (_user == null) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      await authLocalDataSource.cacheUser(UserModel.fromEntity(_user!));
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;

    } on TimeoutException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Connection timeout. Please check your internet connection.';
      notifyListeners();
      return false;
    } on SocketException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Network error. Please check your internet connection.';
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail() async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final email = forgotEmailController.text.trim();
      await client.auth.resetPasswordForEmail(email);

      _status = AuthStatus.unauthenticated;
      _isEmailSent = true;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  // In your AuthProvider, add this when signing out
  Future<void> signOut() async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      // Clear local data
      await authLocalDataSource.clearUser();
      _user = null;

      // Sign out from Supabase
      await signOutUseCase();

      _status = AuthStatus.unauthenticated;
      notifyListeners();

    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _parseError(e);
      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final cachedUser = await AuthLocalDataSourceImpl().getCachedUser();

    if (cachedUser != null) {
      _user = cachedUser;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<bool> verifyEmail({required String email, required String token}) async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      await client.auth.verifyOTP(
          email: email,
          token: token,
          type: OtpType.email
      );

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> _addSkills(String userId, List<String> skills) async {
    final existingSkills = await client
        .from('skills')
        .select('id, name')
        .inFilter('name', skills);

    final existingNames = existingSkills.map((s) => s['name'] as String).toSet();
    final existingIds = Map.fromEntries(
        existingSkills.map((s) => MapEntry(s['name'] as String, s['id'] as String))
    );

    final newSkills = skills.where((s) => !existingNames.contains(s)).toList();
    if (newSkills.isNotEmpty) {
      final insertedSkills = await client
          .from('skills')
          .insert(newSkills.map((name) => {'name': name, 'category': 'user_added'}).toList())
          .select('id, name');

      for (var skill in insertedSkills) {
        existingIds[skill['name'] as String] = skill['id'] as String;
      }
    }

    final studentSkills = skills.map((skillName) => {
      'student_id': userId,
      'skill_id': existingIds[skillName],
      'proficiency_level': 'intermediate',
    }).toList();

    await client.from('student_skills').insert(studentSkills);
  }

  String _parseError(dynamic error) {
    if (error is AuthException) {
      return error.message;
    } else if (error is PostgrestException) {
      return error.message;
    }
    return error.toString();
  }
}