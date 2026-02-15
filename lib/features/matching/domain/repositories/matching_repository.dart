import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/match_suggestion.dart';

/// Matching Repository Interface
///
/// Defines the contract for matching operations
abstract class MatchingRepository {
  /// Get match suggestions for current user
  ///
  /// [limit] - Maximum number of matches to return (default: 20)
  /// [minScore] - Minimum match score 0.0-1.0 (default: 0.0)
  ///
  /// Returns list of [MatchSuggestion] sorted by score (highest first)
  /// or [Failure] on error
  Future<Either<Failure, List<MatchSuggestion>>> getMatchSuggestions({
    int limit = 20,
    double minScore = 0.0,
  });

  /// Get top matches for current user
  ///
  /// Returns top 10 matches with score >= 50%
  Future<Either<Failure, List<MatchSuggestion>>> getTopMatches();

  /// Get match score with specific user
  ///
  /// [userId] - ID of user to calculate match with
  ///
  /// Returns match score (0.0 to 1.0) or [Failure]
  Future<Either<Failure, double>> getMatchScore(String userId);

  /// Refresh match suggestions
  ///
  /// Forces recalculation of all matches
  Future<Either<Failure, List<MatchSuggestion>>> refreshMatches();
}