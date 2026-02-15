import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/student_profile.dart';

/// Profile Repository Interface
///
/// Defines contract for profile operations
abstract class ProfileRepository {
  /// Get current user's profile
  Future<Either<Failure, Profile>> getCurrentProfile();

  /// Get profile by user ID
  Future<Either<Failure, Profile>> getProfileById(String userId);

  /// Update profile information
  Future<Either<Failure, Profile>> updateProfile(Profile profile);

  /// Upload profile picture
  Future<Either<Failure, String>> uploadProfilePicture(File image);

  /// Add skill to profile
  Future<Either<Failure, void>> addSkill(String skillName);

  /// Remove skill from profile
  Future<Either<Failure, void>> removeSkill(String skillName);

  /// Add interest to profile
  Future<Either<Failure, void>> addInterest(String interestName);

  /// Remove interest from profile
  Future<Either<Failure, void>> removeInterest(String interestName);

  /// Update availability status
  Future<Either<Failure, void>> updateAvailability(String status);

  /// Get user statistics
  Future<Either<Failure, Map<String, int>>> getUserStats(String userId);
}