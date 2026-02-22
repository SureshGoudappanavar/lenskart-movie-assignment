import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  static const String _baseUrl = 'https://api.tvmaze.com';

  // Get popular movies (using TVMaze shows)
  static Future<List<Movie>> getPopularMovies({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/shows?page=$page'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((show) => Movie.fromTVMazeJson(show)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }

  // Search movies
  static Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/search/shows?q=$query'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((item) => Movie.fromTVMazeJson(item['show'])).toList();
    } else {
      throw Exception('Failed to search movies');
    }
  }

  // Get movie details
  static Future<Movie> getMovieDetails(int movieId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/shows/$movieId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Movie.fromTVMazeJson(data);
    } else {
      throw Exception('Failed to load movie details');
    }
  }
}
