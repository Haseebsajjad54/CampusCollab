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
  Future<Either<Failure, Post>> createPost(Post post) {
    // TODO: implement createPost
    // throw UnimplementedError();

    // return client.from('posts').insert();
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId) {
    // TODO: implement deletePost
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Post>> editPost(Post post) {
    // TODO: implement editPost
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Post>>> filterPosts(String filter) {
    // TODO: implement filterPosts
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Post>> getPost(String postId) {
    // TODO: implement getPost
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Post>>> getPosts() {
    // TODO: implement getPosts
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Post>>> searchPosts(String query) {
    // TODO: implement searchPosts
    throw UnimplementedError();
  }
}