import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_lists_provider.dart';
import '../widgets/movie_list_tile.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_widget.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favourites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<UserListsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget();
          }

          if (provider.favorites.isEmpty) {
            return const EmptyWidget(
              message: 'No favourite movies yet.\nAdd some from the Movies tab!',
              icon: Icons.favorite_outline,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.favorites.length,
            itemBuilder: (context, index) {
              return MovieListTile(
                movie: provider.favorites[index],
                showRemoveButton: true,
                onRemove: () =>
                    provider.toggleFavorite(provider.favorites[index]),
              );
            },
          );
        },
      ),
    );
  }
}
