import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/application_model.dart';
import '../entities/application.dart';

/// Application repository interface - Domain layer
abstract class ApplicationRepository {
  /// Submit a new application
  Future<Either<Failure, Application>> submitApplication({
    required String postId,
    required String message,
  });

  /// Get all applications sent by current user
  Future<Either<Failure, List<Application>>> getSentApplications();

  /// Get all applications received for current user's posts
  Future<Either<Failure, List<Application>>> getReceivedApplications();

  /// Get application by ID
  Future<Either<Failure, Application>> getApplicationById(String applicationId);

  /// Update application status (accept/reject)
  Future<Either<Failure, Application>> updateApplicationStatus({
    required String applicationId,
    required ApplicationStatus status,
    String? responseMessage,
  });

  /// Withdraw application
  Future<Either<Failure, void>> withdrawApplication(String applicationId);

  /// Get applications for a specific post
  Future<Either<Failure, List<Application>>> getApplicationsForPost(String postId);
}