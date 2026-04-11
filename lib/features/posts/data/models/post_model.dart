import '../../domain/entities/post.dart';

class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.authorId,
    required super.postType,
    required super.title,
    required super.description,
    super.projectDomain,
    required super.teamSize,
    super.currentTeamSize,
    super.deadline,
    super.duration,
    super.lookingFor,
    super.selectedSkills,
    super.status,
    super.isPublished,
    super.viewCount,
    super.matchScore,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      postType: _convertToDbCategory(json['type'] as String? ?? 'other'),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      projectDomain: json['type'] as String?, // Store the original display type
      teamSize: json['teamSize'] as int? ?? 1,
      currentTeamSize: json['currentMembers'] as int? ?? 1,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      duration: json['duration'] as String? ?? 'Not specified',
      lookingFor: (json['lookingFor'] as List<dynamic>?)
          ?.map((role) => role as String)
          .toList() ??
          [],
      selectedSkills: (json['requiredSkills'] as List<dynamic>?)
          ?.map((skill) => skill['name'] as String)
          .toList() ??
          [],
      status: 'open',
      isPublished: true,
      viewCount: json['viewCount'] as int? ?? 0,
      matchScore: json['matchScore'] as int? ?? 0,
      createdAt: _parseTimePosted(json['timePosted'] as String?),
      updatedAt: _parseTimePosted(json['timePosted'] as String?),
    );
  }

  factory PostModel.fromEntity(Post entity) {
    return PostModel(
      id: entity.id,
      authorId: entity.authorId,
      postType: entity.postType,
      title: entity.title,
      description: entity.description,
      projectDomain: entity.projectDomain,
      teamSize: entity.teamSize,
      currentTeamSize: entity.currentTeamSize,
      deadline: entity.deadline,
      duration: entity.duration,
      lookingFor: entity.lookingFor,
      selectedSkills: entity.selectedSkills,
      status: entity.status,
      isPublished: entity.isPublished,
      viewCount: entity.viewCount,
      matchScore: entity.matchScore,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Post toEntity() {
    return Post(
      id: id,
      authorId: authorId,
      postType: postType,
      title: title,
      description: description,
      projectDomain: projectDomain,
      teamSize: teamSize,
      currentTeamSize: currentTeamSize,
      deadline: deadline,
      duration: duration,
      lookingFor: lookingFor,
      selectedSkills: selectedSkills,
      status: status,
      isPublished: isPublished,
      viewCount: viewCount,
      matchScore: matchScore,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_id': authorId,
      'category': postType,
      'title': title,
      'description': description,
      'project_domain': projectDomain ?? "General",
      'team_size': teamSize,
      'current_members': currentTeamSize,
      'deadline': deadline?.toIso8601String(),
      'duration': duration,
      'looking_for': lookingFor,
      'selected_skills': selectedSkills,
      'status': status,
      'is_published': isPublished,
      'views_count': viewCount,
      'match_score': matchScore,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper method to convert display type to database category
  static String _convertToDbCategory(String displayType) {
    switch (displayType) {
      case 'FYP Group':
        return 'academic_project';
      case 'Project Partner':
        return 'startup';
      case 'Research':
        return 'research';
      case 'Hackathon':
        return 'hackathon';
      case 'Competition':
        return 'competition';
      case 'Study Group':
        return 'study_group';
      default:
        return 'other';
    }
  }

  // Helper method to parse timePosted string to DateTime
  static DateTime _parseTimePosted(String? timePosted) {
    if (timePosted == null) return DateTime.now();

    final now = DateTime.now();
    final parts = timePosted.split(' ');

    if (parts.length >= 2) {
      final value = int.tryParse(parts[0]);
      if (value != null) {
        final unit = parts[1];
        if (unit.contains('day')) {
          return now.subtract(Duration(days: value));
        } else if (unit.contains('hour')) {
          return now.subtract(Duration(hours: value));
        } else if (unit.contains('minute')) {
          return now.subtract(Duration(minutes: value));
        }
      }
    }

    return now;
  }
}