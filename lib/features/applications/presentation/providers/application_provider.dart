import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/application_remote_datasource.dart';
import '../../data/models/application_model.dart';
import '../../data/repositories/application_repository_impl.dart';
import '../../domain/usecases/get_applications_usecase.dart';
import '../../domain/usecases/submit_application_usecase.dart';
import '../../domain/usecases/update_application_status_usecase.dart';

/// Application state
enum ApplicationStateStatus {
  initial,
  loading,
  success,
  error,
}

class ApplicationState {
  final ApplicationStateStatus status;
  final List<Application> sentApplications;
  final List<Application> receivedApplications;
  final String? errorMessage;

  ApplicationState({
    required this.status,
    required this.sentApplications,
    required this.receivedApplications,
    this.errorMessage,
  });

  factory ApplicationState.initial() {
    return ApplicationState(
      status: ApplicationStateStatus.initial,
      sentApplications: [],
      receivedApplications: [],
    );
  }

  ApplicationState copyWith({
    ApplicationStateStatus? status,
    List<Application>? sentApplications,
    List<Application>? receivedApplications,
    String? errorMessage,
  }) {
    return ApplicationState(
      status: status ?? this.status,
      sentApplications: sentApplications ?? this.sentApplications,
      receivedApplications: receivedApplications ?? this.receivedApplications,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Application provider
class ApplicationProvider extends ChangeNotifier {
  // Dependencies
  late final SubmitApplicationUseCase _submitApplicationUseCase;
  late final GetSentApplicationsUseCase _getSentApplicationsUseCase;
  late final GetReceivedApplicationsUseCase _getReceivedApplicationsUseCase;
  late final UpdateApplicationStatusUseCase _updateApplicationStatusUseCase;
  late final WithdrawApplicationUseCase _withdrawApplicationUseCase;
  late final GetApplicationsForPostUseCase _getApplicationsForPostUseCase;

  // State
  ApplicationState _state = ApplicationState.initial();
  ApplicationState get state => _state;

  ApplicationProvider() {
    _initializeUseCases();
  }

  void _initializeUseCases() {
    final supabase = Supabase.instance.client;
    final remoteDataSource = ApplicationRemoteDataSource(
      supabaseClient: supabase,
    );
    final repository = ApplicationRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );

    _submitApplicationUseCase = SubmitApplicationUseCase(repository);
    _getSentApplicationsUseCase = GetSentApplicationsUseCase(repository);
    _getReceivedApplicationsUseCase = GetReceivedApplicationsUseCase(repository);
    _updateApplicationStatusUseCase = UpdateApplicationStatusUseCase(repository);
    _withdrawApplicationUseCase = WithdrawApplicationUseCase(repository);
    _getApplicationsForPostUseCase = GetApplicationsForPostUseCase(repository);
  }

  /// Submit a new application
  Future<bool> submitApplication({
    required String postId,
    required String message,
  }) async {
    _state = _state.copyWith(status: ApplicationStateStatus.loading);
    notifyListeners();

    final result = await _submitApplicationUseCase(
      postId: postId,
      message: message,
    );

    return result.fold(
          (failure) {
        _state = _state.copyWith(
          status: ApplicationStateStatus.error,
          errorMessage: failure.message,
        );
        notifyListeners();
        return false;
      },
          (application) {
        // Add to sent applications list
        final updatedList = [application, ..._state.sentApplications];
        _state = _state.copyWith(
          status: ApplicationStateStatus.success,
          sentApplications: updatedList,
        );
        notifyListeners();
        return true;
      },
    );
  }

  /// Load sent applications
  Future<void> loadSentApplications() async {
    _state = _state.copyWith(status: ApplicationStateStatus.loading);
    notifyListeners();

    final result = await _getSentApplicationsUseCase();

    result.fold(
          (failure) {
        _state = _state.copyWith(
          status: ApplicationStateStatus.error,
          errorMessage: failure.message,
        );
      },
          (applications) {
        _state = _state.copyWith(
          status: ApplicationStateStatus.success,
          sentApplications: applications,
        );
      },
    );
    notifyListeners();
  }

  /// Load received applications
  Future<void> loadReceivedApplications() async {
    _state = _state.copyWith(status: ApplicationStateStatus.loading);
    notifyListeners();

    final result = await _getReceivedApplicationsUseCase();

    result.fold(
          (failure) {
        _state = _state.copyWith(
          status: ApplicationStateStatus.error,
          errorMessage: failure.message,
        );
      },
          (applications) {
        _state = _state.copyWith(
          status: ApplicationStateStatus.success,
          receivedApplications: applications,
        );
      },
    );
    notifyListeners();
  }

  /// Accept application
  Future<bool> acceptApplication({
    required String applicationId,
    String? responseMessage,
  }) async {
    final result = await _updateApplicationStatusUseCase(
      applicationId: applicationId,
      status: ApplicationStatus.accepted,
      responseMessage: responseMessage,
    );

    return result.fold(
          (failure) {
        _state = _state.copyWith(
          status: ApplicationStateStatus.error,
          errorMessage: failure.message,
        );
        notifyListeners();
        return false;
      },
          (updatedApplication) {
        // Update in received applications list
        final updatedList = _state.receivedApplications.map((app) {
          return app.id == applicationId ? updatedApplication : app;
        }).toList();

        _state = _state.copyWith(
          status: ApplicationStateStatus.success,
          receivedApplications: updatedList,
        );
        notifyListeners();
        return true;
      },
    );
  }

  /// Reject application
  Future<bool> rejectApplication({
    required String applicationId,
    String? responseMessage,
  }) async {
    final result = await _updateApplicationStatusUseCase(
      applicationId: applicationId,
      status: ApplicationStatus.rejected,
      responseMessage: responseMessage,
    );

    return result.fold(
          (failure) {
        _state = _state.copyWith(
          status: ApplicationStateStatus.error,
          errorMessage: failure.message,
        );
        notifyListeners();
        return false;
      },
          (updatedApplication) {
        // Update in received applications list
        final updatedList = _state.receivedApplications.map((app) {
          return app.id == applicationId ? updatedApplication : app;
        }).toList();

        _state = _state.copyWith(
          status: ApplicationStateStatus.success,
          receivedApplications: updatedList,
        );
        notifyListeners();
        return true;
      },
    );
  }

  /// Withdraw application
  Future<bool> withdrawApplication(String applicationId) async {
    final result = await _withdrawApplicationUseCase(applicationId);

    return result.fold(
          (failure) {
        _state = _state.copyWith(
          status: ApplicationStateStatus.error,
          errorMessage: failure.message,
        );
        notifyListeners();
        return false;
      },
          (_) {
        // Remove from sent applications list
        final updatedList = _state.sentApplications
            .where((app) => app.id != applicationId)
            .toList();

        _state = _state.copyWith(
          status: ApplicationStateStatus.success,
          sentApplications: updatedList,
        );
        notifyListeners();
        return true;
      },
    );
  }

  /// Get applications for a specific post
  Future<List<Application>> getApplicationsForPost(String postId) async {
    final result = await _getApplicationsForPostUseCase(postId);

    return result.fold(
          (failure) => [],
          (applications) => applications,
    );
  }

  /// Clear error
  void clearError() {
    _state = _state.copyWith(
      status: ApplicationStateStatus.initial,
      errorMessage: null,
    );
    notifyListeners();
  }
}