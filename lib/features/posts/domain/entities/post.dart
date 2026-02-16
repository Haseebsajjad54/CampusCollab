import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final String id;
  final String authorId;
  final String postType; // project_partner, fyp_group
  final String title;
  final String description;
  final String? projectDomain; // AI, Web, Mobile, IoT, etc.
  final int? requiredTeamSize;
  final int currentTeamSize;
  final DateTime? deadline;
  final String status; // open, in_progress, closed, completed
  final bool isPublished;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Post({
    required this.id,
    required this.authorId,
    required this.postType,
    required this.title,
    required this.description,
    this.projectDomain,
    this.requiredTeamSize,
    this.currentTeamSize = 1,
    this.deadline,
    this.status = 'open',
    this.isPublished = true,
    this.viewCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    authorId,
    postType,
    title,
    description,
    projectDomain,
    requiredTeamSize,
    currentTeamSize,
    deadline,
    status,
    isPublished,
    viewCount,
    createdAt,
    updatedAt,
  ];
}
