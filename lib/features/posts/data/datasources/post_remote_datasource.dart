import 'package:campus_collab/features/posts/data/models/post_model.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/post.dart';

abstract class PostRemoteDataSource{
  Future<Either<Failure, Post>> createPost(Post post);

  // Filter Posts
  Future<Either<Failure, List<Post>>> filterPosts(String filter);




  //Get Posts
  Future<Either<Failure, List<Post>>> getPosts();


  // Search posts
  Future<Either<Failure, List<Post>>> searchPosts(String query);
  // Edit Post
  Future<Either<Failure, Post>> editPost(Post post);

  // Delete Post
  Future<Either<Failure, void>> deletePost(String postId);


  // Get Post
  Future<Either<Failure, Post>> getPost(String postId);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final SupabaseClient client;

  PostRemoteDataSourceImpl(this.client);

  @override
  Future<Either<Failure, Post>> createPost(Post post) async {
    try {
      final postModel = PostModel.fromEntity(post);

      final response = await client
          .from('posts')
          .insert(postModel.toJson())
          .select()
          .single();

      final createdPost = PostModel.fromJson(response);

      return Right(createdPost);
    } catch (e) {
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
          .eq('id', post.id);
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
  Future<Either<Failure, List<Post>>> getPosts()async {
      try{
        final response = await client
            .from('posts')
            .select()
            .eq('is_published', true);
        final posts = (response as List)
            .map((json) => PostModel.fromJson(json).toEntity());
        return Right(posts.toList());

      }catch(e){
        return Left(ServerFailure(e.toString()));
      }
  }

  @override
  Future<Either<Failure, List<Post>>> searchPosts(String query) {
    // TODO: implement searchPosts
    throw UnimplementedError();
  }
}