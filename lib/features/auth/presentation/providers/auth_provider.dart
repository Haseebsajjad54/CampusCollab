import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';

class AuthProvider extends ChangeNotifier {
  final SignUpUseCase signUpUseCase;
  final SignInUseCase signInUseCase;
  final SignOutUseCase signOutUseCase;

  AppUser? _user;
  bool _isLoading = false;

  AuthProvider({
    required this.signUpUseCase,
    required this.signInUseCase,
    required this.signOutUseCase,
  });

  AppUser? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> signUp(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    _user = await signUpUseCase(email, password);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    _user = await signInUseCase(email, password);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await signOutUseCase();
    _user = null;
    notifyListeners();
  }
}
