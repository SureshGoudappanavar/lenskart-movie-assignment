import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  static const String _baseUrl = 'https://api.tvmaze.com';

  // Get popular shows (TVMaze doesn't have "popular" endpoint, so we use shows list)
  static Future<List<Movie>> getPopularMovies({int page = 0}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/shows?page=$page'),
    );

    if (response.statusCode == 200) {
      final List results = json.decode(response.body);
      return results.take(20).map((show) => Movie.fromTVMazeJson(show)).toList();
    } else {
      throw Exception('Failed to load shows');
    }
  }

  // Search shows
  static Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/search/shows?q=$query'),
    );

    if (response.statusCode == 200) {
      final List results = json.decode(response.body);
      return results.map((item) => Movie.fromTVMazeJson(item)).toList();
    } else {
      throw Exception('Failed to search shows');
    }
  }

  // Get show details
  static Future<Movie> getMovieDetails(int showId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/shows/$showId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Movie.fromTVMazeJson(data);
    } else {
      throw Exception('Failed to load show details');
    }
  }
}
