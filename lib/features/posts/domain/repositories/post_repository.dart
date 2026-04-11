import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/post.dart';

abstract class PostRepository{

  //Create Post
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
  Future<Either<Failure, Post>> getPost(String postId);

  Future<Map<String, dynamic>?> fetchPostById(String postId);
  Future<List<String>> skills();


  // Get Post Comments
 // Future<Either<Failure, List<Comment>>> getPostComments(String postId);

  // Create Post Comment

  // Edit Post Comment

  // Delete Post Comment

}