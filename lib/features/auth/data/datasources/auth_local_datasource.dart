import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUser();

}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _cachedUserKey = 'CACHED_USER';

  @override
  Future<void> cacheUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(user.toJson());
    await prefs.setString(_cachedUserKey, jsonString);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cachedUserKey);

    if (jsonString == null) return null;

    final jsonMap = jsonDecode(jsonString);
    return UserModel.fromJson(jsonMap);
  }

  @override
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cachedUserKey);
  }


}
