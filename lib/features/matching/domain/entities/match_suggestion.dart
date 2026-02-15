import 'package:equatable/equatable.dart';

/// Match Suggestion Entity
///
/// Represents a potential match with another user
class MatchSuggestion extends Equatable {
  final String id;
  final String userId;
  final String fullName;
  final String? profilePictureUrl;
  final String? department;
  final int? yearOfStudy;
  final double? cgpa;
  final String? bio;
  final String availabilityStatus;
  final int? preferredTeamSize;

  // Match score details
  final double matchScore; // 0.0 to 1.0 (0% to 100%)
  final List<String> sharedSkills;
  final List<String> sharedInterests;
  final Map<String, dynamic> matchReasons;

  // Social links
  final String? linkedinUrl;
  final String? githubUrl;
  final String? portfolioUrl;

  // Additional data
  final int totalPosts;
  final int totalProjects;
  final DateTime createdAt;

  const MatchSuggestion({
    required this.id,
    required this.userId,
    required this.fullName,
    this.profilePictureUrl,
    this.department,
    this.yearOfStudy,
    this.cgpa,
    this.bio,
    required this.availabilityStatus,
    this.preferredTeamSize,
    required this.matchScore,
    required this.sharedSkills,
    required this.sharedInterests,
    required this.matchReasons,
    this.linkedinUrl,
    this.githubUrl,
    this.portfolioUrl,
    this.totalPosts = 0,
    this.totalProjects = 0,
    required this.createdAt,
  });

  /// Get match percentage (0-100)
  int get matchPercentage => (matchScore * 100).round();

  /// Check if high match (>80%)
  bool get isHighMatch => matchScore >= 0.8;

  /// Check if medium match (60-80%)
  bool get isMediumMatch => matchScore >= 0.6 && matchScore < 0.8;

  /// Check if low match (<60%)
  bool get isLowMatch => matchScore < 0.6;

  /// Get match quality text
  String get matchQuality {
    if (isHighMatch) return 'Excellent Match';
    if (isMediumMatch) return 'Good Match';
    return 'Fair Match';
  }

  /// Check if user is available
  bool get isAvailable => availabilityStatus == 'available';

  MatchSuggestion copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? profilePictureUrl,
    String? department,
    int? yearOfStudy,
    double? cgpa,
    String? bio,
    String? availabilityStatus,
    int? preferredTeamSize,
    double? matchScore,
    List<String>? sharedSkills,
    List<String>? sharedInterests,
    Map<String, dynamic>? matchReasons,
    String? linkedinUrl,
    String? githubUrl,
    String? portfolioUrl,
    int? totalPosts,
    int? totalProjects,
    DateTime? createdAt,
  }) {
    return MatchSuggestion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      department: department ?? this.department,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      cgpa: cgpa ?? this.cgpa,
      bio: bio ?? this.bio,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      preferredTeamSize: preferredTeamSize ?? this.preferredTeamSize,
      matchScore: matchScore ?? this.matchScore,
      sharedSkills: sharedSkills ?? this.sharedSkills,
      sharedInterests: sharedInterests ?? this.sharedInterests,
      matchReasons: matchReasons ?? this.matchReasons,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      totalPosts: totalPosts ?? this.totalPosts,
      totalProjects: totalProjects ?? this.totalProjects,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    fullName,
    profilePictureUrl,
    department,
    yearOfStudy,
    cgpa,
    bio,
    availabilityStatus,
    preferredTeamSize,
    matchScore,
    sharedSkills,
    sharedInterests,
    matchReasons,
    linkedinUrl,
    githubUrl,
    portfolioUrl,
    totalPosts,
    totalProjects,
    createdAt,
  ];
}