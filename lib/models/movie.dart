class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String releaseDate;
  final double voteAverage;
  final List<String> genres;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.genres,
  });

  // Factory constructor for TVMaze JSON
  factory Movie.fromTVMazeJson(Map<String, dynamic> json) {
    final image = json['image'];
    final premiered = json['premiered'] ?? '';
    final rating = json['rating'];
    final genresList = json['genres'] as List<dynamic>?;

    return Movie(
      id: json['id'] ?? 0,
      title: json['name'] ?? '',
      overview: json['summary']?.replaceAll(RegExp(r'<[^>]*>'), '') ?? '',
      posterPath: image?['medium'] ?? '',
      backdropPath: image?['original'] ?? '',
      releaseDate: premiered,
      voteAverage: (rating?['average'] ?? 0).toDouble(),
      genres: genresList?.map((g) => g.toString()).toList() ?? [],
    );
  }

  // Convert Movie to JSON (for storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'release_date': releaseDate,
      'vote_average': voteAverage,
      'genres': genres,
    };
  }

  // Factory constructor from JSON (for storage)
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      releaseDate: json['release_date'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      genres: List<String>.from(json['genres'] ?? []),
    );
  }

  // Full image URLs (TVMaze provides full URLs)
  String get fullPosterPath => posterPath;
  String get fullBackdropPath => backdropPath;
}
