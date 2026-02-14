import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/application_model.dart';
import '../entities/application.dart';
import '../repositories/application_repository.dart';

/// Update Application Status Use Case
///
/// Handles updating the status of an application (accept/reject)
class UpdateApplicationStatusUseCase {
  final ApplicationRepository repository;

  UpdateApplicationStatusUseCase(this.repository);

  /// Execute the use case
  ///
  /// [applicationId] - ID of the application to update
  /// [status] - New status (accepted/rejected)
  /// [responseMessage] - Optional message to applicant
  ///
  /// Returns updated [Application] on success or [Failure] on error
  Future<Either<Failure, Application>> call({
    required String applicationId,
    required ApplicationStatus status,
    String? responseMessage,
  }) async {
    // Validate inputs
    if (applicationId.isEmpty) {
      return  Left(
        ValidationFailure(message: 'Application ID cannot be empty'),
      );
    }

    // Can only accept or reject
    if (status != ApplicationStatus.accepted &&
        status != ApplicationStatus.rejected) {
      return  Left(
        ValidationFailure(
          message: 'Status must be either accepted or rejected',
        ),
      );
    }

    // Call repository
    return await repository.updateApplicationStatus(
      applicationId: applicationId,
      status: status,
      responseMessage: responseMessage,
    );
  }
}

/// Withdraw Application Use Case
///
/// Allows applicant to withdraw their application
class WithdrawApplicationUseCase {
  final ApplicationRepository repository;

  WithdrawApplicationUseCase(this.repository);

  Future<Either<Failure, void>> call(String applicationId) async {
    if (applicationId.isEmpty) {
      return Left(
        ValidationFailure(message: 'Application ID cannot be empty'),
      );
    }

    return await repository.withdrawApplication(applicationId);
  }
}