import 'dart:io';
import 'package:campus_collab/features/posts/data/models/post_model.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../../posts/domain/entities/post.dart';
import '../../domain/entities/student_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/student_profile_model.dart';

/// Profile Repository Implementation
///
/// Complete Supabase integration for profile operations
class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient supabaseClient;

  ProfileRepositoryImpl({required this.supabaseClient});

  @override
  Future<Either<Failure, Profile>> getCurrentProfile() async {
    try {
      final currentUser = supabaseClient.auth.currentUser;

      if (currentUser == null) {
        return const Left(
          AuthenticationFailure(  'User not authenticated'),
        );
      }

      return await getProfileById(currentUser.id);
    } catch (e) {
      print("Error in getting current profile: $e");
      return Left(
        ServerFailure(  'Failed to get profile: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Profile>> getProfileById(String userId) async {
    print("Getting profile by ID: $userId");
    try {
      // Get profile data
      final profileData = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      // Get skills
      final skillsData = await supabaseClient
          .from('student_skills')
          .select('skills(name)')
          .eq('student_id', userId);

      final skills = skillsData
          .map((s) => (s['skills'] as Map)['name'] as String)
          .toList();

      // Get interests
      final interestsData = await supabaseClient
          .from('student_interests')
          .select('interests(name)')
          .eq('student_id', userId);

      final interests = interestsData
          .map((i) => (i['interests'] as Map)['name'] as String)
          .toList();

      // Combine data
      final profile = ProfileModel.fromJson({
        ...profileData,
        'skills': skills,
        'interests': interests,
      });
      print("Profile retrieved: $profile");

      return Right(profile);
    } on PostgrestException catch (e) {
      print("Error in getting profile by ID: $e");
      if (e.code == '404') {
        print("Profile not found for user ID: $userId");

      }
      return Left(
        ServerFailure(  'Database error: ${e.message}'),
      );
    } catch (e) {
      print("Error in getting profile by ID: $e");
      return Left(
        ServerFailure(  'Failed to get profile: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Profile>> updateProfile(Profile profile) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;

      if (currentUser == null) {
        return const Left(
          AuthenticationFailure(  'User not authenticated'),
        );
      }

      final profileModel = ProfileModel.fromEntity(profile);

      // Update profile in database
      await supabaseClient
          .from('profiles')
          .update(profileModel.toJson())
          .eq('id', currentUser.id);

      // Get updated profile
      return await getProfileById(currentUser.id);
    } on PostgrestException catch (e) {
      return Left(
        ServerFailure(  'Database error: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure(  'Failed to update profile: ${e.toString()}'),
      );
    }
  }

  // ProfileRepositoryImpl mein uploadProfilePicture method update karein

  @override
  Future<Either<Failure, String>> uploadProfilePicture(File image) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        return const Left(AuthenticationFailure('User not authenticated'));
      }

      print('📤 Starting upload for user: ${currentUser.id}');
      print('📁 File path: ${image.path}');
      print('📏 File size: ${await image.length()} bytes');

      // Check if file exists
      if (!await image.exists()) {
        return const Left(ServerFailure('Image file does not exist'));
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = image.path.split('.').last;
      final fileName = '${currentUser.id}_$timestamp.$extension';
      final path = 'profile_pictures/$fileName';

      print('📝 Generated filename: $fileName');
      print('🛣️ Storage path: $path');

      // Try to upload with more detailed error handling
      try {
        await supabaseClient.storage
            .from('ProfileImages')
            .upload(
          path,
          image,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: false,
          ),
        );
        print('✅ Upload successful!');
      } on StorageException catch (e) {
        print('❌ Storage exception: ${e.message}');
        print('❌ Status code: ${e.statusCode}');
        print('❌ Error details: ${e.error}');
        return Left(ServerFailure('Storage error: ${e.message}'));
      }

      // Get public URL
      final publicUrl = supabaseClient.storage
          .from('ProfileImages')
          .getPublicUrl(path);

      print('🔗 Public URL: $publicUrl');

      // Verify URL is accessible
      try {
        final response = await supabaseClient.storage
            .from('ProfileImages')
            .createSignedUrl(path, 60);
        print('✅ Signed URL created successfully');
      } catch (e) {
        print('⚠️ Warning: Could not create signed URL: $e');
      }

      // Update profile with new picture URL
      final updateResult = await supabaseClient
          .from('profiles')
          .update({'profile_picture_url': publicUrl})
          .eq('id', currentUser.id)
          .select();

      print('📝 Profile update result: $updateResult');

      return Right(publicUrl);
    } catch (e) {
      print('❌ Unexpected error: $e');
      return Left(ServerFailure('Failed to upload image: ${e.toString()}'));
    }
  }
  // @override
  // Future<Either<Failure, String>> uploadProfilePicture(File image) async {
  //   try {
  //     final currentUser = supabaseClient.auth.currentUser;
  //
  //     if (currentUser == null) {
  //       return const Left(
  //         AuthenticationFailure(  'User not authenticated'),
  //       );
  //     }
  //
  //     // Generate unique filename
  //     final timestamp = DateTime.now().millisecondsSinceEpoch;
  //     final extension = image.path.split('.').last;
  //     final fileName = '${currentUser.id}_$timestamp.$extension';
  //
  //     // Upload to Supabase Storage
  //     final path = 'profile_pictures/$fileName';
  //
  //     await supabaseClient.storage
  //         .from('ProfileImages')
  //         .upload(path, image);
  //
  //     // Get public URL
  //     final publicUrl = supabaseClient.storage
  //         .from('ProfileImages')
  //         .getPublicUrl(path);
  //
  //     // Update profile with new picture URL
  //     await supabaseClient
  //         .from('profiles')
  //         .update({
  //       'profile_picture_url': publicUrl,
  //       'updated_at': DateTime.now().toIso8601String(),
  //     })
  //         .eq('id', currentUser.id);
  //
  //     return Right(publicUrl);
  //   } on StorageException catch (e) {
  //     return Left(
  //       ServerFailure(  'Storage error: ${e.message}'),
  //     );
  //   } catch (e) {
  //     return Left(
  //       ServerFailure(  'Failed to upload image: ${e.toString()}'),
  //     );
  //   }
  // }

  @override
  Future<Either<Failure, void>> addSkill(String skillName) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;

      if (currentUser == null) {
        return const Left(
          AuthenticationFailure(  'User not authenticated'),
        );
      }

      // Check if skill exists in skills table
      final existingSkill = await supabaseClient
          .from('skills')
          .select('id')
          .eq('name', skillName)
          .maybeSingle();

      String skillId;

      if (existingSkill == null) {
        // Create new skill
        final newSkill = await supabaseClient
            .from('skills')
            .insert({'name': skillName})
            .select('id')
            .single();

        skillId = newSkill['id'] as String;
      } else {
        skillId = existingSkill['id'] as String;
      }

      // Add to student_skills
      await supabaseClient
          .from('student_skills')
          .insert({
        'student_id': currentUser.id,
        'skill_id': skillId,
      });

      return const Right(null);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        // Unique constraint violation - skill already added
        return const Left(
          ValidationFailure(  'Skill already added'),
        );
      }
      return Left(
        ServerFailure(  'Database error: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure(  'Failed to add skill: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> removeSkill(String skillName) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;

      if (currentUser == null) {
        return const Left(
          AuthenticationFailure(  'User not authenticated'),
        );
      }

      // Get skill ID
      final skill = await supabaseClient
          .from('skills')
          .select('id')
          .eq('name', skillName)
          .maybeSingle();

      if (skill == null) {
        return const Left(
          ValidationFailure(  'Skill not found'),
        );
      }

      // Remove from student_skills
      await supabaseClient
          .from('student_skills')
          .delete()
          .eq('student_id', currentUser.id)
          .eq('skill_id', skill['id']);

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(
        ServerFailure(  'Database error: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure(  'Failed to remove skill: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> addInterest(String interestName) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;

      if (currentUser == null) {
        return const Left(
          AuthenticationFailure(  'User not authenticated'),
        );
      }

      // Check if interest exists
      final existingInterest = await supabaseClient
          .from('interests')
          .select('id')
          .eq('name', interestName)
          .maybeSingle();

      String interestId;

      if (existingInterest == null) {
        // Create new interest
        final newInterest = await supabaseClient
            .from('interests')
            .insert({'name': interestName})
            .select('id')
            .single();

        interestId = newInterest['id'] as String;
      } else {
        interestId = existingInterest['id'] as String;
      }

      // Add to student_interests
      await supabaseClient
          .from('student_interests')
          .insert({
        'student_id': currentUser.id,
        'interest_id': interestId,
      });

      return const Right(null);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        return const Left(
          ValidationFailure(  'Interest already added'),
        );
      }
      return Left(
        ServerFailure(  'Database error: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure(  'Failed to add interest: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> removeInterest(String interestName) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;

      if (currentUser == null) {
        return const Left(
          AuthenticationFailure(  'User not authenticated'),
        );
      }

      // Get interest ID
      final interest = await supabaseClient
          .from('interests')
          .select('id')
          .eq('name', interestName)
          .maybeSingle();

      if (interest == null) {
        return const Left(
          ValidationFailure(  'Interest not found'),
        );
      }

      // Remove from student_interests
      await supabaseClient
          .from('student_interests')
          .delete()
          .eq('student_id', currentUser.id)
          .eq('interest_id', interest['id']);

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(
        ServerFailure(  'Database error: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure(  'Failed to remove interest: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateAvailability(String status) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;

      if (currentUser == null) {
        return const Left(
          AuthenticationFailure(  'User not authenticated'),
        );
      }

      await supabaseClient
          .from('profiles')
          .update({
        'availability_status': status,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', currentUser.id);

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(
        ServerFailure(  'Database error: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure(  'Failed to update availability: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getUserStats(String userId) async {
    try {
      // Get posts count
      final postsData = await supabaseClient
          .from('posts')
          .select('id')
          .eq('author_id', userId);

      // Get applications sent count
      final sentAppsData = await supabaseClient
          .from('applications')
          .select('id')
          .eq('applicant_id', userId);

      // Get applications received count (posts they created)
      final receivedAppsData = await supabaseClient
          .from('applications')
          .select('id', )
          .eq('post_id', userId);

      final stats = {
        'posts': postsData.length,
        'applications_sent': sentAppsData.length,
        'applications_received': receivedAppsData.length,
      };

      return Right(stats);
    } on PostgrestException catch (e) {
      return Left(
        ServerFailure(  'Database error: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure(  'Failed to get stats: ${e.toString()}'),
      );
    }
  }
  Future<void> testBucketAccess() async {
    print('=== STORAGE DEBUGGING ===');

    // 1. Check authentication
    final user = supabaseClient.auth.currentUser;
    print('👤 Current user: ${user?.email}');
    print('👤 User ID: ${user?.id}');

    if (user == null) {
      print('❌ ERROR: User not authenticated! Please login first.');
      return;
    }

    // 2. Check session token
    final session = supabaseClient.auth.currentSession;
    print('🔑 Session exists: ${session != null}');
    print('🔑 Access token: ${session?.accessToken.substring(0, 20)}...');

    // 3. Try to list buckets with error details
    try {
      final buckets = await supabaseClient.storage.listBuckets();
      print('📦 Buckets found: ${buckets.map((b) => b.id).toList()}');

      if (buckets.isEmpty) {
        print('❌ No buckets returned. This could be due to:');
        print('   - Missing SELECT policy on storage.buckets table');
        print('   - User role issue (make sure target role is "authenticated")');
        print('   - API key permissions issue');
      }
    } catch (e) {
      print('❌ Error listing buckets: $e');

      // Check for specific error types
      if (e.toString().contains('403')) {
        print('🔍 This is a PERMISSION error - RLS policy missing on storage.buckets');
      } else if (e.toString().contains('401')) {
        print('🔍 This is an AUTHENTICATION error - token invalid/expired');
      } else if (e.toString().contains('404')) {
        print('🔍 This is a NOT FOUND error - storage endpoint issue');
      }
    }

    // 4. Try direct bucket access without listing
    print('\n🔄 Trying direct bucket access...');
    try {
      // Try to list files in the bucket (this will fail if bucket doesn't exist or no permission)
      final files = await supabaseClient.storage
          .from('ProfileImages')
          .list();
      print('✅ Can access ProfileImages bucket directly! Files: ${files.length}');
    } catch (e) {
      print('❌ Cannot access ProfileImages bucket directly: $e');

      if (e.toString().contains('bucket')) {
        print('🔍 Bucket "ProfileImages" might not exist or name is incorrect');
      } else if (e.toString().contains('permission') || e.toString().contains('policy')) {
        print('🔍 Missing SELECT policy on storage.objects for this bucket');
      }
    }
  }

  // In your ProfileRepositoryImpl class

  Future<Either<Failure, List<Post>>> fetchCurrentUserPosts() async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        return const Left(
          AuthenticationFailure('User not authenticated'),
        );
      }

      final response = await supabaseClient
          .from('posts')
          .select('*')
          .eq('author_id', currentUser.id)
          .order('created_at', ascending: false);

      // Convert the response to List<Post>
      final List<Post> posts = [];
      for (var postData in response) {
        try {
          final post = PostModel.fromJson(postData);
          print('✅ Post fetched: $post');
          posts.add(post);
        } catch (e) {
          print('Error parsing post: $e');
          continue;
        }
      }

      return Right(posts);
    } catch (e) {
      print("Error in fetching current user posts: $e");
      return Left(
        ServerFailure('Failed to fetch posts: ${e.toString()}'),
      );
    }
  }
}