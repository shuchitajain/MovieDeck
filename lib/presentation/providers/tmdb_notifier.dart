import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/local/cache_service.dart';
import '../../data/remote/connectivity_service.dart';
import '../../domain/entities/tmdb_movie.dart';
import '../../domain/utils/debouncer.dart';
import 'repository_providers.dart';

/// Immutable state for discover/search.
@immutable
class TMDBState {
  final List<TMDBMovie> movies;
  final bool isLoading;
  final bool hasMore;

  const TMDBState({
    this.movies = const [],
    this.isLoading = false,
    this.hasMore = true,
  });

  TMDBState copyWith({
    List<TMDBMovie>? movies,
    bool? isLoading,
    bool? hasMore,
  }) {
    return TMDBState(
      movies: movies ?? this.movies,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class TMDBNotifier extends Notifier<TMDBState> {
  int _currentPage = 1;
  String _currentQuery = '';
  bool _isTrending = true;
  final _debouncer = Debouncer();
  final _cache = CacheService.instance;

  @override
  TMDBState build() => const TMDBState();

  /// Debounced search — cancels previous pending search.
  void searchMoviesDebounced(String query) {
    _debouncer.run(() => searchMovies(query));
  }

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      state = const TMDBState();
      return;
    }
    _currentQuery = query;
    _currentPage = 1;
    _isTrending = false;
    state = state.copyWith(isLoading: true);

    final repo = ref.read(tmdbRepositoryProvider);
    final results = await repo.searchMovies(query, page: 1);
    state = TMDBState(
      movies: results,
      hasMore: results.length >= 20,
      isLoading: false,
    );
  }

  Future<void> getTrending() async {
    _currentQuery = '';
    _currentPage = 1;
    _isTrending = true;
    state = state.copyWith(isLoading: true);

    // Try cache first if offline
    final online = await ConnectivityService.isOnline;
    if (!online) {
      final cached = await _cache.read('trending_page_1');
      if (cached != null) {
        final movies = (cached as List)
            .map((j) => TMDBMovie.fromJson(j as Map<String, dynamic>))
            .toList();
        state = TMDBState(movies: movies, hasMore: false, isLoading: false);
        return;
      }
    }

    final repo = ref.read(tmdbRepositoryProvider);
    final results = await repo.getTrending(page: 1);

    // Cache for offline
    if (results.isNotEmpty) {
      await _cache.write(
        'trending_page_1',
        results
            .map(
              (m) => {
                'id': m.id,
                'title': m.title,
                'poster_path': m.posterPath,
                'release_date': m.releaseDate,
                'vote_average': m.voteAverage,
                'overview': m.overview,
              },
            )
            .toList(),
        ttl: const Duration(hours: 6),
      );
    }

    state = TMDBState(
      movies: results,
      hasMore: results.length >= 20,
      isLoading: false,
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);

    _currentPage++;
    final repo = ref.read(tmdbRepositoryProvider);
    final results = _isTrending
        ? await repo.getTrending(page: _currentPage)
        : await repo.searchMovies(_currentQuery, page: _currentPage);

    state = TMDBState(
      movies: [...state.movies, ...results],
      hasMore: results.length >= 20,
      isLoading: false,
    );
  }

  void clear() {
    _debouncer.cancel();
    state = const TMDBState();
    _currentPage = 1;
  }
}
