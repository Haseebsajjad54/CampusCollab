import '../../domain/entities/match_suggestion.dart';

class MatchSuggestionModel extends MatchSuggestion {
  const MatchSuggestionModel({
    required super.id,
    required super.userId,
    required super.fullName,
    super.profilePictureUrl,
    super.department,
    super.yearOfStudy,
    super.cgpa,
    super.bio,
    required super.availabilityStatus,
    super.preferredTeamSize,
    required super.matchScore,
    required super.sharedSkills,
    required super.sharedInterests,
    required super.matchReasons,
    super.linkedinUrl,
    super.githubUrl,
    super.portfolioUrl,
    super.totalPosts = 0,
    super.totalProjects = 0,
    required super.createdAt,
  });

  /// Convert JSON to Model
  factory MatchSuggestionModel.fromJson(Map<String, dynamic> json) {
    return MatchSuggestionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      profilePictureUrl: json['profile_picture_url'] as String?,
      department: json['department'] as String?,
      yearOfStudy: json['year_of_study'] as int?,
      cgpa: (json['cgpa'] as num?)?.toDouble(),
      bio: json['bio'] as String?,
      availabilityStatus: json['availability_status'] as String? ?? 'unavailable',
      preferredTeamSize: json['preferred_team_size'] as int?,
      matchScore: (json['match_score'] as num).toDouble(),
      sharedSkills: List<String>.from(json['shared_skills'] ?? []),
      sharedInterests: List<String>.from(json['shared_interests'] ?? []),
      matchReasons: Map<String, dynamic>.from(json['match_reasons'] ?? {}),
      linkedinUrl: json['linkedin_url'] as String?,
      githubUrl: json['github_url'] as String?,
      portfolioUrl: json['portfolio_url'] as String?,
      totalPosts: json['total_posts'] as int? ?? 0,
      totalProjects: json['total_projects'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert Model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'profile_picture_url': profilePictureUrl,
      'department': department,
      'year_of_study': yearOfStudy,
      'cgpa': cgpa,
      'bio': bio,
      'availability_status': availabilityStatus,
      'preferred_team_size': preferredTeamSize,
      'match_score': matchScore,
      'shared_skills': sharedSkills,
      'shared_interests': sharedInterests,
      'match_reasons': matchReasons,
      'linkedin_url': linkedinUrl,
      'github_url': githubUrl,
      'portfolio_url': portfolioUrl,
      'total_posts': totalPosts,
      'total_projects': totalProjects,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert Model to Entity (optional but useful in repository)
  MatchSuggestion toEntity() {
    return MatchSuggestion(
      id: id,
      userId: userId,
      fullName: fullName,
      profilePictureUrl: profilePictureUrl,
      department: department,
      yearOfStudy: yearOfStudy,
      cgpa: cgpa,
      bio: bio,
      availabilityStatus: availabilityStatus,
      preferredTeamSize: preferredTeamSize,
      matchScore: matchScore,
      sharedSkills: sharedSkills,
      sharedInterests: sharedInterests,
      matchReasons: matchReasons,
      linkedinUrl: linkedinUrl,
      githubUrl: githubUrl,
      portfolioUrl: portfolioUrl,
      totalPosts: totalPosts,
      totalProjects: totalProjects,
      createdAt: createdAt,
    );
  }
}
