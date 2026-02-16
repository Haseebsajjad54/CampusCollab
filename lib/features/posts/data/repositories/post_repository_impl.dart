import 'package:campus_collab/core/errors/failures.dart';
import 'package:campus_collab/features/posts/domain/entities/post.dart';
import 'package:campus_collab/features/posts/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';

import '../datasources/post_remote_datasource.dart';

class PostRepositoryImpl extends PostRepository{
  final PostRemoteDataSource dataSource;

  PostRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, Post>> createPost(Post post) {
    // TODO: implement createPost
    //throw UnimplementedError();

    return dataSource.createPost(post);
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