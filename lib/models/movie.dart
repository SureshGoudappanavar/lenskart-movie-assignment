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

  factory Movie.fromTVMazeJson(Map<String, dynamic> json) {
    final show = json['show'] ?? json;
    final image = show['image'] as Map<String, dynamic>?;
    final rating = show['rating'] as Map<String, dynamic>?;
    final genres = show['genres'] as List<dynamic>? ?? [];

    return Movie(
      id: show['id'] ?? 0,
      title: show['name'] ?? '',
      overview: _stripHtmlTags(show['summary'] ?? ''),
      posterPath: image?['medium'] ?? '',
      backdropPath: image?['original'] ?? '',
      releaseDate: show['premiered'] ?? '',
      voteAverage: (rating?['average'] ?? 0).toDouble(),
      genres: genres.map((g) => g.toString()).toList(),
    );
  }

  static String _stripHtmlTags(String htmlString) {
    return htmlString
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': title,
      'summary': overview,
      'image': {'medium': posterPath, 'original': backdropPath},
      'premiered': releaseDate,
      'rating': {'average': voteAverage},
      'genres': genres,
    };
  }

  String get fullPosterPath => posterPath;
  String get fullBackdropPath => backdropPath;
}
