import 'package:campus_collab/core/errors/failures.dart';
import 'package:campus_collab/features/posts/domain/entities/post.dart';
import 'package:campus_collab/features/posts/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';

import '../datasources/post_remote_datasource.dart';

class PostRepositoryImpl extends PostRepository {
  final PostRemoteDataSource dataSource;

  PostRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, Post>> createPost(Post post) async {
    return await dataSource.createPost(post);
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId) async {
    return await dataSource.deletePost(postId);
  }

  @override
  Future<Either<Failure, Post>> editPost(Post post) async {
    return await dataSource.editPost(post);
  }

  @override
  Future<Either<Failure, List<Post>>> filterPosts(String filter) async {
    return await dataSource.filterPosts(filter);
  }

  @override
  Future<Either<Failure, Post>> getPost(String postId) async {
    return await dataSource.getPost(postId);
  }

  @override
  Future<Map<String, dynamic>?> fetchPostById(String postId) async {
    return await dataSource.fetchPostById(postId);
  }


  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getPosts() async {
    return await dataSource.getPosts();
  }

  @override
  Future<Either<Failure, List<Post>>> searchPosts(String query) async {
    return await dataSource.searchPosts(query);
  }

  @override
  Future<List<String>> skills()async {
    return await dataSource.getSkills();
  }
}