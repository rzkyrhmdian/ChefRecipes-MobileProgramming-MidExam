import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/auth_service.dart';
import '../services/db_service.dart';
import '../services/favorites_service.dart';
import '../widgets/safe_network_image.dart';
import 'add_recipe_page.dart';
import 'edit_recipe_page.dart';
import 'recipe_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _dbService = DbService();
  final _authService = AuthService();
  final _favoritesService = FavoritesService();

  Future<void> _openAddRecipe() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddRecipePage()),
    );
    if (created == true && mounted) setState(() {});
  }

  Future<void> _openEditRecipe(Recipe recipe) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditRecipePage(recipe: recipe)),
    );
    if (updated == true && mounted) setState(() {});
  }

  Future<void> _openDetailRecipe(Recipe recipe) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: recipe)),
    );
    if (changed == true && mounted) setState(() {});
  }

  Future<void> _deleteRecipe(Recipe recipe) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Recipe'),
          content: Text('Delete "${recipe.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _favoritesService.removeFavoritesByRecipeId(recipe.id);
      await _dbService.deleteRecipe(recipe.id);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chef Recipes Home'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/favorite'),
            icon: const Icon(Icons.favorite),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddRecipe,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_pin, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Login as: ${user?.email ?? '-'}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'All Recipes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<Recipe>>(
                stream: _dbService.getAllRecipes(),
                builder: (context, snapshot) {
                  if (user == null) {
                    return const Center(child: Text('Please login first.'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Failed to load recipes: ${snapshot.error}'),
                    );
                  }

                  final recipes = snapshot.data ?? [];
                  if (recipes.isEmpty) {
                    return const Center(
                      child: Text('No recipes yet. Tap + to create one.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      final isOwner = recipe.userId == user.uid;
                      return Card(
                        child: ListTile(
                          onTap: () => _openDetailRecipe(recipe),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          leading: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                              ? SafeNetworkImage(
                                  imageUrl: recipe.imageUrl!,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                  borderRadius: BorderRadius.circular(6),
                                )
                              : const Icon(Icons.restaurant_menu),
                          title: Text(recipe.title),
                          subtitle: Text(
                            '${recipe.category} • ${recipe.createdAt.toLocal()}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              StreamBuilder<bool>(
                                stream: _favoritesService.isRecipeFavorited(
                                  userId: user.uid,
                                  recipeId: recipe.id,
                                ),
                                builder: (context, favSnapshot) {
                                  final isFav = favSnapshot.data ?? false;
                                  return IconButton(
                                    onPressed: () async {
                                      await _favoritesService.toggleFavorite(
                                        userId: user.uid,
                                        recipeId: recipe.id,
                                      );
                                    },
                                    icon: Icon(
                                      isFav ? Icons.favorite : Icons.favorite_border,
                                      color: isFav ? Colors.red : null,
                                    ),
                                  );
                                },
                              ),
                              if (isOwner) ...[
                                IconButton(
                                  onPressed: () => _openEditRecipe(recipe),
                                  icon: const Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () => _deleteRecipe(recipe),
                                  icon: const Icon(Icons.delete),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
