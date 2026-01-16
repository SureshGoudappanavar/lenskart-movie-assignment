import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_lists_provider.dart';
import '../widgets/movie_list_tile.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_widget.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Watchlist',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<UserListsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget();
          }

          if (provider.watchlist.isEmpty) {
            return const EmptyWidget(
              message: 'Your watchlist is empty.\nAdd movies to watch later!',
              icon: Icons.bookmark_outline,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.watchlist.length,
            itemBuilder: (context, index) {
              return MovieListTile(
                movie: provider.watchlist[index],
                showRemoveButton: true,
                onRemove: () =>
                    provider.toggleWatchlist(provider.watchlist[index]),
              );
            },
          );
        },
      ),
    );
  }
}
