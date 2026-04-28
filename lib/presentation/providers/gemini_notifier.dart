import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/local/cache_service.dart';
import '../../data/remote/connectivity_service.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/recommendation.dart';
import 'repository_providers.dart';

/// Immutable Gemini state.
@immutable
class GeminiState {
  final List<Recommendation> recommendations;
  final bool isLoading;
  final String? error;

  const GeminiState({
    this.recommendations = const [],
    this.isLoading = false,
    this.error,
  });

  GeminiState copyWith({
    List<Recommendation>? recommendations,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return GeminiState(
      recommendations: recommendations ?? this.recommendations,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class GeminiNotifier extends Notifier<GeminiState> {
  late String _apiKey;
  late GenerativeModel _model;
  late GenerativeModel _fallbackModel;
  final _cache = CacheService.instance;

  @override
  GeminiState build() {
    _apiKey = const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    try {
      final dotenvKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      if (dotenvKey.isNotEmpty) _apiKey = dotenvKey;
    } catch (_) {}

    final config = GenerationConfig(responseMimeType: 'application/json');
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      generationConfig: config,
    );
    _fallbackModel = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
      generationConfig: config,
    );
    return const GeminiState();
  }

  bool get isConfigured => _apiKey.isNotEmpty && _apiKey != 'your_api_key_here';

  String _buildPrompt(List<Movie> watchlist, String? mood) {
    final watchlistText = watchlist.isEmpty
        ? "The user hasn't added any movies yet."
        : watchlist
            .map(
              (m) =>
                  '- ${m.name} (${m.genre.isEmpty ? "Unknown genre" : m.genre}), directed by ${m.director}',
            )
            .join('\n');
    final moodText = (mood != null && mood.isNotEmpty) ? '\nMood: $mood' : '';
    return '''
You are a movie recommendation assistant. Recommend exactly 5 movies.

User's watchlist:
$watchlistText
$moodText

Return a JSON array of 5 objects: "title", "genre", "year", "director", "reason".
Do NOT include movies already in the watchlist.
''';
  }

  Future<void> getRecommendations(List<Movie> watchlist, {String? mood}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    // Check if cache is still valid (skip API call)
    final cachedRecs = await _cache.read('last_recommendations');
    if (cachedRecs != null) {
      final recs = (cachedRecs as List)
          .map((j) => Recommendation.fromJson(j as Map<String, dynamic>))
          .toList();
      state = state.copyWith(recommendations: recs, isLoading: false);
      debugPrint('Served recommendations from cache (24h)');
      return;
    }

    // Cache is expired or doesn't exist - check connection
    final online = await ConnectivityService.isOnline;
    if (!online) {
      state = state.copyWith(
        error: 'You are offline. Connect to get AI recommendations.',
        isLoading: false,
      );
      return;
    }

    try {
      final prompt = _buildPrompt(watchlist, mood);
      final content = [Content.text(prompt)];

      GenerateContentResponse response;
      try {
        response = await _model.generateContent(content);
      } catch (e) {
        final msg = e.toString();
        if (msg.contains('503') ||
            msg.contains('UNAVAILABLE') ||
            msg.contains('overloaded')) {
          response = await _fallbackModel.generateContent(content);
        } else {
          rethrow;
        }
      }

      final text = _extractJson(response);
      final jsonList = _parseJsonList(text);
      final recs = jsonList
          .map((j) => Recommendation.fromJson(j as Map<String, dynamic>))
          .toList();

      state = state.copyWith(recommendations: recs, isLoading: false);

      // Cache for 24 hours (daily limit)
      await _cache.write(
        'last_recommendations',
        jsonList,
        ttl: const Duration(hours: 24),
      );

      final tmdb = ref.read(tmdbRepositoryProvider);
      _fetchPostersInBackground(recs, tmdb);
    } catch (e) {
      state = state.copyWith(
        error: _friendlyError(e.toString()),
        isLoading: false,
      );
      debugPrint('Gemini error: $e');
    }
  }

  String _extractJson(GenerateContentResponse response) {
    String text = '';
    if (response.candidates.isNotEmpty) {
      for (final part in response.candidates.first.content.parts) {
        if (part is TextPart) {
          final c = part.text.trim();
          if (c.startsWith('[') || c.startsWith('{')) {
            try {
              jsonDecode(c);
              return c;
            } catch (_) {}
          }
          if (text.isEmpty) text = c;
        }
      }
    }
    if (text.isEmpty) text = response.text ?? '';
    final start = text.indexOf(RegExp(r'[\[{]'));
    if (start > 0) text = text.substring(start);
    return text;
  }

  List<dynamic> _parseJsonList(String text) {
    try {
      final decoded = jsonDecode(text);
      if (decoded is List) return decoded;
      if (decoded is Map) {
        final list = decoded.values.firstWhere(
          (v) => v is List,
          orElse: () => null,
        );
        if (list != null) return list as List;
      }
    } catch (_) {}
    final match = RegExp(r'\[[\s\S]*\]').firstMatch(text);
    if (match != null) return jsonDecode(match.group(0)!);
    throw Exception('Could not parse AI response');
  }

  String _friendlyError(String msg) {
    if (msg.contains('503') || msg.contains('UNAVAILABLE')) {
      return 'AI is busy. Try again in a moment.';
    }
    if (msg.contains('429')) {
      return 'Rate limit reached. Please wait before trying again.';
    }
    if (msg.contains('quota') || msg.contains('Quota exceeded')) {
      return 'Daily quota reached. Try again tomorrow or check your API plan.';
    }
    if (msg.contains('401') || msg.contains('403') || msg.contains('API key')) {
      return 'API key issue. Check your .env file.';
    }
    return 'Something went wrong. Please try again.';
  }

  Future<void> _fetchPostersInBackground(
    List<Recommendation> recs,
    dynamic tmdb,
  ) async {
    try {
      final updated = <Recommendation>[];
      for (final rec in recs) {
        final url = await tmdb.fetchPosterUrl(rec.title, year: rec.year);
        updated.add(rec.copyWith(posterUrl: url ?? ''));
      }
      if (state.recommendations.isNotEmpty &&
          state.recommendations.first.title == updated.first.title) {
        state = state.copyWith(recommendations: updated);
      }
    } catch (e) {
      debugPrint('Poster fetch error: $e');
    }
  }

  void clearRecommendations() => state = const GeminiState();
}
