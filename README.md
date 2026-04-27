# 🎬 MovieDeck

![Flutter](https://img.shields.io/badge/Flutter-3.38+-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.10+-blue?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)
![AI](https://img.shields.io/badge/AI-Gemini%202.0%20Flash-orange?logo=google)

A Flutter movie watchlist app with **AI-powered recommendations** using Google Gemini. Add movies you've watched, organize your watchlist, and get personalized recommendations based on your taste and mood.

## ✨ Features

- **Movie Watchlist** — Add movies manually with name, director, genre, and poster image
- **Discover Movies** — Search and browse 10,000+ movies from TMDB with infinite scroll and pagination
- **AI Recommendations** — Get personalized movie suggestions powered by Gemini 2.0 Flash, grounded in your actual watchlist
- **Mood-based Discovery** — Pick a mood or describe what you want to watch
- **Search & Sort** — Find movies quickly with search, sort A-Z / Z-A / last added
- **Authentication** — Email/password and Google Sign-In via Firebase Auth
- **Local Storage** — SQLite (sqflite v2) for offline-first data persistence
- **Material 3** — Modern UI with Material 3 theming, dark/light mode, rounded poster corners, and proper color contrast
- **Undo Delete** — Deleted movies can be restored via snackbar undo action

## 🏗️ Architecture

```
lib/
├── main.dart                         # App entry point, ProviderScope, theming
├── constants.dart                    # Colors, kPrimaryColor, kGenres
├── domain/
│   ├── entities/
│   │   ├── movie.dart                # Local Movie entity
│   │   └── tmdb_movie.dart           # TMDB API Movie entity
│   └── utils/
│       ├── genre_utils.dart          # Genre normalization
│       └── debouncer.dart            # Search debouncing
├── data/
│   ├── local/
│   │   ├── cache_service.dart        # In-memory cache with TTL
│   │   └── movie_db.dart             # sqflite database operations
│   └── remote/
│       ├── tmdb_service.dart         # TMDB API client
│       └── connectivity_service.dart # Network connectivity check
├── presentation/
│   ├── providers/
│   │   ├── auth_notifier.dart        # Firebase Auth state
│   │   ├── data_notifier.dart        # Local watchlist CRUD
│   │   ├── tmdb_notifier.dart        # TMDB search/trending state
│   │   ├── gemini_notifier.dart      # AI recommendations
│   │   ├── theme_notifier.dart       # Dark/light mode toggle
│   │   └── repository_providers.dart # Repository dependencies
│   └── screens/
│       ├── splash_screen.dart
│       ├── onboarding_screen.dart
│       ├── login_screen.dart
│       ├── signup_screen.dart
│       ├── home_screen.dart          # Watchlist + movie detail sheet
│       ├── add_movie_screen.dart     # Manual add + edit with poster picker
│       ├── discover_screen.dart      # TMDB browse with pagination
│       └── recommendations_screen.dart # AI recommendations
├── ui/
│   ├── config.dart                   # App utilities
│   ├── theme.dart                    # Material 3 light/dark themes
│   └── widgets/
│       ├── movie_detail_sheet.dart   # Reusable bottom sheet
│       ├── back_button_widget.dart
│       ├── form_field_widget.dart    # Theme-aware input fields
│       └── reusable_button_widget.dart
```

## 🧠 AI + Discovery Integration

### Movie Discovery (TMDB API)
- Real-time search of 10,000+ movies from The Movie Database
- Infinite pagination with lazy loading
- Debounced search to reduce API calls
- Fallback & offline cache support

### AI Recommendations (Gemini 2.0 Flash)
The app uses **Google Gemini 2.0 Flash** (free tier: 15 RPM, 1M tokens/day) for personalized recommendations:

1. User's local watchlist (titles, genres, directors) is sent as context
2. User selects a mood or types a custom preference
3. Gemini returns 5 structured JSON recommendations with title, genre, year, and personalized reason
4. Results are rendered as recommendation cards
5. From recommendations, users can add directly to their watchlist

**Key decisions:**
- Structured JSON output for reliable parsing
- Watchlist grounding so recommendations are personalized
- API keys via `.env` file (not hardcoded, gitignored)
- Network-aware flow with connectivity checks
- Reusable `MovieDetailSheet` for both discovery and watchlist

## 🚀 Setup

### Prerequisites
- Flutter 3.38+ / Dart 3.10+
- Firebase project configured (Auth enabled)
- Gemini API key from [aistudio.google.com](https://aistudio.google.com)

### Steps

1. Clone the repo
   ```bash
   git clone https://github.com/shuchitajain/movie_deck.git
   cd movie_deck
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Set up Firebase
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

4. Add your API keys
   Create a `.env` file in the project root:
   ```env
   TMDB_API_KEY=your_tmdb_api_key_here
   GEMINI_API_KEY=your_gemini_api_key_here
   ```
   - Get TMDB API key: [api.themoviedb.org](https://www.themoviedb.org/settings/api)
   - Get Gemini API key: [aistudio.google.com](https://aistudio.google.com)

5. Run the app
   ```bash
   flutter run
   ```

## 📸 Screenshots

<img src = "https://github.com/shuchitajain/movie_deck/blob/main/flutter_01.png" height = "240">   <img src = "https://github.com/shuchitajain/movie_deck/blob/main/flutter_02.png" height = "240" >   <img src = "https://github.com/shuchitajain/movie_deck/blob/main/flutter_03.png" height = "240" >
<img src = "https://github.com/shuchitajain/movie_deck/blob/main/flutter_04.png" height = "240" >   <img src = "https://github.com/shuchitajain/movie_deck/blob/main/flutter_05.png" height = "240" >   <img src = "https://github.com/shuchitajain/movie_deck/blob/main/flutter_06.png" height = "240" >

## 🛠️ Tech Stack

| Layer | Tech |
|-------|------|
| Framework | Flutter 3.38+ / Dart 3.10+ |
| State Management | hooks_riverpod + flutter_hooks |
| Authentication | Firebase Auth + Google Sign-In |
| Database | SQLite (sqflite v2) |
| API Discovery | The Movie Database (TMDB) |
| AI | Google Gemini 2.0 Flash |
| UI | Material 3 + google_fonts |
| Storage | flutter_secure_storage |
| Image Caching | cached_network_image |
| HTTP Client | http |
| Navigation | page_transition |

## 📄 License

This project is licensed under the MIT License.
