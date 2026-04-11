//  final postId = widget.post['id'] as String? ?? '';
//     final title = widget.post['title'] as String? ?? '';
//     final description = widget.post['description'] as String? ?? '';
//     final postType = widget.post['post_type'] as String? ?? 'project';
//     final teamSize = widget.post['team_size'] as int? ?? 3;
//     final currentTeamSize = widget.post['current_team_size'] as int? ?? 1;
//     final requiredTeamSize = widget.post['required_team_size'] as int? ?? 5;
//     final matchScore = widget.post['match_score'] as int? ?? 0;
//     final deadline = widget.post['deadline'] as String? ?? '';
//     List<String> selectedSkills = [];
//     final skillsData = widget.post['selected_skills'];
//     if (skillsData != null && skillsData is List) {
//       selectedSkills = skillsData.map((skill) => skill.toString()).toList();
//     }
//
//     final authorName = widget.post['author_name'] as String? ?? 'Unknown User';
//     final authorImage = widget.post['author_image'] as String? ?? '';
//     final authorDepartment = widget.post['department'] as String? ?? 'Computer Science';
//     final authorYear = widget.post['year'] as int? ?? widget.post['year_of_study'] as int? ?? 2026;
//
//     final timePosted = _formatTimePosted(widget.post['created_at'] as String?);