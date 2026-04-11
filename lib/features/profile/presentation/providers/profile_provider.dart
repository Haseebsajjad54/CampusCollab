import 'dart:io';
import 'package:campus_collab/core/errors/failures.dart';
import 'package:campus_collab/features/posts/domain/entities/post.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
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
  loaded,
}

/// Profile State
class ProfileState {
  final ProfileStatus status;
  final Profile? profile;
  final Map<String, int>? stats;
  final String? errorMessage;
  final List<Post>? userPosts;

  ProfileState({
    required this.status,
    this.profile,
    this.stats,
    this.errorMessage,
    this.userPosts,
  });

  factory ProfileState.initial() {
    return ProfileState(
      status: ProfileStatus.initial,
      profile: null,
      stats: {},
      userPosts: const [],
      errorMessage: null,
    );
  }

  ProfileState copyWith({
    ProfileStatus? status,
    Profile? profile,
    Map<String, int>? stats,
    String? errorMessage,
    List<Post>? userPosts,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      stats: stats ?? this.stats,
      errorMessage: errorMessage,
      userPosts: userPosts ?? this.userPosts,
    );
  }

  bool get isLoading => status == ProfileStatus.loading;
  bool get hasError => status == ProfileStatus.error;
  bool get hasProfile => profile != null;
  ProfileStatus get profileStatus => status;
}

/// Profile Provider
class ProfileProvider extends ChangeNotifier {
  late final GetProfileUseCase _getProfileUseCase;
  late final UpdateProfileUseCase _updateProfileUseCase;
  late final UploadProfilePictureUseCase _uploadPictureUseCase;
  late final ProfileRepositoryImpl _repository;
  late final authLocalDataSource = AuthLocalDataSourceImpl();
  File? _tempImage;
  File? get tempImage => _tempImage;
  late final SupabaseClient supabaseClient = Supabase.instance.client;

  final ValueNotifier<ProfileState> _stateNotifier = ValueNotifier(ProfileState.initial());
  ValueNotifier<ProfileState> get stateNotifier => _stateNotifier;

  ProfileState _state = ProfileState.initial();
  ProfileState get state => _state;

  Profile? get profile => _state.profile;
  Map<String, int>? get stats => _state.stats;
  bool get isLoading => _state.isLoading;
  bool get hasError => _state.hasError;
  String? get errorMessage => _state.errorMessage;
  List<Post>? get userPosts => _state.userPosts;

  ProfileProvider() {
    _initializeUseCases();
    _setupAuthListener();
  }

  void _initializeUseCases() {
    final supabase = Supabase.instance.client;
    _repository = ProfileRepositoryImpl(supabaseClient: supabase);
    _getProfileUseCase = GetProfileUseCase(_repository);
    _updateProfileUseCase = UpdateProfileUseCase(_repository);
    _uploadPictureUseCase = UploadProfilePictureUseCase(_repository);

    // Only load profile if user is already logged in
    if (supabase.auth.currentUser != null) {
      loadCurrentProfile();
    }
  }

  /// Listen to auth state changes
  void _setupAuthListener() {
    supabaseClient.auth.onAuthStateChange.listen((event) {
      if (event.event == AuthChangeEvent.signedOut) {
        // ✅ Clear all data on logout
        _clearAllData();
      } else if (event.event == AuthChangeEvent.signedIn) {
        // ✅ Reload profile on login
        loadCurrentProfile();
      }
    });
  }

  /// Clear all profile data
  void _clearAllData() {
    _state = ProfileState.initial();
    _stateNotifier.value = _state;
    notifyListeners();
  }

  /// Reset profile state to initial
  void resetState() {
    _clearAllData();
  }

