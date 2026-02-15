import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/application_model.dart';
import '../entities/application.dart';
import '../repositories/application_repository.dart';

/// Get Sent Applications Use Case
///
/// Retrieves all applications sent by the current user
class GetSentApplicationsUseCase {
  final ApplicationRepository repository;

  GetSentApplicationsUseCase(this.repository);

  Future<Either<Failure, List<Application>>> call() async {
    return await repository.getSentApplications();
  }
}

/// Get Received Applications Use Case
///
/// Retrieves all applications received for the current user's posts
class GetReceivedApplicationsUseCase {
  final ApplicationRepository repository;

  GetReceivedApplicationsUseCase(this.repository);

  Future<Either<Failure, List<Application>>> call() async {
    return await repository.getReceivedApplications();
  }
}

/// Get Application By ID Use Case
///
/// Retrieves a specific application by its ID
class GetApplicationByIdUseCase {
  final ApplicationRepository repository;

  GetApplicationByIdUseCase(this.repository);

  Future<Either<Failure, Application>> call(String applicationId) async {
    if (applicationId.isEmpty) {
      return  Left(
        ValidationFailure( 'Application ID cannot be empty'),
      );
    }

    return await repository.getApplicationById(applicationId);
  }
}



/// Get Applications For Post Use Case
///
/// Retrieves all applications for a specific post
class GetApplicationsForPostUseCase {
  final ApplicationRepository repository;

  GetApplicationsForPostUseCase(this.repository);

  Future<Either<Failure, List<Application>>> call(String postId) async {
    if (postId.isEmpty) {
      return  Left(
        ValidationFailure( 'Post ID cannot be empty'),
      );
    }

    return await repository.getApplicationsForPost(postId);
  }
}