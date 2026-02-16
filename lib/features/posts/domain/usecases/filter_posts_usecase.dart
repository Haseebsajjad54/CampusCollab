import 'package:campus_collab/features/posts/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/post.dart';

class FilterPostUseCase{
  late final PostRepository repository;
  FilterPostUseCase(this.repository);

  Future<Either<Failure, List<Post>>> call(String filter) {
    return repository.filterPosts(filter);
  }
}