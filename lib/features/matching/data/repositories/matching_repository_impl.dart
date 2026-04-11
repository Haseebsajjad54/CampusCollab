import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/match_suggestion.dart';
import '../../domain/repositories/matching_repository.dart';
import '../models/match_suggestion_model.dart';

/// Matching Repository Implementation
///
/// Implements matching algorithm with Supabase
class MatchingRepositoryImpl implements MatchingRepository {
  final SupabaseClient supabaseClient;

  MatchingRepositoryImpl({required this.supabaseClient});

  @override
  Future<Either<Failure, List<MatchSuggestion>>> getMatchSuggestions({
    int limit = 20,
    double minScore = 0.0,
  }) async {
    try {
      final currentUserId = supabaseClient.auth.currentUser?.id;
      if (currentUserId == null) {
        return Left(
          AuthenticationFailure( 'User not authenticated'),
        );
      }

      // Get current user's profile with skills and interests
      final currentProfile = await _getCurrentUserProfile(currentUserId);

      // Get all other users
      final otherUsers = await supabaseClient
          .from('profiles')
          .select()
          .neq('id', currentUserId);

      // Calculate match scores for each user
      final matches = <MatchSuggestionModel>[];

      for (final user in otherUsers) {
        final matchData = await _calculateMatchScore(
          currentProfile,
          user,
        );

        if (matchData['score'] >= minScore) {
          matches.add(matchData['model']);
        }
      }

      // Sort by match score (highest first)
      matches.sort((a, b) => b.matchScore.compareTo(a.matchScore));

      // Limit results
      final limitedMatches = matches.take(limit).toList();

      return Right(limitedMatches);
    } catch (e) {
      return Left(ServerFailure( e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MatchSuggestion>>> getTopMatches() async {
    return await getMatchSuggestions(limit: 10, minScore: 0.5);
  }

  @override
  Future<Either<Failure, double>> getMatchScore(String userId) async {
    try {
      final currentUserId = supabaseClient.auth.currentUser?.id;
      if (currentUserId == null) {
        return const Left(
          AuthenticationFailure( 'User not authenticated'),
        );
      }

      final currentProfile = await _getCurrentUserProfile(currentUserId);
      final otherProfile = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      final matchData = await _calculateMatchScore(
        currentProfile,
        otherProfile,
      );

      return Right(matchData['score']);
    } catch (e) {
      return Left(ServerFailure( e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MatchSuggestion>>> refreshMatches() async {
    // Same as getMatchSuggestions but forces fresh calculation
    return await getMatchSuggestions();
  }

  /// Get current user's complete profile with skills and interests
  Future<Map<String, dynamic>> _getCurrentUserProfile(String userId) async {
    // Get profile
    final profile = await supabaseClient
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    // Get user's skills
    final userSkills = await supabaseClient
        .from('student_skills')
        .select('skills(name)')
        .eq('student_id', userId);

    final skills = userSkills
        .map((s) => (s['skills'] as Map)['name'] as String)
        .toList();

    // Get user's interests
    final userInterests = await supabaseClient
        .from('student_interests')
        .select('interests(name)')
        .eq('student_id', userId);

    final interests = userInterests
        .map((i) => (i['interests'] as Map)['name'] as String)
        .toList();

    return {
      ...profile,
      'user_skills': skills,
      'user_interests': interests,
    };
  }

  /// Calculate match score between two users
  Future<Map<String, dynamic>> _calculateMatchScore(Map<String, dynamic> currentUser, Map<String, dynamic> otherUser,) async {
    double totalScore = 0.0;
    final reasons = <String, dynamic>{};

    // Get other user's skills and interests
    final otherUserId = otherUser['id'];

    final otherSkillsData = await supabaseClient
        .from('student_skills')
        .select('skills(name)')
        .eq('student_id', otherUserId);

    final otherSkills = otherSkillsData
        .map((s) => (s['skills'] as Map)['name'] as String)
        .toList();

    final otherInterestsData = await supabaseClient
        .from('student_interests')
        .select('interests(name)')
        .eq('student_id', otherUserId);

    final otherInterests = otherInterestsData
        .map((i) => (i['interests'] as Map)['name'] as String)
        .toList();

    // 1. Skills Match (40% weight)
    final currentSkills = List<String>.from(currentUser['user_skills'] ?? []);
    final sharedSkills = currentSkills
        .where((skill) => otherSkills.contains(skill))
        .toList();

    if (currentSkills.isNotEmpty) {
      final skillScore = sharedSkills.length / currentSkills.length;
      totalScore += skillScore * 0.4;
      reasons['skills'] = '${sharedSkills.length} shared skills';
    }

    // 2. Interests Match (30% weight)
    final currentInterests = List<String>.from(currentUser['user_interests'] ?? []);
    final sharedInterests = currentInterests
        .where((interest) => otherInterests.contains(interest))
        .toList();

    if (currentInterests.isNotEmpty) {
      final interestScore = sharedInterests.length / currentInterests.length;
      totalScore += interestScore * 0.3;
      reasons['interests'] = '${sharedInterests.length} shared interests';
    }

    // 3. Department Match (10% weight)
    final currentDept = currentUser['department'];
    final otherDept = otherUser['department'];
    if (currentDept != null && otherDept != null && currentDept == otherDept) {
      totalScore += 0.1;
      reasons['department'] = 'Same department';
    }

    // 4. Year Compatibility (10% weight)
    final currentYear = currentUser['year_of_study'] as int?;
    final otherYear = otherUser['year_of_study'] as int?;
    if (currentYear != null && otherYear != null) {
      final yearDiff = (currentYear - otherYear).abs();
      if (yearDiff == 0) {
        totalScore += 0.1;
        reasons['year'] = 'Same year';
      } else if (yearDiff == 1) {
        totalScore += 0.05;
        reasons['year'] = 'Adjacent year';
      }
    }

    // 5. CGPA Range (5% weight)
    final currentCGPA = currentUser['cgpa'] as double?;
    final otherCGPA = otherUser['cgpa'] as double?;
    if (currentCGPA != null && otherCGPA != null) {
      final cgpaDiff = (currentCGPA - otherCGPA).abs();
      if (cgpaDiff <= 0.5) {
        totalScore += 0.05;
        reasons['cgpa'] = 'Similar CGPA';
      }
    }

    // 6. Availability (5% weight)
    if (otherUser['availability_status'] == 'available') {
      totalScore += 0.05;
      reasons['availability'] = 'Currently available';
    }

    // Get total posts count
    final postsCount = await supabaseClient
        .from('posts')
        .select('id')
        .eq('author_id', otherUserId);

    final totalPosts = postsCount.length;

    // Create model
    final model = MatchSuggestionModel(
      id: otherUserId,
      userId: otherUserId,
      fullName: otherUser['full_name'] as String,
      profilePictureUrl: otherUser['profile_picture_url'] as String?,
      department: otherDept as String?,
      yearOfStudy: otherYear,
      cgpa: otherCGPA,
      bio: otherUser['bio'] as String?,
      availabilityStatus: otherUser['availability_status'] as String? ?? 'available',
      preferredTeamSize: otherUser['preferred_team_size'] as int?,
      matchScore: totalScore,
      sharedSkills: sharedSkills,
      sharedInterests: sharedInterests,
      matchReasons: reasons,
      linkedinUrl: otherUser['linkedin_url'] as String?,
      githubUrl: otherUser['github_url'] as String?,
      portfolioUrl: otherUser['portfolio_url'] as String?,
      totalPosts: totalPosts,
      totalProjects: 0, // Can be calculated if needed
      createdAt: DateTime.parse(otherUser['created_at'] as String),
    );

    return {
      'score': totalScore,
      'model': model,
    };
  }

  @override
  Future<Either<Failure, bool>> sendConnectionRequest(String senderId, String receiverId) async {
    try {
      print("Sender ID: $senderId, Receiver ID: $receiverId");

      // Call the RPC function instead of direct update
      final response = await supabaseClient.rpc('send_connection_request', params: {
        'p_receiver_id': receiverId,
        'p_sender_id': senderId,
      });

      print("RPC Response: $response");

      final success = response['success'] as bool;
      return Right(success);

    } catch (e) {
      print("Error: $e");
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> acceptConnectionRequest(String userId, String requesterId) async{
    try {
      // Get current data
      final profileData = await supabaseClient
          .from('profiles')
          .select('connections_requests, connections')
          .eq('id', userId)
          .single();

      // Remove from connection_requests
      List<dynamic> requests = profileData['connections_requests'] ?? [];
      requests.remove(requesterId);

      // Add to connections array
      List<dynamic> connections = profileData['connections'] ?? [];
      if (!connections.contains(requesterId)) {
        connections.add(requesterId);
      }

      // Update both arrays
      await supabaseClient
          .from('profiles')
          .update({
        'connections_requests': requests,
        'connections': connections,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', userId);

      // Also add to requester's connections
      final requesterData = await supabaseClient
          .from('profiles')
          .select('connections')
          .eq('id', requesterId)
          .single();

      List<dynamic> requesterConnections = requesterData['connections'] ?? [];
      if (!requesterConnections.contains(userId)) {
        requesterConnections.add(userId);
      }

      await supabaseClient
          .from('profiles')
          .update({
        'connections': requesterConnections,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', requesterId);

      return const Right(true);

    } catch (e) {
      print(e);
      return Left(ServerFailure(e.toString()));
    }
  }
}