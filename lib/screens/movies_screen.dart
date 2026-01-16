import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/movie_provider.dart';
import '../models/movie.dart';
import '../screens/movie_detail_screen.dart';
import '../services/notification_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_widget.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFeaturedIndex = 0;
  bool _isAutoSliding = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().loadMovies();
      _startAutoSlide();
    });
  }

  void _startAutoSlide() {
    Future.doWhile(() async {
      if (!mounted || !_isAutoSliding) return false;
      
      // Wait 3 seconds before switching
      await Future.delayed(const Duration(seconds: 3));
      
      if (mounted && _isAutoSliding) {
        final provider = context.read<MovieProvider>();
        if (provider.movies.isNotEmpty) {
          setState(() {
            _selectedFeaturedIndex = (_selectedFeaturedIndex + 1) % 5.clamp(0, provider.movies.length);
          });
        }
      }
      return mounted && _isAutoSliding;
    });
  }

  void _selectFeatured(int index) {
    setState(() {
      _selectedFeaturedIndex = index;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _isAutoSliding = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MovieProvider>(
        builder: (context, provider, _) {
          if (provider.state == LoadingState.loading && provider.movies.isEmpty) {
            return const LoadingWidget();
          }

          if (provider.state == LoadingState.error) {
            return AppErrorWidget(
              message: provider.errorMessage,
              onRetry: () => provider.loadMovies(),
            );
          }

          if (provider.movies.isEmpty) {
            return EmptyWidget(
              message: provider.isSearching
                  ? 'No shows found for "${provider.searchQuery}"'
                  : 'No shows available',
              icon: Icons.movie_outlined,
            );
          }

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search shows...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: provider.isSearching
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              provider.clearSearch();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFF16213E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => provider.searchMovies(value),
                ),
              ),

              // Main Content
              Expanded(
                child: provider.isSearching
                    ? _buildSearchResults(provider.movies)
                    : _buildMainContent(provider.movies),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainContent(List<Movie> movies) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;
        final isTablet = constraints.maxWidth > 600 && constraints.maxWidth <= 900;

        if (isDesktop) {
          return _buildDesktopLayout(movies);
        } else {
          return _buildMobileLayout(movies, isTablet);
        }
      },
    );
  }

  // Desktop Layout
  Widget _buildDesktopLayout(List<Movie> movies) {
    final featuredMovies = movies.take(5).toList();
    final selectedMovie = featuredMovies.isNotEmpty 
        ? featuredMovies[_selectedFeaturedIndex] 
        : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - Featured Hero
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedMovie != null) _buildFeaturedHero(selectedMovie),
                const SizedBox(height: 16),
                // Featured selector thumbnails
                if (featuredMovies.isNotEmpty) _buildFeaturedSelector(featuredMovies),
                const SizedBox(height: 30),
                _buildHorizontalSection('Trending Now', movies.skip(5).take(10).toList()),
              ],
            ),
          ),
        ),
        // Right side - Cards Grid
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.only(top: 20, bottom: 20, right: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Popular Shows',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: movies.skip(10).take(10).length,
                    itemBuilder: (context, index) {
                      return _buildMovieCard(movies.skip(10).toList()[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Mobile/Tablet Layout
  Widget _buildMobileLayout(List<Movie> movies, bool isTablet) {
    final featuredMovies = movies.take(5).toList();
    final selectedMovie = featuredMovies.isNotEmpty 
        ? featuredMovies[_selectedFeaturedIndex] 
        : null;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedMovie != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildFeaturedHero(selectedMovie),
            ),
          const SizedBox(height: 12),
          if (featuredMovies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildFeaturedSelector(featuredMovies),
            ),
          const SizedBox(height: 24),
          _buildHorizontalSection('Popular Shows', movies.skip(0).take(10).toList()),
          _buildHorizontalSection('Trending Now', movies.skip(5).take(10).toList()),
          _buildHorizontalSection('New Releases', movies.skip(10).take(10).toList()),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Featured Hero Card
  Widget _buildFeaturedHero(Movie movie) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
      ),
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade900,
              Colors.deepPurple.shade700,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withAlpha(100),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CustomPaint(
                  painter: _PatternPainter(),
                ),
              ),
            ),
            // Content
            Row(
              children: [
                // Poster
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: movie.fullPosterPath.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: movie.fullPosterPath,
                            width: 140,
                            height: 210,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              width: 140,
                              height: 210,
                              color: Colors.grey.shade800,
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              width: 140,
                              height: 210,
                              color: Colors.grey.shade800,
                              child: const Icon(Icons.movie, size: 50, color: Colors.grey),
                            ),
                          )
                        : Container(
                            width: 140,
                            height: 210,
                            color: Colors.grey.shade800,
                            child: const Icon(Icons.movie, size: 50, color: Colors.grey),
                          ),
                  ),
                ),
                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 30, 20, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '⭐ FEATURED',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          movie.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        if (movie.genres.isNotEmpty)
                          Text(
                            movie.genres.take(3).join(' • '),
                            style: TextStyle(
                              color: Colors.grey.shade300,
                              fontSize: 12,
                            ),
                          ),
                        const Spacer(),
                        if (movie.voteAverage > 0)
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                movie.voteAverage.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                ' / 10',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                              ),
                            ],
                          ),
                        const SizedBox(height: 12),
                        Builder(
                          builder: (buttonContext) {
                            return ElevatedButton.icon(
                              onPressed: () async {
                                final messenger = ScaffoldMessenger.of(buttonContext);
                                await NotificationService.showMoviePlayingNotification(movie.title);
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Movie is Playing'),
                                    backgroundColor: Colors.deepPurple,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.play_arrow, size: 20),
                              label: const Text('Play Now'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.deepPurple,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Featured Selector Thumbnails
  Widget _buildFeaturedSelector(List<Movie> movies) {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedFeaturedIndex;
          return GestureDetector(
            onTap: () => _selectFeatured(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? Colors.deepPurpleAccent : Colors.transparent,
                  width: 3,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    movies[index].fullPosterPath.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: movies[index].fullPosterPath,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: const Color(0xFF16213E)),
                            errorWidget: (_, __, ___) => Container(
                              color: const Color(0xFF16213E),
                              child: const Icon(Icons.movie, color: Colors.grey),
                            ),
                          )
                        : Container(
                            color: const Color(0xFF16213E),
                            child: const Icon(Icons.movie, color: Colors.grey),
                          ),
                    if (!isSelected)
                      Container(color: Colors.black.withAlpha(100)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Horizontal Section
  Widget _buildHorizontalSection(String title, List<Movie> movies) {
    if (movies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: movies.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _buildMovieCard(movies[index]),
            ),
          ),
        ),
      ],
    );
  }

  // Movie Card
  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
      ),
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              movie.fullPosterPath.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: movie.fullPosterPath,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: const Color(0xFF16213E),
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: const Color(0xFF16213E),
                        child: const Icon(Icons.movie, color: Colors.grey),
                      ),
                    )
                  : Container(
                      color: const Color(0xFF16213E),
                      child: const Icon(Icons.movie, color: Colors.grey),
                    ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withAlpha(220), Colors.transparent],
                    ),
                  ),
                  child: Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              if (movie.voteAverage > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(180),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 10),
                        const SizedBox(width: 2),
                        Text(
                          movie.voteAverage.toStringAsFixed(1),
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Search Results
  Widget _buildSearchResults(List<Movie> movies) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 150,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) => _buildMovieCard(movies[index]),
    );
  }
}

// Pattern Painter for hero background
class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(10)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 20; i++) {
      canvas.drawCircle(
        Offset(size.width * (i * 0.15), size.height * 0.3),
        30 + (i * 5).toDouble(),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
