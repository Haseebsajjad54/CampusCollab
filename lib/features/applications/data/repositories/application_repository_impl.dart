import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/application_repository.dart';
import '../datasources/application_remote_datasource.dart';
import '../models/application_model.dart';

/// Application repository implementation
class ApplicationRepositoryImpl implements ApplicationRepository {
  final ApplicationRemoteDataSource remoteDataSource;

  ApplicationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Application>> submitApplication({
    required String postId,
    required String message,
  }) async {
    try {
      final result = await remoteDataSource.submitApplication(
        postId: postId,
        message: message,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Application>>> getSentApplications() async {
    try {
      final result = await remoteDataSource.getSentApplications();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure( e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Application>>> getReceivedApplications() async {
    try {
      final result = await remoteDataSource.getReceivedApplications();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Application>> getApplicationById(
      String applicationId,
      ) async {
    try {
      final result = await remoteDataSource.getApplicationById(applicationId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure( e.toString()));
    }
  }

  @override
  Future<Either<Failure, Application>> updateApplicationStatus({
    required String applicationId,
    required ApplicationStatus status,
    String? responseMessage,
  }) async {
    try {
      final result = await remoteDataSource.updateApplicationStatus(
        applicationId: applicationId,
        status: status.name,
        responseMessage: responseMessage,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure( e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> withdrawApplication(
      String applicationId,
      ) async {
    try {
      await remoteDataSource.withdrawApplication(applicationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Application>>> getApplicationsForPost(
      String postId,
      ) async {
    try {
      final result = await remoteDataSource.getApplicationsForPost(postId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}