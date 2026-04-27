import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/local/sqflite_movie_repository.dart';
import '../../data/remote/tmdb_repository_impl.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../domain/repositories/tmdb_repository.dart';

// ── Repository providers (Dependency Inversion: depend on abstractions) ──
final movieRepositoryProvider = Provider<MovieRepository>((_) {
  return SqfliteMovieRepository();
});

final tmdbRepositoryProvider = Provider<TMDBRepository>((_) {
  return TMDBRepositoryImpl();
});
