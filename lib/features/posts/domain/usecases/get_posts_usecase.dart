import 'package:campus_collab/features/posts/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/post.dart';

class GetPostUseCase{

  final PostRepository repository;
  GetPostUseCase(this.repository);

  Future<Either<Failure, Post>> getPostById(String postId) {
    return repository.getPost(postId);

  }

  Future<Either<Failure, List<Post>>> getAllPosts() {
    return repository.getPosts();

  }


}