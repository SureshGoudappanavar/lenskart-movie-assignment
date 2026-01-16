import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';

class StorageService {
  static const String _favoritesKey = 'favorites';
  static const String _watchlistKey = 'watchlist';

  static Future<List<Movie>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_favoritesKey);
    if (data == null) return [];

    final List decoded = json.decode(data);
    return decoded.map((item) => Movie.fromTMDBJson(item)).toList();
  }

  static Future<void> saveFavorites(List<Movie> movies) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = json.encode(movies.map((m) => m.toJson()).toList());
    await prefs.setString(_favoritesKey, data);
  }

  static Future<List<Movie>> getWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_watchlistKey);
    if (data == null) return [];

    final List decoded = json.decode(data);
    return decoded.map((item) => Movie.fromTMDBJson(item)).toList();
  }

  static Future<void> saveWatchlist(List<Movie> movies) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = json.encode(movies.map((m) => m.toJson()).toList());
    await prefs.setString(_watchlistKey, data);
  }
}
