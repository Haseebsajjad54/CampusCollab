import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/matching_repository_impl.dart';
import '../../domain/entities/match_suggestion.dart';
import '../../domain/usecases/get_match_suggestions_usecase.dart';

/// Matching State Status
enum MatchingStatus {
  initial,
  loading,
  success,
  error,
  empty,
}

/// Matching State
class MatchingState {
  final MatchingStatus status;
  final List<MatchSuggestion> matches;
  final String? errorMessage;

  MatchingState({
    required this.status,
    required this.matches,
    this.errorMessage,
  });

  factory MatchingState.initial() {
    return MatchingState(
      status: MatchingStatus.initial,
      matches: [],
    );
  }

  MatchingState copyWith({
    MatchingStatus? status,
    List<MatchSuggestion>? matches,
    String? errorMessage,
  }) {
    return MatchingState(
      status: status ?? this.status,
      matches: matches ?? this.matches,
      errorMessage: errorMessage,
    );
  }

  bool get isLoading => status == MatchingStatus.loading;
  bool get isSuccess => status == MatchingStatus.success;
  bool get hasError => status == MatchingStatus.error;
  bool get isEmpty => status == MatchingStatus.empty;
}

/// Matching Provider
///
/// Manages match suggestions state and operations
class MatchingProvider extends ChangeNotifier {
  late final GetMatchSuggestionsUseCase _getMatchSuggestionsUseCase;

  MatchingState _state = MatchingState.initial();
  MatchingState get state => _state;

  // Convenient getters
  List<MatchSuggestion> get matches => _state.matches;
  bool get isLoading => _state.isLoading;
  bool get hasError => _state.hasError;
  bool get isEmpty => _state.isEmpty;
  String? get errorMessage => _state.errorMessage;

  MatchingProvider() {
    _initializeUseCase();
  }

  /// Initialize use case with Supabase
  void _initializeUseCase() {
    final supabase = Supabase.instance.client;
    final repository = MatchingRepositoryImpl(supabaseClient: supabase);
    _getMatchSuggestionsUseCase = GetMatchSuggestionsUseCase(repository);
  }

