# Claude Notes — MovieDeck

## Project Overview
Flutter movie watchlist app with AI-powered recommendations via Google Gemini.

## Key Decisions Made
- **Free-only constraint**: No Firebase Blaze plan. Gemini API free tier (15 RPM, 1M tokens/day).
- **API key handling**: `.env` file via `flutter_dotenv`, gitignored.
- **State management**: Migrated from Provider → **hooks_riverpod** (Session 2).
- **Gemini model**: `gemini-2.0-flash` — fast, free, structured JSON output.
- **Grounding strategy**: User's watchlist sent as context to Gemini.
- **DB migration**: sqflite v1→v2, added `genre TEXT` column.
- **AuthProvider conflict**: Firebase exports `AuthProvider`, so imports use `as app_auth`.
- **Theme**: Material 3 with `ThemeProvider` (persisted via FlutterSecureStorage), toggle in home_screen.
- **Colors**: All screens use `Theme.of(context).colorScheme` tokens — dark mode works properly.

## Architecture
- State: **hooks_riverpod** (ChangeNotifierProvider) | DB: sqflite v2
- Auth: Firebase Auth + Google Sign-In | AI: google_generative_ai → GeminiProvider
- Theme: ThemeProvider persisted in FlutterSecureStorage
- Providers defined in `lib/providers/providers.dart` (authProvider, dataProvider, geminiProvider, themeProvider)

## File Structure
```
lib/
├── main.dart                         # ProviderScope, ConsumerWidget
├── constants.dart                    # kPrimaryColor, kGenres
├── models/movie_model.dart           # Movie with genre
├── providers/
│   ├── providers.dart                # Central Riverpod provider definitions
│   ├── auth_provider.dart            # Firebase Auth ChangeNotifier
│   ├── data_provider.dart            # Movie CRUD ChangeNotifier
│   ├── db_provider.dart              # sqflite operations
│   ├── gemini_provider.dart          # Gemini AI ChangeNotifier
│   └── theme_provider.dart           # Dark/light toggle, persisted
├── ui/
│   ├── config.dart                   # App utilities
│   ├── theme.dart                    # lightTheme / darkTheme
│   ├── screens/                      # All ConsumerStatefulWidget
│   └── widgets/                      # Stateless helpers
```

## What's Done
- ✅ SDK >=3.0.0 <4.0.0, all deps latest
- ✅ hooks_riverpod + flutter_hooks (replaced provider)
- ✅ All screens migrated: ConsumerStatefulWidget, ref.read/ref.watch
- ✅ ThemeProvider with toggle + persistence (FlutterSecureStorage)
- ✅ lib/ui/theme.dart (lightTheme, darkTheme)
- ✅ All hardcoded colors → colorScheme tokens (dark mode works)
- ✅ Material 3 theming
- ✅ Genre field + DB migration + dropdown
- ✅ GeminiProvider + RecommendationsScreen
- ✅ README with badges, architecture, setup
- ✅ flutter analyze → 0 issues
- ✅ try/catch error handling + errorMessage in AuthProvider & DataProvider
- ✅ Error SnackBar display in home_screen

## What's NOT Done Yet
- ❌ Runtime testing with real Gemini API key
- ❌ Unit + widget tests
- ❌ GitHub Actions CI

## Genres
Action, Adventure, Animation, Comedy, Crime, Documentary, Drama, Fantasy, Horror, Musical, Mystery, Romance, Sci-Fi, Thriller, War, Western, Other
