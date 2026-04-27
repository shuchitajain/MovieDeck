import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../data/remote/api_client.dart';
import '../../domain/entities/tmdb_movie.dart';
import '../../domain/repositories/tmdb_repository.dart';
import '../../domain/utils/genre_utils.dart';

/// Concrete TMDB implementation using ApiClient (with retry + backoff).
/// Merges old TMDBProvider + PosterService into one class (DRY).
class TMDBRepositoryImpl implements TMDBRepository {
  static const _baseUrl = 'https://api.themoviedb.org/3';
  final ApiClient _api;

  TMDBRepositoryImpl({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  String get _apiKey => dotenv.env['TMDB_API_KEY'] ?? '';
  bool get isConfigured => _apiKey.isNotEmpty;

  @override
  Future<List<TMDBMovie>> searchMovies(String query, {int page = 1}) async {
    if (!isConfigured) return [];
    try {
      final q = Uri.encodeComponent(query);
      final url = Uri.parse(
          '$_baseUrl/search/movie?api_key=$_apiKey&query=$q&page=$page&language=en-US');
      final response = await _api.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['results'] as List? ?? [])
            .map((j) => TMDBMovie.fromJson(j as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('TMDB search error: $e');
    }
    return [];
  }

  @override
  Future<List<TMDBMovie>> getTrending({int page = 1}) async {
    if (!isConfigured) return [];
    try {
      final url = Uri.parse(
          '$_baseUrl/trending/movie/week?api_key=$_apiKey&page=$page&language=en-US');
      final response = await _api.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['results'] as List? ?? [])
            .map((j) => TMDBMovie.fromJson(j as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('TMDB trending error: $e');
    }
    return [];
  }

  @override
  Future<Map<String, String>> getMovieDetails(int movieId) async {
    if (!isConfigured) return {'director': 'Unknown', 'genre': 'Other'};
    try {
      final url = Uri.parse(
          '$_baseUrl/movie/$movieId?api_key=$_apiKey&append_to_response=credits&language=en-US');
      final response = await _api.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final crew = data['credits']?['crew'] as List? ?? [];
        final director = crew.firstWhere(
          (c) => c['job'] == 'Director',
          orElse: () => {'name': 'Unknown'},
        );
        final genres = data['genres'] as List? ?? [];
        final rawGenre =
            genres.isNotEmpty ? genres.first['name'] ?? 'Other' : 'Other';
        return {
          'director': director['name'] ?? 'Unknown',
          'genre': normalizeGenre(rawGenre),
        };
      }
    } catch (e) {
      debugPrint('TMDB details error: $e');
    }
    return {'director': 'Unknown', 'genre': 'Other'};
  }

  @override
  Future<String?> fetchPosterUrl(String title, {String? year}) async {
    if (!isConfigured) return null;
    try {
      final q = Uri.encodeComponent(title);
      final yearParam = (year != null && year.isNotEmpty) ? '&year=$year' : '';
      final url = Uri.parse(
          '$_baseUrl/search/movie?api_key=$_apiKey&query=$q$yearParam&page=1');
      final response = await _api.get(url);
      if (response.statusCode == 200) {
        final results = jsonDecode(response.body)['results'] as List;
        if (results.isNotEmpty) {
          final path = results[0]['poster_path'];
          if (path != null && path.toString().isNotEmpty) {
            return 'https://image.tmdb.org/t/p/w500$path';
          }
        }
      }
    } catch (e) {
      debugPrint('Poster fetch error: $e');
    }
    return null;
  }
}
