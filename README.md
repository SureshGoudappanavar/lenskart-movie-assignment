# Lenskart Movie Assignment

A Flutter movie application built for the Lenskart Mobile Dev Assignment using TMDB API.

## � API Note

> Initially, the TMDB API was not working due to API key registration delays, so I temporarily used TVMaze API as an alternative. Now that TMDB is working, the app has been updated to use **TMDB (The Movie Database)** as specified in the assignment requirements.

## 📱 Download APK

**Pre-built APK available at:** `build/app/outputs/flutter-apk/app-release.apk`

Or build it yourself:
```bash
flutter build apk --release
```

## 📱 Features

### Core Features
- **Splash Screen** - Animated logo with smooth transitions
- **Bottom Navigation** - Movies (landing), Favourites, Watchlist
- **Movies Screen** - Browse movies with images, names, and genre cards
- **Search** - Search for movies on the same screen
- **Favourites** - User's favourite list (unique per user, persisted locally)
- **Watchlist** - Movies to watch later (unique per user, persisted locally)

### Movie Details Screen
- Movie Banner/Poster
- Name
- Overview/Description
- Release Date
- Genre chips
- User Rating (Circular Progress Bar)
- **Play Now** - Triggers In-App Notification with "Movie is Playing"

### UI/UX Features
- Featured Hero Card with auto-sliding (3 sec interval)
- Thumbnail selector for featured movies
- Responsive layout (Desktop, Tablet, Mobile)
- Loading, Empty, and Error states
- Dark theme with Material Design 3
- Clean, minimal UI

## 🛠️ Tech Stack

- **Framework:** Flutter (Dart)
- **API:** TMDB (The Movie Database)
- **State Management:** Provider
- **Local Storage:** SharedPreferences
- **Notifications:** flutter_local_notifications

## � Dependencies

```yaml
dependencies:
  http: ^1.2.0
  provider: ^6.1.2
  cached_network_image: ^3.3.1
  shared_preferences: ^2.2.3
  flutter_local_notifications: ^18.0.1
  percent_indicator: ^4.2.3
```

## � Setup & Run

```bash
# Clone the repository
git clone https://github.com/SureshGoudappanavar/lenskart-movie-assignment.git

# Navigate to project
cd lenskart-movie-assignment

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## 📁 Project Structure

```
movie_app/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   └── movie.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── notification_service.dart
│   │   └── storage_service.dart
│   ├── providers/
│   │   ├── movie_provider.dart
│   │   └── user_lists_provider.dart
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── home_screen.dart
│   │   ├── movies_screen.dart
│   │   ├── favorites_screen.dart
│   │   ├── watchlist_screen.dart
│   │   └── movie_detail_screen.dart
│   └── widgets/
│       ├── movie_card.dart
│       ├── movie_list_tile.dart
│       ├── loading_widget.dart
│       ├── error_widget.dart
│       └── empty_widget.dart
├── android/
├── ios/
├── web/
├── build/app/outputs/flutter-apk/app-release.apk  ← APK FILE
└── pubspec.yaml
```

## ✅ Assignment Requirements Checklist

- [x] Splash Screen with dummy image
- [x] Home Page with Bottom Navigation
- [x] Movies screen with images, names, genre cards
- [x] Search functionality
- [x] Mark movies as Favourites (unique per user)
- [x] Mark movies as Watchlist (unique per user)
- [x] Favourites screen
- [x] Watchlist screen
- [x] Movie details: Banner, Name, Overview, Release Date, Genre
- [x] User ratings as Circular Progress Bar
- [x] Play Now with In-App Notification "Movie is Playing"
- [x] Clean folder structure
- [x] Readable code
- [x] Loading, Empty, Error states
- [x] Responsive for common phone sizes
- [x] Consistent typography and spacing
- [x] Material Design UI

## 📸 Screenshots

### Desktop View
- Featured hero card on left with auto-sliding
- Popular movies grid on right

### Mobile View
- Vertical scroll layout
- Hero card with thumbnail selector
- Horizontal scrolling category rows

## 👤 Author

**Suresh Goudappanavar**

- GitHub: [@SureshGoudappanavar](https://github.com/SureshGoudappanavar)
