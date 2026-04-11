class Post {
  final String id;
  final String authorId;
  final String postType;
  final String title;
  final String description;
  final String? projectDomain;
  final int teamSize;
  final int currentTeamSize;
  final DateTime? deadline;
  final String? duration;
  final List<String> lookingFor;
  final List<String> selectedSkills;
  final String? status;
  final bool? isPublished;
  final int viewCount;
  final int matchScore;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Post({
    required this.id,
    required this.authorId,
    required this.postType,
    required this.title,
    required this.description,
    this.projectDomain,
    required this.teamSize,
    this.currentTeamSize = 1,
    this.deadline,
    this.duration,
    this.lookingFor = const [],
    this.selectedSkills = const [],
    this.status = 'open',
    this.isPublished = true,
    this.viewCount = 0,
    this.matchScore = 0,
    required this.createdAt,
    required this.updatedAt,
  });
}