import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movie_deck/providers/auth_provider.dart';
import 'package:movie_deck/providers/theme_provider.dart';

// New architecture imports
import 'package:movie_deck/presentation/providers/data_provider.dart';
import 'package:movie_deck/presentation/providers/gemini_notifier.dart';
import 'package:movie_deck/presentation/providers/tmdb_notifier.dart';

// Re-export for screens
export 'package:movie_deck/presentation/providers/data_provider.dart'
    show DataState, DataNotifier;
export 'package:movie_deck/presentation/providers/gemini_notifier.dart'
    show GeminiState, GeminiNotifier;
export 'package:movie_deck/presentation/providers/tmdb_notifier.dart'
    show TMDBState, TMDBNotifier;
export 'package:movie_deck/presentation/providers/repository_providers.dart';

// Auth
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

// Data (movies) — now uses MovieRepository
final dataProvider = NotifierProvider<DataNotifier, DataState>(() {
  return DataNotifier();
});

// Gemini AI — with caching + offline support
final geminiProvider = NotifierProvider<GeminiNotifier, GeminiState>(() {
  return GeminiNotifier();
});

// Theme
final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(() {
  return ThemeNotifier();
});

// TMDB discover — with debounce + pagination + cache
final tmdbMoviesProvider = NotifierProvider<TMDBNotifier, TMDBState>(() {
  return TMDBNotifier();
});
