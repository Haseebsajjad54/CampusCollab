import 'package:campus_collab/features/posts/data/models/post_model.dart';
import 'package:campus_collab/features/posts/data/models/post_transformer.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/post.dart';

abstract class PostRemoteDataSource{
  Future<Either<Failure, Post>> createPost(Post post);

  // Filter Posts
  Future<Either<Failure, List<Post>>> filterPosts(String filter);




  //Get Posts
  Future<Either<Failure, List<Map<String, dynamic>>>> getPosts();


  // Search posts
  Future<Either<Failure, List<Post>>> searchPosts(String query);
  // Edit Post
  Future<Either<Failure, Post>> editPost(Post post);

  // Delete Post
  Future<Either<Failure, void>> deletePost(String postId);


  // Get Post
  Future<Map<String, dynamic>?> fetchPostById(String postId);

  Future<Either<Failure, Post>> getPost(String postId);

  Future<List<String>> getSkills();
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final SupabaseClient client;

  PostRemoteDataSourceImpl(this.client);

  @override
  Future<Either<Failure, Post>> createPost(Post post) async {
    print('In create Post function');
    try {
      final postModel = PostModel.fromEntity(post);

      final response = await client
          .from('posts')
          .insert(postModel.toJson())
          .select()
          .single();

      final createdPost = PostModel.fromJson(response);
      print("Response of post creation $response");

      return Right(createdPost);
    } catch (e) {
      print("In Catch Block of create Post");
      print("Error in post creation $e");
      return Left(ServerFailure(e.toString()));
    }
  }


  @override
  Future<Either<Failure, void>> deletePost(String postId) async {
    try{
      client.from('posts').delete().eq('id', postId);
      return const Right(null);
    }catch(e){
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Post>> editPost(Post post)async {
    try{
      final postModel = PostModel.fromEntity(post);
      final response = await client
          .from('posts')
          .update(postModel.toJson())
          .eq('id', post.id)
          .select()
          .single();
      final updatedPost = PostModel.fromJson(response);
      return Right(updatedPost);


    }catch(e){
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  @override
  Future<Either<Failure, List<Post>>> filterPosts(String filter) async {
    try {
      final response = await client
          .from('posts')
          .select()
          .eq('status', filter)
          .eq('is_published', true)
          .order('created_at', ascending: false);

      final posts = (response as List)
          .map((json) => PostModel.fromJson(json).toEntity())
          .toList();

      return Right(posts);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }


  @override
  Future<Either<Failure, Post>> getPost(String postId) async {
    try{
      final response= await client
          .from('posts')
          .select()
          .eq('id', postId)
          .single();
      final post = PostModel.fromJson(response).toEntity();
      return Right(post);
    }catch(e){
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getPosts() async {
    try {
      // where author_id is not equal to current user id and is_published is true
      final currentUserId = client.auth.currentUser?.id;

      final response = await client
          .from('posts')
          .select('''
      *,
      profiles!inner (
        full_name,
        profile_picture_url,
        department,
        year_of_study
      )
    ''')
          .eq('is_published', true)
          .neq('author_id', currentUserId as Object)  // Use .neq() instead of .eq()
          .order('created_at', ascending: false);

      final posts = (response as List).map((json) {
        final profileData = json['profiles'] as Map<String, dynamic>;

        // Return a flattened map
        return {
          'id': json['id'],
          'title': json['title'],
          'description': json['description'],
          'post_type': json['post_type'],
          'team_size': json['team_size'],
          'deadline': json['deadline'],
          'selected_skills': json['selected_skills'],
          'created_at': json['created_at'],
          'author_id': json['author_id'],
          'author_name': profileData['full_name'],
          'author_image': profileData['profile_picture_url'],
          'author_department': profileData['department'],
          'author_year': profileData['year_of_study'],
        };
      }).toList();

      return Right(posts);
    } catch (e) {
      print('Error fetching posts: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> searchPosts(String query) {
    // TODO: implement searchPosts
    throw UnimplementedError();
  }

  Future<Map<String, dynamic>> fetchAllPosts() async {
    final response = await client
        .from('posts')
        .select('''
        *,
        author:profiles!author_id (
          id,
          full_name,
          profile_picture_url,
          bio,
          department,
          year_of_study,
          cgpa
        ),
        applications (
          count
        ),
        post_skills (
          is_required,
          skill:skills (
            id,
            name,
            category
          )
        ),
        bookmarks!inner (
          user_id
        )
      ''')
        .order('created_at', ascending: false);

    return PostTransformer.toMockFormat(response as Map<String, dynamic>);
  }


  @override
  Future<Map<String, dynamic>?> fetchPostById(String postId) async {
    final response = await client
        .from('posts')
        .select('''
        *,
        author:profiles!author_id (
          student_id,
          full_name,
          profile_picture_url,
          bio,
          department,
          year_of_study,
          cgpa
        ),
        applications (
          count
        ),
        post_skills (
          is_required,
          skill:skills (
            id,
            name,
            category
          )
        )
      ''')
        .eq('id', postId)
        .single();

    return PostTransformer.toMockFormat(response);
  }

  @override
  Future<List<String>> getSkills() async {
    try {
      final response = await client
          .from('skills')
          .select('name')
          .order('name');

      if (response.isEmpty) {
        return [];
      }

      final skills = response.map((skill) => skill['name'] as String).toList();
      return skills;
    } catch (e) {
      print('Error fetching skills: $e');
      return [];
    }
  }
}