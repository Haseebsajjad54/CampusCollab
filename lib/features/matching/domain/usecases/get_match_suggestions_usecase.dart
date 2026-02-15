import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/match_suggestion.dart';
import '../repositories/matching_repository.dart';

/// Get Match Suggestions Use Case
///
/// Fetches personalized match suggestions for current user
/// with validation and filtering options
class GetMatchSuggestionsUseCase {
  final MatchingRepository repository;

  GetMatchSuggestionsUseCase(this.repository);

  /// Execute use case
  ///
  /// [limit] - Maximum number of suggestions (default: 20, max: 100)
  /// [minScore] - Minimum match score 0.0-1.0 (default: 0.0)
  /// [forceRefresh] - Force recalculate matches (default: false)
  ///
  /// Returns list of [MatchSuggestion] sorted by match score (highest first)
  /// or [Failure] if validation fails or operation errors
  Future<Either<Failure, List<MatchSuggestion>>> call({
    int limit = 20,
    double minScore = 0.0,
    bool forceRefresh = false,
  }) async {
    // ✅ VALIDATE LIMIT
    if (limit <= 0) {
      return const Left(
        ValidationFailure(
           'Limit must be greater than 0',
        ),
      );
    }

    if (limit > 100) {
      return const Left(
        ValidationFailure(
           'Limit cannot exceed 100. Please use a smaller limit.',
        ),
      );
    }

    // ✅ VALIDATE MIN SCORE
    if (minScore < 0.0) {
      return const Left(
        ValidationFailure(
           'Minimum score cannot be negative',
        ),
      );
    }

    if (minScore > 1.0) {
      return const Left(
        ValidationFailure(
           'Minimum score cannot exceed 1.0 (100%)',
        ),
      );
    }

    try {
      // Force refresh if requested
      if (forceRefresh) {
        return await repository.refreshMatches();
      }

      // Get suggestions with filters
      return await repository.getMatchSuggestions(
        limit: limit,
        minScore: minScore,
      );
    } catch (e) {
      return Left(
        ServerFailure(
           'Failed to get match suggestions: ${e.toString()}',
        ),
      );
    }
  }

  /// Get top matches (convenience method)
  ///
  /// Returns top 10 matches with score >= 50%
  Future<Either<Failure, List<MatchSuggestion>>> getTopMatches() async {
    try {
      return await repository.getTopMatches();
    } catch (e) {
      return Left(
        ServerFailure(
           'Failed to get top matches: ${e.toString()}',
        ),
      );
    }
  }

  /// Get high quality matches only
  ///
  /// Returns matches with score >= 70%
  Future<Either<Failure, List<MatchSuggestion>>> getHighQualityMatches({
    int limit = 20,
  }) async {
    return await call(
      limit: limit,
      minScore: 0.7,
    );
  }

  /// Get excellent matches only
  ///
  /// Returns matches with score >= 80%
  Future<Either<Failure, List<MatchSuggestion>>> getExcellentMatches({
    int limit = 20,
  }) async {
    return await call(
      limit: limit,
      minScore: 0.8,
    );
  }

  /// Get all matches without filtering
  ///
  /// Returns all possible matches
  Future<Either<Failure, List<MatchSuggestion>>> getAllMatches() async {
    return await call(
      limit: 100,
      minScore: 0.0,
    );
  }
}