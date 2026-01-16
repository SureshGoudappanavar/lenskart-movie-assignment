import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/storage_service.dart';

class UserListsProvider extends ChangeNotifier {
  List<Movie> _favorites = [];
  List<Movie> _watchlist = [];
  bool _isLoading = true;

  List<Movie> get favorites => _favorites;
  List<Movie> get watchlist => _watchlist;
  bool get isLoading => _isLoading;

  UserListsProvider() {
    _loadLists();
  }

  Future<void> _loadLists() async {
    _isLoading = true;
    notifyListeners();

    _favorites = await StorageService.getFavorites();
    _watchlist = await StorageService.getWatchlist();

    _isLoading = false;
    notifyListeners();
  }

  bool isFavorite(int movieId) {
    return _favorites.any((m) => m.id == movieId);
  }

  bool isInWatchlist(int movieId) {
    return _watchlist.any((m) => m.id == movieId);
  }

  Future<void> toggleFavorite(Movie movie) async {
    if (isFavorite(movie.id)) {
      _favorites.removeWhere((m) => m.id == movie.id);
    } else {
      _favorites.add(movie);
    }
    await StorageService.saveFavorites(_favorites);
    notifyListeners();
  }

  Future<void> toggleWatchlist(Movie movie) async {
    if (isInWatchlist(movie.id)) {
      _watchlist.removeWhere((m) => m.id == movie.id);
    } else {
      _watchlist.add(movie);
    }
    await StorageService.saveWatchlist(_watchlist);
    notifyListeners();
  }
}
