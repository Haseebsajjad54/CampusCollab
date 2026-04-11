import 'package:equatable/equatable.dart';

/// Profile Entity - Domain Layer
///
/// Complete user profile information
class Profile extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? studentId;
  final String? department;
  final int? yearOfStudy;
  final double? cgpa;
  final String? bio;
  final String? profilePictureUrl;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? portfolioUrl;
  final String? phoneNumber;
  final String availabilityStatus;
  final int? preferredTeamSize;
  final List<String> skills;
  final List<String> interests;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.id,
    required this.email,
    required this.fullName,
    this.studentId,
    this.department,
    this.yearOfStudy,
    this.cgpa,
    this.bio,
    this.profilePictureUrl,
    this.linkedinUrl,
    this.githubUrl,
    this.portfolioUrl,
    this.phoneNumber,
    this.availabilityStatus = 'available',
    this.preferredTeamSize,
    this.skills = const [],
    this.interests = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if profile is complete
  bool get isComplete {
    return studentId != null &&
        department != null &&
        yearOfStudy != null &&
        bio != null &&
        bio!.isNotEmpty &&
        skills.isNotEmpty;
  }

  /// Get completion percentage
  int get completionPercentage {
    int completed = 0;
    const int total = 10;

    if (fullName.isNotEmpty) completed++;
    if (studentId != null) completed++;
    if (department != null) completed++;
    if (yearOfStudy != null) completed++;
    if (cgpa != null) completed++;
    if (bio != null && bio!.isNotEmpty) completed++;
    if (profilePictureUrl != null) completed++;
    if (skills.isNotEmpty) completed++;
    if (interests.isNotEmpty) completed++;
    if (phoneNumber != null) completed++;

    return ((completed / total) * 100).round();
  }

  /// Check if available
  bool get isAvailable => availabilityStatus == 'available';

  Profile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? studentId,
    String? department,
    int? yearOfStudy,
    double? cgpa,
    String? bio,
    String? profilePictureUrl,
    String? linkedinUrl,
    String? githubUrl,
    String? portfolioUrl,
    String? phoneNumber,
    String? availabilityStatus,
    int? preferredTeamSize,
    List<String>? skills,
    List<String>? interests,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      studentId: studentId ?? this.studentId,
      department: department ?? this.department,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      cgpa: cgpa ?? this.cgpa,
      bio: bio ?? this.bio,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      preferredTeamSize: preferredTeamSize ?? this.preferredTeamSize,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    studentId,
    department,
    yearOfStudy,
    cgpa,
    bio,
    profilePictureUrl,
    linkedinUrl,
    githubUrl,
    portfolioUrl,
    phoneNumber,
    availabilityStatus,
    preferredTeamSize,
    skills,
    interests,
    createdAt,
    updatedAt,
  ];
  /// All the getters of this profile class


}