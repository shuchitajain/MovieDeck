# 🎬 MovieDeck

![Flutter](https://img.shields.io/badge/Flutter-3.38+-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.10+-blue?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)
![AI](https://img.shields.io/badge/AI-Gemini%202.0%20Flash-orange?logo=google)

A Flutter movie watchlist app with **AI-powered recommendations** using Google Gemini. Add movies you've watched, organize your watchlist, and get personalized recommendations based on your taste and mood.

## ✨ Features

- **Movie Watchlist** — Add movies with name, director, genre, and poster image
- **AI Recommendations** — Get personalized movie suggestions powered by Gemini 2.0 Flash, grounded in your actual watchlist
- **Mood-based Discovery** — Pick a mood or describe what you want to watch
- **Search & Sort** — Find movies quickly with search, sort A-Z / Z-A / last added
- **Authentication** — Email/password and Google Sign-In via Firebase Auth
- **Local Storage** — SQLite (sqflite) for offline-first data persistence
- **Material 3** — Modern UI with Material 3 theming and dark/light mode support

## 🏗️ Architecture

```
lib/
├── main.dart                    # App entry point, providers setup
├── constants.dart               # Colors, genre list
├── models/
│   └── movie_model.dart         # Movie data model
├── providers/
│   ├── auth_provider.dart       # Firebase Auth logic
│   ├── data_provider.dart       # Movie CRUD, search, sort
│   ├── db_provider.dart         # SQLite operations
│   └── gemini_provider.dart     # Gemini AI integration
└── ui/
    ├── config.dart              # App utilities
    ├── screens/
    │   ├── splash_screen.dart
    │   ├── onboarding_screen.dart
    │   ├── login_screen.dart
    │   ├── signup_screen.dart
    │   ├── home_screen.dart
    │   ├── add_movie_screen.dart
    │   ├── recommendations_screen.dart  # AI recommendations
    │   └── dummy_screen.dart
    └── widgets/
        ├── app_logo_widget.dart
        ├── back_button_widget.dart
        ├── bezier_container_widget.dart
        ├── custom_clipper.dart
        ├── form_field_widget.dart
        └── reusable_button_widget.dart
```

## 🧠 AI Integration

The app uses **Google Gemini 2.0 Flash** (free tier: 15 RPM, 1M tokens/day) for movie recommendations:

1. User's watchlist (titles, genres, directors) is sent as context
2. User selects a mood or types a custom preference
3. Gemini returns 5 structured JSON recommendations with title, genre, year, and a personalized reason
4. Results are rendered as recommendation cards

**Key decisions:**
- Structured JSON output for reliable parsing
- Watchlist grounding so recommendations are personalized, not generic
- API key via `.env` file (not hardcoded, gitignored)

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

4. Add your Gemini API key
   # Edit .env and add: GEMINI_API_KEY=your_key_here

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
| Framework | Flutter 3.38 / Dart 3.10 |
| State Management | Provider |
| Authentication | Firebase Auth + Google Sign-In |
| Database | SQLite (sqflite) |
| AI | Google Gemini 2.0 Flash |
| UI | Material 3 |

## 📄 License

This project is licensed under the MIT License.
