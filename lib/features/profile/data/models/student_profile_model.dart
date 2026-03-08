import '../../domain/entities/student_profile.dart';

/// Profile Data Model - Data Layer
class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.studentId,
    super.department,
    super.yearOfStudy,
    super.cgpa,
    super.bio,
    super.profilePictureUrl,
    super.linkedinUrl,
    super.githubUrl,
    super.portfolioUrl,
    super.phoneNumber,
    super.availabilityStatus,
    super.preferredTeamSize,
    super.skills,
    super.interests,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Convert JSON (from Supabase or API) to ProfileModel
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      studentId: json['student_id'] as String?,
      department: json['department'] as String?,
      yearOfStudy: json['year_of_study'] as int?,
      cgpa: (json['cgpa'] != null)
          ? double.tryParse(json['cgpa'].toString())
          : null,
      bio: json['bio'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      linkedinUrl: json['linkedin_url'] as String?,
      githubUrl: json['github_url'] as String?,
      portfolioUrl: json['portfolio_url'] as String?,
      phoneNumber: json['phone_number'] as String?,
      availabilityStatus: json['availability_status'] as String? ?? 'available',
      preferredTeamSize: json['preferred_team_size'] as int?,
      skills: (json['skills'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      interests: (json['interests'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert ProfileModel to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'student_id': studentId,
      'department': department,
      'year_of_study': yearOfStudy,
      'cgpa': cgpa,
      'bio': bio,
      'profile_picture_url': profilePictureUrl,
      'linkedin_url': linkedinUrl,
      'github_url': githubUrl,
      'portfolio_url': portfolioUrl,
      'phone_number': phoneNumber,
      'availability_status': availabilityStatus,
      'preferred_team_size': preferredTeamSize,
      'skills': skills,
      'interests': interests,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  factory ProfileModel.fromEntity(Profile entity) {
    return ProfileModel(
      id: entity.id,
      email: entity.email,
      fullName: entity.fullName,
      studentId: entity.studentId,
      department: entity.department,
      yearOfStudy: entity.yearOfStudy,
      cgpa: entity.cgpa,
      bio: entity.bio,
      profilePictureUrl: entity.profilePictureUrl,
      linkedinUrl: entity.linkedinUrl,
      githubUrl: entity.githubUrl,
      portfolioUrl: entity.portfolioUrl,
      phoneNumber: entity.phoneNumber,
      availabilityStatus: entity.availabilityStatus,
      preferredTeamSize: entity.preferredTeamSize,
      skills: entity.skills,
      interests: entity.interests,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
