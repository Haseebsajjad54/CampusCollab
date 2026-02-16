import '../../domain/entities/post.dart';

class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.authorId,
    required super.postType,
    required super.title,
    required super.description,
    super.projectDomain,
    super.requiredTeamSize,
    super.currentTeamSize,
    super.deadline,
    super.status,
    super.isPublished,
    super.viewCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      postType: json['post_type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      projectDomain: json['project_domain'] as String?,
      requiredTeamSize: json['required_team_size'] as int?,
      currentTeamSize: json['current_team_size'] as int? ?? 1,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      status: json['status'] as String? ?? 'open',
      isPublished: json['is_published'] as bool? ?? true,
      viewCount: json['view_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_id': authorId,
      'post_type': postType,
      'title': title,
      'description': description,
      'project_domain': projectDomain,
      'required_team_size': requiredTeamSize,
      'current_team_size': currentTeamSize,
      'deadline': deadline?.toIso8601String(),
      'status': status,
      'is_published': isPublished,
      'view_count': viewCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
