import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';

enum LoadingState { initial, loading, loaded, error }

class MovieProvider extends ChangeNotifier {
  List<Movie> _movies = [];
  List<Movie> _searchResults = [];
  LoadingState _state = LoadingState.initial;
  String _errorMessage = '';
  String _searchQuery = '';
  bool _isSearching = false;

  List<Movie> get movies => _isSearching ? _searchResults : _movies;
  LoadingState get state => _state;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;

  Future<void> loadMovies() async {
    _state = LoadingState.loading;
    notifyListeners();

    try {
      _movies = await ApiService.getPopularMovies();
      _state = LoadingState.loaded;
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      _isSearching = false;
      _searchQuery = '';
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    _searchQuery = query;
    _state = LoadingState.loading;
    notifyListeners();

    try {
      _searchResults = await ApiService.searchMovies(query);
      _state = LoadingState.loaded;
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  void clearSearch() {
    _isSearching = false;
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }
}
