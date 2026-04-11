import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  Future<User> signUp(String email, String password, String fullName);
  Future<User> signIn(String email, String password);
  Future<void> signOut();
  User? getCurrentUser();
  Future<Map<String, dynamic>?> getProfile(String userId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient client;

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<User> signUp(String email, String password, String fullName) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName}, // Passed to trigger
    );

    if (response.user == null) {
      throw Exception('Signup failed');
    }

    return response.user!;
  }

  @override
  Future<User> signIn(String email, String password) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Login failed');
    }

    return response.user!;
  }

  @override
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  @override
  User? getCurrentUser() {
    return client.auth.currentUser;
  }

  @override
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    for (int i = 0; i < 3; i++) {
      final profile = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (profile != null) return profile;

      await Future.delayed(Duration(milliseconds: 300));
    }

    return null;
  }
}