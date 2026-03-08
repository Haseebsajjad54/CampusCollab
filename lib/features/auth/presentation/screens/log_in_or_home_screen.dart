import 'package:campus_collab/app.dart';
import 'package:campus_collab/features/auth/presentation/providers/auth_provider.dart';
import 'package:campus_collab/features/posts/presentation/screens/post_feed_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';

class LogInOrHomeScreen extends StatelessWidget {
  const LogInOrHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    // Access the provider
    final provider = Provider.of<AuthProvider>(context);

    // Decide which screen to show
    if (provider.user == null) {
      return const LoginScreen();
    } else {
      return const MainScreen();
    }
  }
}
