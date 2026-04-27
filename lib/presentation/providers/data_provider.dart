import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/movie.dart';
import 'repository_providers.dart';

/// Immutable state for the watchlist.
@immutable
class DataState {
  final List<Movie> items;
  final List<Movie> filteredItems;
  final int sorted;
  final String query;
  final String? errorMessage;

  const DataState({
    this.items = const [],
    this.filteredItems = const [],
    this.sorted = 2,
    this.query = '',
    this.errorMessage,
  });

  DataState copyWith({
    List<Movie>? items,
    List<Movie>? filteredItems,
    int? sorted,
    String? query,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DataState(
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      sorted: sorted ?? this.sorted,
      query: query ?? this.query,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  int get isSorted => sorted;

  List<Movie> get displayItems {
    final source = query.isNotEmpty ? filteredItems : items;
    return _sortItems([...source]);
  }

  List<Movie> _sortItems(List<Movie> list) {
    switch (sorted) {
      case 0:
        list.sort((a, b) => a.name.compareTo(b.name));
        return list;
      case 1:
        list.sort((a, b) => b.name.compareTo(a.name));
        return list;
      case 2:
      default:
        return list.reversed.toList();
    }
  }
}

/// Data notifier — depends on MovieRepository (Dependency Inversion).
class DataNotifier extends Notifier<DataState> {
  @override
  DataState build() => const DataState();

  void clearError() => state = state.copyWith(clearError: true);

  void toggle(int newSort) => state = state.copyWith(sorted: newSort);

  void filterItems(String newQuery) {
    if (newQuery.isEmpty) {
      state = state.copyWith(query: '', filteredItems: []);
      return;
    }
    final lower = newQuery.toLowerCase();
    final filtered =
        state.items.where((m) => m.name.toLowerCase().contains(lower)).toList();
    state = state.copyWith(query: newQuery, filteredItems: filtered);
  }

  Future<void> addMovie({
    required String movieName,
    required String directorName,
    required String genre,
    required String imagePath,
    required String createdAt,
    required String updatedAt,
  }) async {
    try {
      final movie = Movie(
        name: movieName,
        director: directorName,
        genre: genre,
        createdOn: createdAt,
        updatedOn: updatedAt,
        imageUrl: imagePath,
      );
      final items = [...state.items];
      final idx = items.indexWhere((e) => e.createdOn == createdAt);
      if (idx >= 0) {
        items[idx] = movie;
      } else {
        items.add(movie);
      }
      state = state.copyWith(items: items);
      await ref.read(movieRepositoryProvider).save(movie);
    } catch (e) {
      state = state.copyWith(
          errorMessage: 'Failed to save movie. Please try again.');
      debugPrint('addMovie error: $e');
    }
  }

  Future<void> deleteMovie(String movieName) async {
    try {
      final items = state.items.where((e) => e.name != movieName).toList();
      state = state.copyWith(items: items);
      await ref.read(movieRepositoryProvider).delete(movieName);
    } catch (e) {
      state = state.copyWith(
          errorMessage: 'Failed to delete movie. Please try again.');
      debugPrint('deleteMovie error: $e');
    }
  }

  Movie? findById(String name) {
    try {
      return state.items.firstWhere((e) => e.name == name);
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchAndSetMovie() async {
    try {
      final items = await ref.read(movieRepositoryProvider).getAll();
      state = state.copyWith(items: items);
    } catch (e) {
      state = state.copyWith(
          errorMessage: 'Failed to load movies. Please restart the app.');
      debugPrint('fetchAndSetMovie error: $e');
    }
  }
}
