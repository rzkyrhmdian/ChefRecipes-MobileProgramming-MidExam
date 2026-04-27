import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/recipe.dart';

class FavoritesService {
  FavoritesService();

  final CollectionReference<Map<String, dynamic>> _favoritesRef =
      FirebaseFirestore.instance.collection('favorites');
  final CollectionReference<Map<String, dynamic>> _recipesRef =
      FirebaseFirestore.instance.collection('recipes');

  Stream<List<String>> getFavoriteRecipeIdsByUserId(String userId) {
    return _favoritesRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => doc.data()['recipeId'] as String?)
              .whereType<String>()
              .toList(),
        );
  }

  Stream<bool> isRecipeFavorited({
    required String userId,
    required String recipeId,
  }) {
    return _favoritesRef
        .where('userId', isEqualTo: userId)
        .where('recipeId', isEqualTo: recipeId)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  Future<bool> toggleFavorite({
    required String userId,
    required String recipeId,
  }) async {
    final existing = await _favoritesRef
        .where('userId', isEqualTo: userId)
        .where('recipeId', isEqualTo: recipeId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      await existing.docs.first.reference.delete();
      return false;
    }

    await _favoritesRef.add({
      'userId': userId,
      'recipeId': recipeId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return true;
  }

  Future<void> removeFavoritesByRecipeId(String recipeId) async {
    final snapshot = await _favoritesRef
        .where('recipeId', isEqualTo: recipeId)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Stream<List<Recipe>> getFavoriteRecipesByUserId(String userId) async* {
    await for (final favoriteSnapshot in _favoritesRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()) {
      final recipeIds = favoriteSnapshot.docs
          .map((doc) => doc.data()['recipeId'] as String?)
          .whereType<String>()
          .toList();

      if (recipeIds.isEmpty) {
        yield [];
        continue;
      }

      final idOrder = <String, int>{};
      for (var i = 0; i < recipeIds.length; i++) {
        idOrder[recipeIds[i]] = i;
      }

      final recipes = <Recipe>[];
      for (var i = 0; i < recipeIds.length; i += 10) {
        final chunk = recipeIds.sublist(
          i,
          i + 10 > recipeIds.length ? recipeIds.length : i + 10,
        );

        final recipeSnapshot = await _recipesRef
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        recipes.addAll(recipeSnapshot.docs.map(Recipe.fromFirestore));
      }

      recipes.sort(
        (a, b) => (idOrder[a.id] ?? 999999).compareTo(idOrder[b.id] ?? 999999),
      );
      yield recipes;
    }
  }
}
