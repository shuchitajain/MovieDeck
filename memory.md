# Memory — MovieDeck Conversations

## Session 1 — April 27, 2026
- Full project analysis, planned revamp
- SDK upgrade, Material 3, genre field, DB migration, AI recommendations screen
- Created gemini_provider.dart, recommendations_screen.dart
- flutter analyze → 0 issues

## Session 2 — April 27, 2026

### What we did
1. **Replaced Provider with hooks_riverpod** across entire app
   - Added `hooks_riverpod` + `flutter_hooks` to pubspec, removed `provider`
   - Created `lib/providers/providers.dart` — central Riverpod provider definitions
   - All screens migrated: StatefulWidget → ConsumerStatefulWidget
   - All `Provider.of` / `Consumer<T>` → `ref.read` / `ref.watch` / `Consumer`
2. **Created ThemeProvider** with dark/light toggle persisted via FlutterSecureStorage
3. **Created `lib/ui/theme.dart`** with extracted lightTheme / darkTheme
4. **Added theme toggle button** in home_screen app bar (sun/moon icon)
5. **Replaced ALL hardcoded colors** (kBlackColor, kWhiteColor, kGreyColor) with `Theme.of(context).colorScheme` tokens across home_screen, add_movie_screen, recommendations_screen, login_screen, signup_screen
6. **Fixed AuthProvider ambiguous import** in providers.dart (using `as app_auth`)

### Current state
- `flutter analyze` → **0 issues**
- Full Riverpod migration complete
- Dark mode fully functional (colorScheme tokens everywhere)
- Remaining: error handling in providers, runtime testing, tests, CI

## Session 3 — April 28, 2026

### Build Fixes
- Android: ndkVersion "28.2.13676358", google-services.json placement, android:exported="true"
- Gradle: migrated to .gradle.kts, JVM toolchain for Kotlin/Java compat, heap space → 4096m
- iOS: provisioning profile requires Apple Developer enrollment ($99/yr) OR physical device

### Gemini Integration
- Model: gemini-2.5-flash (primary) + gemini-2.0-flash (fallback on 503)
- `responseMimeType: 'application/json'` for structured output
- Parsing: skip thinking tokens, try each TextPart for valid JSON, regex fallback
- Error display: user-friendly messages, not raw exceptions
- Prompt: English-only movies, JSON array format enforced

### TMDB Integration (NEW)
- Created `tmdb_provider.dart`: TMDBProvider (static API), TMDBNotifier (Notifier), TMDBState (reactive)
- Created `discover_screen.dart`: trending grid, search, infinite scroll, movie detail bottom sheet
- Created `poster_service.dart`: poster URL lookup for Gemini recommendations
- Detail sheet: DraggableScrollableSheet with poster, title, chips (year/rating/genre), director, overview, add/remove button
- Director + genre fetched from TMDB credits API on add
- API key: MUST use getter (`get _apiKey`), not static final

### Home Screen Changes
- Removed search bar (useless on small watchlist, search lives in Discover)
- FAB bottom sheet: Discover (first) / AI Recommendations / Add Manually
- Dark mode cards: border + primary glow shadow instead of dark shadow
- Bottom padding (110px) for FAB clearance
- Poster display: CachedNetworkImage for URLs, File for local, gradient placeholder for missing

### Add/Edit Movie Screen
- Title: "Edit movie" when editing, "Add a movie" when adding
- Genre: fuzzy-match to kGenres, DropdownButtonFormField with `initialValue`
- Poster: CachedNetworkImage for network URLs, no poster requirement when editing
- Poster not required when editing existing movie

### Design Decisions
- Edit button: kept but secondary (mainly for fixing Gemini/TMDB data)
- Discover screen is primary way to add movies
- AI Recommendations for mood-based discovery
- Add Manually as fallback
