import 'package:campus_collab/features/posts/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/post.dart';

class CreatePostUseCase{
  late final PostRepository repository;
  CreatePostUseCase(this.repository);

  Future<Either<Failure, Post>> call(Post post){
    return repository.createPost(post);
  }
}
