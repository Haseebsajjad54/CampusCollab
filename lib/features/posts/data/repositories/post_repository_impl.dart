import 'package:campus_collab/core/errors/failures.dart';
import 'package:campus_collab/features/posts/domain/entities/post.dart';
import 'package:campus_collab/features/posts/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';

import '../datasources/post_remote_datasource.dart';

class PostRepositoryImpl extends PostRepository{
  final PostRemoteDataSource dataSource;

  PostRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, Post>> createPost(Post post) async{
try{
  return Right(dataSource.createPost(post) as Post);

}catch(e){
  return Left(ServerFailure(e.toString()));
}
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId) async {
    try{
      dataSource.deletePost(postId);
      return const Right(null);
    }catch(e){
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Post>> editPost(Post post) async {
    try{
      return Right(dataSource.editPost(post) as Post);
    }catch(e){
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> filterPosts(String filter) {
    // TODO: implement filterPosts
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Post>> getPost(String postId) async {
    try{
      return Right(dataSource.getPost(postId) as Post);
      }catch(e){
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> getPosts() async{
    try{
      return Right(dataSource.getPosts() as List<Post>);
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