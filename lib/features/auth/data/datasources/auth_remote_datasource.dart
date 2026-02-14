import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  Future<User> signUp(String email, String password);
  Future<User> signIn(String email, String password);
  Future<void> signOut();
  User? getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient client;

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<User> signUp(String email, String password) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
    );

    return response.user!;
  }

  @override
  Future<User> signIn(String email, String password) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );

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
}
