import '../entities/movie.dart';

/// Abstract movie storage — implement for sqflite, Hive, etc.
/// Single Responsibility: only handles CRUD for movies.
/// Open/Closed: extend by creating a new implementation, not modifying this.
abstract class MovieRepository {
  Future<List<Movie>> getAll();
  Future<List<Movie>> findByName(String name);
  Future<void> save(Movie movie);
  Future<void> delete(String movieName);
  Future<void> deleteAll();
}
