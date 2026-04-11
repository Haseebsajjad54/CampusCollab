import 'package:campus_collab/app.dart';
import 'package:campus_collab/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';

class LogInOrHomeScreen extends StatelessWidget {
  const LogInOrHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();

    if (provider.status == AuthStatus.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (provider.isAuthenticated) {
      return MainScreen();
    }
    else {
      return const LoginScreen();
    }
  }
}
