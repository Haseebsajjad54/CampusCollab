class PostTransformer {
  // Transform single post to mock format
  static Map<String, dynamic> toMockFormat(Map<String, dynamic> dbPost) {
    // Get author data
    final author = dbPost['author'] as Map<String, dynamic>;

    // Transform required skills
    final requiredSkills = (dbPost['post_skills'] as List?)
        ?.map((skillRelation) {
      final skill = skillRelation['skill'] as Map<String, dynamic>;
      return {
        'name': skill['name'],
        'mandatory': skillRelation['is_required'] ?? false,
      };
    })
        .toList() ?? [];

    // Get looking for roles (if stored in post)
    final lookingFor = (dbPost['looking_for'] as List?)?.cast<String>() ?? [];

    // Calculate match score (you can implement your own logic)
    final matchScore = _calculateMatchScore(dbPost);

    return {
      'id': dbPost['id'],
      'type': _getDisplayCategory(dbPost['category']),
      'title': dbPost['title'],
      'author': author['full_name'],
      'authorId': author['student_id'],
      'selectedSkills': requiredSkills.map((skill) => skill['name']).toList(),
      'authorImage': author['profile_picture_url'] ??
          'https://i.pravatar.cc/150?img=${author['id'].hashCode.abs() % 70}',
      'authorBio': author['bio'] ?? '',
      'department': author['department'] ?? 'Not specified',
      'year': author['year_of_study'] ?? 4,
      'cgpa': author['cgpa']?.toDouble() ?? 3.5,
      'description': dbPost['description'],
      'requiredSkills': requiredSkills,
      'lookingFor': lookingFor,
      'teamSize': dbPost['team_size'] ?? 4,
      'currentMembers': dbPost['current_members'] ?? 1,
      'deadline': dbPost['deadline'],
      'duration': dbPost['duration'] ?? 'Not specified',
      'matchScore': matchScore,
      'timePosted': _formatTimeAgo(DateTime.parse(dbPost['created_at'])),
      'viewCount': dbPost['views_count'] ?? 0,
      'applicationCount': _getApplicationCount(dbPost['applications']),
    };
  }

  // Transform list of posts
  static List<Map<String, dynamic>> toMockFormatList(List<Map<String, dynamic>> dbPosts) {
    return dbPosts.map((post) => toMockFormat(post)).toList();
  }

  // Helper: Get application count
  static int _getApplicationCount(dynamic applications) {
    if (applications == null) return 0;
    if (applications is List) return applications.length;
    if (applications is Map && applications.containsKey('count')) {
      return applications['count'] as int;
    }
    return 0;
  }

  // Helper: Format time ago
  static String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${difference.inDays ~/ 7} weeks ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  // Helper: Convert database category to display type
  static String _getDisplayCategory(String category) {
    switch (category) {
      case 'academic_project':
        return 'FYP Group';
      case 'research':
        return 'Research';
      case 'hackathon':
        return 'Hackathon';
      case 'startup':
        return 'Startup';
      case 'competition':
        return 'Competition';
      case 'study_group':
        return 'Study Group';
      default:
        return category;
    }
  }

  // Helper: Calculate match score (implement your logic)
  static int _calculateMatchScore(Map<String, dynamic> post) {
    // This is a placeholder - implement your matching algorithm
    // You could compare user skills with post requirements
    return 85; // Return a score between 0-100
  }
}

// Add looking_for field to posts table if not exists (run this SQL)
/*
ALTER TABLE posts
ADD COLUMN IF NOT EXISTS looking_for TEXT[] DEFAULT '{}';

ALTER TABLE posts
ADD COLUMN IF NOT EXISTS current_members INTEGER DEFAULT 1;

ALTER TABLE posts
ADD COLUMN IF NOT EXISTS duration TEXT;
*/