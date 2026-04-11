import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.avatarUrl,
  });

  /// Convert from JSON (Supabase row)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  /// Convert to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
    };
  }

  /// Convert Supabase User object to UserModel
  factory UserModel.fromSupabaseUser(User user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] ?? '',
      avatarUrl: user.userMetadata?['avatar_url'],
    );
  }

  /// Convert Data Model to Domain Entity
  AppUser toDomain() {
    return AppUser(
      id: id,
      email: email,
      fullName: fullName,
      avatarUrl: avatarUrl,
    );
  }

  /// For caching locally
  factory UserModel.fromJsonString(String jsonString) {
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return UserModel.fromJson(jsonMap);
  }

  String toJsonString() => jsonEncode(toJson());

  static UserModel fromEntity(AppUser appUser) {
    return UserModel(
      id: appUser.id,
      email: appUser.email,
      fullName: appUser.fullName,
    );
  }
}
