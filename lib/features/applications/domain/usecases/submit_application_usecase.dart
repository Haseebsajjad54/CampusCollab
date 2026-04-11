import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/application_model.dart';
import '../repositories/application_repository.dart';

/// Submit Application Use Case
///
/// Handles submitting a new application to a post
class SubmitApplicationUseCase {
  final ApplicationRepository repository;

  SubmitApplicationUseCase(this.repository);

  /// Execute the use case
  ///
  /// [postId] - ID of the post to apply to
  /// [message] - Application message from the applicant
  ///
  /// Returns [Application] on success or [Failure] on error
  Future<Either<Failure, Application>> call({
    required String postId,
    required String message,
  }) async {
    // Validate inputs
    if (postId.isEmpty) {
      return  Left(
        ValidationFailure( 'Post ID cannot be empty'),
      );
    }

    if (message.trim().isEmpty) {
      return  Left(
        ValidationFailure( 'Application message cannot be empty'),
      );
    }

    if (message.length < 20) {
      return  Left(
        ValidationFailure(
           'Application message must be at least 20 characters',
        ),
      );
    }
    
    // Call repository
    return await repository.submitApplication(
      postId: postId,
      message: message,
    );

  }
}