  /// Load current user's profile
  Future<void> loadCurrentProfile() async {
    final currentUser = supabaseClient.auth.currentUser;

    // ✅ If no user is logged in, reset state
    if (currentUser == null) {
      _clearAllData();
      return;
    }

    // Prevent multiple loads
    if (_state.status == ProfileStatus.loading) return;

    _updateState(_state.copyWith(status: ProfileStatus.loading));

    final result = await _getProfileUseCase.getCurrentProfile();

    await result.fold(
          (failure) async {
        _updateState(_state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        ));
      },
          (profile) async {
        try {
          // Load stats
          final statsResult = await _repository.getUserStats(profile.id);

          _updateState(_state.copyWith(
            status: ProfileStatus.success,
            profile: profile,
            stats: statsResult.getOrElse(() => {}),
          ));

          // Load user posts after profile is loaded
          await fetchCurrentUserPosts();
        } catch (e) {
          _updateState(_state.copyWith(
            status: ProfileStatus.success,
            profile: profile,
            stats: {},
          ));
          await fetchCurrentUserPosts();
        }
      },
    );
  }

  /// Fetch current user's posts
  Future<void> fetchCurrentUserPosts() async {
    final currentUser = supabaseClient.auth.currentUser;

    // ✅ If no user is logged in, reset posts
    if (currentUser == null) {
      _updateState(_state.copyWith(userPosts: []));
      return;
    }

    try {
      final result = await _repository.fetchCurrentUserPosts();

      result.fold(
            (failure) {
          print('Error fetching posts: ${failure.message}');
          _updateState(_state.copyWith(userPosts: []));
        },
            (posts) {
          _updateState(_state.copyWith(userPosts: posts));
        },
      );
    } catch (e) {
      print('Error in fetchCurrentUserPosts: $e');
      _updateState(_state.copyWith(userPosts: []));
    }
  }

  /// Helper method to update state and notify listeners
  void _updateState(ProfileState newState) {
    _state = newState;
    _stateNotifier.value = newState;
    notifyListeners();
  }

  /// Load profile by user ID
  Future<void> loadProfileById(String userId) async {
    _updateState(_state.copyWith(status: ProfileStatus.loading));

    final result = await _getProfileUseCase.getProfileById(userId);

    result.fold(
          (failure) {
        _updateState(ProfileState(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        ));
      },
          (profile) async {
        // Load stats
        final statsResult = await _repository.getUserStats(profile.id);

        _updateState(ProfileState(
          status: ProfileStatus.success,
          profile: profile,
          stats: statsResult.getOrElse(() => {}),
        ));
      },
    );
  }

  /// Update profile
  Future<bool> updateProfile(Profile profile) async {
    _updateState(_state.copyWith(status: ProfileStatus.loading));

    final result = await _updateProfileUseCase.updateProfile(profile);

    return result.fold(
          (failure) {
        _updateState(_state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        ));
        return false;
      },
          (updatedProfile) {
        _updateState(_state.copyWith(
          status: ProfileStatus.success,
          profile: updatedProfile,
        ));
        return true;
      },
    );
  }

  /// Upload profile picture
  Future<bool> uploadProfilePicture(File image) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = image.path.split('.').last;
      final fileName = '${currentUser.id}_$timestamp.$extension';
      final path = 'profile_pictures/$fileName';

      await supabaseClient.storage
          .from('ProfileImages')
          .upload(path, image);

      final publicUrl = supabaseClient.storage
          .from('ProfileImages')
          .getPublicUrl(path);

      await supabaseClient
          .from('profiles')
          .update({'profile_picture_url': publicUrl})
          .eq('id', currentUser.id);

      // Reload profile to get updated picture
      await loadCurrentProfile();

      print('✅ Upload successful!');
      return true;
    } catch (e) {
      print('❌ Upload failed: $e');
      return false;
    }
  }

  /// Add skill
  Future<bool> addSkill(String skillName) async {
    try {
      final result = await _repository.addSkill(skillName);

      return result.fold(
            (failure) {
          _updateState(_state.copyWith(errorMessage: failure.message));
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
          _updateState(_state.copyWith(errorMessage: failure.message));
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
          _updateState(_state.copyWith(errorMessage: failure.message));
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
          _updateState(_state.copyWith(errorMessage: failure.message));
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
          _updateState(_state.copyWith(errorMessage: failure.message));
          return false;
        },
            (_) {
          // Update local state
          if (_state.profile != null) {
            _updateState(_state.copyWith(
              profile: _state.profile!.copyWith(
                availabilityStatus: status,
              ),
            ));
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
    _updateState(_state.copyWith(errorMessage: null));
  }

  void uploadImage() async {
    try {
      //final result = await authLocalDataSource.uploadImage();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void testBucket() {
    _repository.testBucketAccess();
  }

  @override
  void dispose() {
    _stateNotifier.dispose();
    super.dispose();
  }
}