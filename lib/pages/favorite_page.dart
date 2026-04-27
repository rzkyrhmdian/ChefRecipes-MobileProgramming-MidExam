import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/favorites_service.dart';
import '../widgets/safe_network_image.dart';
import 'recipe_detail_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final _authService = AuthService();
  final _favoritesService = FavoritesService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
        body: user == null
          ? const Center(child: Text('Please login first.'))
          : StreamBuilder(
              stream: _favoritesService.getFavoriteRecipesByUserId(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Failed to load favorites: ${snapshot.error}'),
                  );
                }

                final recipes = snapshot.data ?? [];
                if (recipes.isEmpty) {
                  return const Center(
                    child: Text('No favorites yet. Tap heart on recipes.'),
                  );
                }

                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.favorite, color: Colors.red),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Your favorite recipes',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: recipes.length,
                        itemBuilder: (context, index) {
                          final recipe = recipes[index];
                          return Card(
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RecipeDetailPage(recipe: recipe),
                                  ),
                                );
                              },
                              leading: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                                  ? SafeNetworkImage(
                                      imageUrl: recipe.imageUrl!,
                                      width: 52,
                                      height: 52,
                                      borderRadius: BorderRadius.circular(6),
                                    )
                                  : const Icon(Icons.restaurant_menu),
                              title: Text(recipe.title),
                              subtitle: Text(recipe.category),
                              trailing: IconButton(
                                icon: const Icon(Icons.favorite, color: Colors.red),
                                onPressed: () async {
                                  await _favoritesService.toggleFavorite(
                                    userId: user.uid,
                                    recipeId: recipe.id,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
