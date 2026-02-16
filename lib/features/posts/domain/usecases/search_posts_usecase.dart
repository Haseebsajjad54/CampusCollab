import 'package:campus_collab/features/posts/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/post.dart';

class SearchPostUseCase{

  final PostRepository repository;

  SearchPostUseCase(this.repository);

  Future<Either<Failure, List<Post>>> searchPosts(String query) {
    return repository.searchPosts(query);
  }

}