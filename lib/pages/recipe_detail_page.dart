import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/auth_service.dart';
import '../services/db_service.dart';
import '../services/favorites_service.dart';
import '../widgets/safe_network_image.dart';
import 'edit_recipe_page.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailPage({
    super.key,
    required this.recipe,
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  final _dbService = DbService();
  final _authService = AuthService();
  final _favoritesService = FavoritesService();
  late Recipe _recipe;

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
  }

  Future<void> _openEditPage() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditRecipePage(recipe: _recipe),
      ),
    );

    if (changed == true) {
      final updatedRecipe = await _dbService.getRecipeById(_recipe.id);
      if (updatedRecipe != null && mounted) {
        setState(() => _recipe = updatedRecipe);
      }
    }
  }

  Future<void> _deleteRecipe() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Recipe'),
          content: const Text('Are you sure you want to delete this recipe?'),
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
      await _favoritesService.removeFavoritesByRecipeId(_recipe.id);
      await _dbService.deleteRecipe(_recipe.id);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Detail'),
        actions: [
          if (userId != null)
            StreamBuilder<bool>(
              stream: _favoritesService.isRecipeFavorited(
                userId: userId,
                recipeId: _recipe.id,
              ),
              builder: (context, snapshot) {
                final isFav = snapshot.data ?? false;
                return IconButton(
                  onPressed: () async {
                    await _favoritesService.toggleFavorite(
                      userId: userId,
                      recipeId: _recipe.id,
                    );
                  },
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : null,
                  ),
                );
              },
            ),
          IconButton(
            onPressed: _openEditPage,
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: _deleteRecipe,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_recipe.imageUrl != null && _recipe.imageUrl!.isNotEmpty) ...[
              SafeNetworkImage(
                imageUrl: _recipe.imageUrl!,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              _recipe.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Chip(label: Text(_recipe.category)),
            const SizedBox(height: 8),
            Text('Created: ${_recipe.createdAt.toLocal()}'),
            const SizedBox(height: 20),
            const Text(
              'Ingredients',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(_recipe.ingredients),
            const SizedBox(height: 20),
            const Text(
              'Steps',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(_recipe.steps),
          ],
        ),
      ),
    );
  }
}
