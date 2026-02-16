import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

class EditPostUseCase{
  late final PostRepository repository;

  EditPostUseCase(this.repository);

  Future<Either<Failure, Post>> call(Post post) {
    return repository.editPost(post);
  }
}