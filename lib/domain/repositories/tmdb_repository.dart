import '../entities/tmdb_movie.dart';

/// Abstract TMDB data source — swap to any movie API.
abstract class TMDBRepository {
  Future<List<TMDBMovie>> searchMovies(String query, {int page = 1});
  Future<List<TMDBMovie>> getTrending({int page = 1});
  Future<Map<String, String>> getMovieDetails(int movieId);
  Future<String?> fetchPosterUrl(String title, {String? year});
}
