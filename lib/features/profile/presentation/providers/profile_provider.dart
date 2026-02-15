import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/student_profile.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/upload_profile_picture_usecase.dart';

/// Profile State Status
enum ProfileStatus {
  initial,
  loading,
  success,
  error,
}

/// Profile State
class ProfileState {
  final ProfileStatus status;
  final Profile? profile;
  final Map<String, int>? stats;
  final String? errorMessage;

  ProfileState({
    required this.status,
    this.profile,
    this.stats,
    this.errorMessage,
  });

  factory ProfileState.initial() {
    return ProfileState(status: ProfileStatus.initial);
  }

  ProfileState copyWith({
    ProfileStatus? status,
    Profile? profile,
    Map<String, int>? stats,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      stats: stats ?? this.stats,
      errorMessage: errorMessage,
    );
  }

  bool get isLoading => status == ProfileStatus.loading;
  bool get hasError => status == ProfileStatus.error;
  bool get hasProfile => profile != null;
}

/// Profile Provider
///
/// Manages profile state and operations
class ProfileProvider extends ChangeNotifier {
  late final GetProfileUseCase _getProfileUseCase;
  late final UpdateProfileUseCase _updateProfileUseCase;
  late final UploadProfilePictureUseCase _uploadPictureUseCase;
  late final ProfileRepositoryImpl _repository;

  ProfileState _state = ProfileState.initial();
  ProfileState get state => _state;

  Profile? get profile => _state.profile;
  Map<String, int>? get stats => _state.stats;
  bool get isLoading => _state.isLoading;
  bool get hasError => _state.hasError;
  String? get errorMessage => _state.errorMessage;

  ProfileProvider() {
    _initializeUseCases();
  }

  void _initializeUseCases() {
    final supabase = Supabase.instance.client;
    _repository = ProfileRepositoryImpl(supabaseClient: supabase);
    _getProfileUseCase = GetProfileUseCase(_repository);
    _updateProfileUseCase = UpdateProfileUseCase(_repository);
    _uploadPictureUseCase = UploadProfilePictureUseCase(_repository);
  }

  /// Load current user's profile
  Future<void> loadCurrentProfile() async {
    _state = _state.copyWith(status: ProfileStatus.loading);
    notifyListeners();

    final result = await _getProfileUseCase.getCurrentProfile();

    result.fold(
          (failure) {
        _state = ProfileState(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        );
      },
          (profile) async {
        // Load stats
        final statsResult = await _repository.getUserStats(profile.id);

        _state = ProfileState(
          status: ProfileStatus.success,
          profile: profile,
          stats: statsResult.getOrElse(() => {}),
        );
      },
    );
    notifyListeners();
  }

  /// Load profile by user ID
  Future<void> loadProfileById(String userId) async {
    _state = _state.copyWith(status: ProfileStatus.loading);
    notifyListeners();

    final result = await _getProfileUseCase.getProfileById(userId);

    result.fold(
          (failure) {
        _state = ProfileState(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        );
      },
          (profile) async {
        // Load stats
        final statsResult = await _repository.getUserStats(profile.id);

        _state = ProfileState(
          status: ProfileStatus.success,
          profile: profile,
          stats: statsResult.getOrElse(() => {}),
        );
      },
    );
    notifyListeners();
  }

  /// Update profile
  Future<bool> updateProfile(Profile profile) async {
    _state = _state.copyWith(status: ProfileStatus.loading);
    notifyListeners();

    final result = await _updateProfileUseCase.updateProfile(profile);

    return result.fold(
          (failure) {
        _state = _state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        );
        notifyListeners();
        return false;
      },
          (updatedProfile) {
        _state = _state.copyWith(
          status: ProfileStatus.success,
          profile: updatedProfile,
        );
        notifyListeners();
        return true;
      },
    );
  }

  /// Upload profile picture
  Future<bool> uploadProfilePicture(File image) async {
    try {
      final result = await _uploadPictureUseCase(image);

      return result.fold(
            (failure) {
          _state = _state.copyWith(
            status: ProfileStatus.error,
            errorMessage: failure.message,
          );
          notifyListeners();
          return false;
        },
            (imageUrl) {
          // Update profile with new image URL
          if (_state.profile != null) {
            _state = _state.copyWith(
              profile: _state.profile!.copyWith(
                profilePictureUrl: imageUrl,
              ),
            );
            notifyListeners();
          }
          return true;
        },
      );
    } catch (e) {
      _state = _state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
      return false;
    }
  }

  /// Add skill
  Future<bool> addSkill(String skillName) async {
    try {
      final result = await _repository.addSkill(skillName);

      return result.fold(
            (failure) {
          _state = _state.copyWith(errorMessage: failure.message);
          notifyListeners();
          return false;
        },
            (_) {
          // Reload profile to get updated skills
          loadCurrentProfile();
          return true;
        },
      );
    } catch (e) {
      return false;
    }
  }

  /// Remove skill
  Future<bool> removeSkill(String skillName) async {
    try {
      final result = await _repository.removeSkill(skillName);

      return result.fold(
            (failure) {
          _state = _state.copyWith(errorMessage: failure.message);
          notifyListeners();
          return false;
        },
            (_) {
          // Reload profile
          loadCurrentProfile();
          return true;
        },
      );
    } catch (e) {
      return false;
    }
  }

  /// Add interest
  Future<bool> addInterest(String interestName) async {
    try {
      final result = await _repository.addInterest(interestName);

      return result.fold(
            (failure) {
          _state = _state.copyWith(errorMessage: failure.message);
          notifyListeners();
          return false;
        },
            (_) {
          // Reload profile
          loadCurrentProfile();
          return true;
        },
      );
    } catch (e) {
      return false;
    }
  }

  /// Remove interest
  Future<bool> removeInterest(String interestName) async {
    try {
      final result = await _repository.removeInterest(interestName);

      return result.fold(
            (failure) {
          _state = _state.copyWith(errorMessage: failure.message);
          notifyListeners();
          return false;
        },
            (_) {
          // Reload profile
          loadCurrentProfile();
          return true;
        },
      );
    } catch (e) {
      return false;
    }
  }

  /// Update availability
  Future<bool> updateAvailability(String status) async {
    try {
      final result = await _repository.updateAvailability(status);

      return result.fold(
            (failure) {
          _state = _state.copyWith(errorMessage: failure.message);
          notifyListeners();
          return false;
        },
            (_) {
          // Update local state
          if (_state.profile != null) {
            _state = _state.copyWith(
              profile: _state.profile!.copyWith(
                availabilityStatus: status,
              ),
            );
            notifyListeners();
          }
          return true;
        },
      );
    } catch (e) {
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }
}