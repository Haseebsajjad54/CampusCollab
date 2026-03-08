import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

/// Auth State Status
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Improved Auth Provider with Error Handling
class AuthProvider extends ChangeNotifier {
  final SignUpUseCase signUpUseCase;
  final SignInUseCase signInUseCase;
  final SignOutUseCase signOutUseCase;

  AppUser? _user;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;

  AuthProvider({
    required this.signUpUseCase,
    required this.signInUseCase,
    required this.signOutUseCase,
  });

  // Getters
  AppUser? get user => _user;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _user != null;

  /// Sign Up with Error Handling
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      // Call use case (it should validate)
      _user = await signUpUseCase(
        email: email,
        password: password,
        fullName: fullName,
      );

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Sign In with Error Handling
  Future<bool> signIn( {
    required String email,
    required String password,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      _user = await signInUseCase.call( email, password);

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      print(_errorMessage);
      notifyListeners();
      return false;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      await signOutUseCase();
      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Clear Error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future verifyEmail({required String email, required String token}) async {
    // TODO: Implement email verification via Supabase
    return true;
  }

  Future<bool> sendPasswordResetEmail(String trim) async {

    return true;

  }
}