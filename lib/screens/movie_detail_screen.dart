import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../providers/user_lists_provider.dart';
import '../services/notification_service.dart';

class MovieDetailScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: size.height * 0.4,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  movie.fullBackdropPath.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: movie.fullBackdropPath,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: const Color(0xFF16213E),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: const Color(0xFF16213E),
                            child: const Icon(Icons.movie, size: 80, color: Colors.grey),
                          ),
                        )
                      : Container(
                          color: const Color(0xFF16213E),
                          child: const Icon(Icons.movie, size: 80, color: Colors.grey),
                        ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF1A1A2E).withAlpha(204),
                          const Color(0xFF1A1A2E),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRatingSection(),
                  const SizedBox(height: 20),
                  _buildInfoRow(),
                  const SizedBox(height: 20),
                  _buildGenreChips(),
                  const SizedBox(height: 20),
                  _buildOverviewSection(),
                  const SizedBox(height: 24),
                  _buildActionButtons(context),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    if (movie.voteAverage <= 0) {
      return Row(
        children: [
          Icon(Icons.star_border, color: Colors.grey[400], size: 30),
          const SizedBox(width: 12),
          Text(
            'No rating available',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      );
    }

    final percent = movie.voteAverage / 10;
    final color = percent >= 0.7
        ? Colors.green
        : percent >= 0.5
            ? Colors.orange
            : Colors.red;

    return Row(
      children: [
        CircularPercentIndicator(
          radius: 35,
          lineWidth: 6,
          percent: percent.clamp(0.0, 1.0),
          center: Text(
            '${(movie.voteAverage * 10).toInt()}%',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          progressColor: color,
          backgroundColor: color.withAlpha(51),
          circularStrokeCap: CircularStrokeCap.round,
        ),
        const SizedBox(width: 16),
        const Text(
          'User\nScore',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          movie.releaseDate.isNotEmpty ? movie.releaseDate : 'Unknown',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildGenreChips() {
    if (movie.genres.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Genres',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: movie.genres.map((genre) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withAlpha(77),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.deepPurpleAccent),
              ),
              child: Text(
                genre,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          movie.overview.isNotEmpty
              ? movie.overview
              : 'No overview available.',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[300],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Consumer<UserListsProvider>(
      builder: (context, provider, _) {
        final isFav = provider.isFavorite(movie.id);
        final inWatchlist = provider.isInWatchlist(movie.id);

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: isFav ? Icons.favorite : Icons.favorite_outline,
                    label: isFav ? 'Favourited' : 'Add to Favourites',
                    color: isFav ? Colors.red : Colors.grey,
                    onTap: () => provider.toggleFavorite(movie),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: inWatchlist ? Icons.bookmark : Icons.bookmark_outline,
                    label: inWatchlist ? 'In Watchlist' : 'Add to Watchlist',
                    color: inWatchlist ? Colors.amber : Colors.grey,
                    onTap: () => provider.toggleWatchlist(movie),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await NotificationService.showMoviePlayingNotification(
                      movie.title);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Movie is Playing'),
                        backgroundColor: Colors.deepPurple,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 28),
                label: const Text(
                  'Play Now',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
