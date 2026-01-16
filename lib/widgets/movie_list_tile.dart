import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../screens/movie_detail_screen.dart';

class MovieListTile extends StatelessWidget {
  final Movie movie;
  final bool showRemoveButton;
  final VoidCallback? onRemove;

  const MovieListTile({
    super.key,
    required this.movie,
    this.showRemoveButton = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MovieDetailScreen(movie: movie),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 80,
                  height: 120,
                  child: movie.fullPosterPath.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: movie.fullPosterPath,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: const Color(0xFF1A1A2E),
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: const Color(0xFF1A1A2E),
                            child: const Icon(Icons.movie, color: Colors.grey),
                          ),
                        )
                      : Container(
                          color: const Color(0xFF1A1A2E),
                          child: const Icon(Icons.movie, color: Colors.grey),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (movie.genres.isNotEmpty)
                      Text(
                        movie.genres.take(2).join(', '),
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (movie.voteAverage > 0) ...[
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        if (movie.releaseDate.isNotEmpty) ...[
                          Icon(Icons.calendar_today,
                              color: Colors.grey[400], size: 14),
                          const SizedBox(width: 4),
                          Text(
                            movie.releaseDate.split('-').first,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (showRemoveButton)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.red[300],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