  /// Load match suggestions
  ///
  /// [limit] - Maximum number of matches to return (default: 20)
  /// [minScore] - Minimum match score 0.0-1.0 (default: 0.0)
  /// [forceRefresh] - Force recalculate matches (default: false)
  Future<void> loadMatches({
    int limit = 20,
    double minScore = 0.0,
    bool forceRefresh = false,
  }) async {
    try {
      _state = _state.copyWith(status: MatchingStatus.loading);
      notifyListeners();

      final result = await _getMatchSuggestionsUseCase(
        limit: limit,
        minScore: minScore,
        forceRefresh: forceRefresh,
      );

      result.fold(
            (failure) {
          _state = MatchingState(
            status: MatchingStatus.error,
            matches: [],
            errorMessage: failure.message,
          );
        },
            (matches) {
          if (matches.isEmpty) {
            _state = MatchingState(
              status: MatchingStatus.empty,
              matches: [],
            );
          } else {
            _state = MatchingState(
              status: MatchingStatus.success,
              matches: matches,
            );
          }
        },
      );
      notifyListeners();
    } catch (e) {
      _state = MatchingState(
        status: MatchingStatus.error,
        matches: [],
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }

  /// Load top matches (high score only)
  ///
  /// Returns top 10 matches with score >= 50%
  Future<void> loadTopMatches() async {
    try {
      _state = _state.copyWith(status: MatchingStatus.loading);
      notifyListeners();

      final result = await _getMatchSuggestionsUseCase.getTopMatches();

      result.fold(
            (failure) {
          _state = MatchingState(
            status: MatchingStatus.error,
            matches: [],
            errorMessage: failure.message,
          );
        },
            (matches) {
          if (matches.isEmpty) {
            _state = MatchingState(
              status: MatchingStatus.empty,
              matches: [],
            );
          } else {
            _state = MatchingState(
              status: MatchingStatus.success,
              matches: matches,
            );
          }
        },
      );
      notifyListeners();
    } catch (e) {
      _state = MatchingState(
        status: MatchingStatus.error,
        matches: [],
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }

  /// Refresh matches
  ///
  /// Forces recalculation of all match scores
  Future<void> refreshMatches() async {
    await loadMatches(forceRefresh: true);
  }

  /// Filter matches by minimum score
  ///
  /// [minScore] - Minimum match score (0.0 to 1.0)
  ///
  /// Returns filtered list of matches
  List<MatchSuggestion> filterByScore(double minScore) {
    return _state.matches.where((m) => m.matchScore >= minScore).toList();
  }

  /// Filter matches by department
  ///
  /// [department] - Department name
  ///
  /// Returns matches from same department
  List<MatchSuggestion> filterByDepartment(String department) {
    return _state.matches
        .where((m) => m.department == department)
        .toList();
  }

  /// Filter matches by availability
  ///
  /// Returns only available users
  List<MatchSuggestion> filterByAvailability() {
    return _state.matches.where((m) => m.isAvailable).toList();
  }

  /// Filter matches by year of study
  ///
  /// [year] - Year of study
  ///
  /// Returns matches from same year
  List<MatchSuggestion> filterByYear(int year) {
    return _state.matches
        .where((m) => m.yearOfStudy == year)
        .toList();
  }

  /// Get high matches only (>80%)
  ///
  /// Returns matches with excellent score
  List<MatchSuggestion> getHighMatches() {
    return _state.matches.where((m) => m.isHighMatch).toList();
  }

  /// Get medium matches (60-80%)
  ///
  /// Returns matches with good score
  List<MatchSuggestion> getMediumMatches() {
    return _state.matches.where((m) => m.isMediumMatch).toList();
  }

  /// Get low matches (<60%)
  ///
  /// Returns matches with fair score
  List<MatchSuggestion> getLowMatches() {
    return _state.matches.where((m) => m.isLowMatch).toList();
  }

  /// Sort matches by score (highest first)
  List<MatchSuggestion> sortByScore() {
    final sorted = List<MatchSuggestion>.from(_state.matches);
    sorted.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return sorted;
  }

  /// Sort matches by CGPA (highest first)
  List<MatchSuggestion> sortByCGPA() {
    final sorted = List<MatchSuggestion>.from(_state.matches);
    sorted.sort((a, b) {
      if (a.cgpa == null && b.cgpa == null) return 0;
      if (a.cgpa == null) return 1;
      if (b.cgpa == null) return -1;
      return b.cgpa!.compareTo(a.cgpa!);
    });
    return sorted;
  }

  /// Get matches with specific skill
  ///
  /// [skill] - Skill name
  ///
  /// Returns matches who have this skill
  List<MatchSuggestion> getMatchesWithSkill(String skill) {
    return _state.matches
        .where((m) => m.sharedSkills.contains(skill))
        .toList();
  }

  /// Get matches with specific interest
  ///
  /// [interest] - Interest name
  ///
  /// Returns matches who have this interest
  List<MatchSuggestion> getMatchesWithInterest(String interest) {
    return _state.matches
        .where((m) => m.sharedInterests.contains(interest))
        .toList();
  }

  /// Get statistics
  Map<String, dynamic> getStatistics() {
    if (_state.matches.isEmpty) {
      return {
        'total': 0,
        'high': 0,
        'medium': 0,
        'low': 0,
        'available': 0,
        'averageScore': 0.0,
      };
    }

    final total = _state.matches.length;
    final high = getHighMatches().length;
    final medium = getMediumMatches().length;
    final low = getLowMatches().length;
    final available = filterByAvailability().length;
    final averageScore = _state.matches
        .map((m) => m.matchScore)
        .reduce((a, b) => a + b) /
        total;

    return {
      'total': total,
      'high': high,
      'medium': medium,
      'low': low,
      'available': available,
      'averageScore': averageScore,
    };
  }

  /// Clear error message
  void clearError() {
    if (_state.status == MatchingStatus.error) {
      _state = MatchingState.initial();
      notifyListeners();
    }
  }

  /// Clear all matches
  void clearMatches() {
    _state = MatchingState.initial();
    notifyListeners();
  }
}