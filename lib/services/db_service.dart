import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/recipe.dart';

class DbService {
  DbService();

  final CollectionReference<Map<String, dynamic>> _recipesRef =
      FirebaseFirestore.instance.collection('recipes');

  Future<String> createRecipe(Recipe recipe) async {
    final docRef = _recipesRef.doc();
    await docRef.set({
      'title': recipe.title,
      'category': recipe.category,
      'ingredients': recipe.ingredients,
      'steps': recipe.steps,
      'imageUrl': recipe.imageUrl,
      'userId': recipe.userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Stream<List<Recipe>> getRecipesByUserId(String userId) {
    return _recipesRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Recipe.fromFirestore).toList());
  }

  Stream<List<Recipe>> getAllRecipes() {
    return _recipesRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Recipe.fromFirestore).toList());
  }

  Future<Recipe?> getRecipeById(String recipeId) async {
    final doc = await _recipesRef.doc(recipeId).get();
    if (!doc.exists) return null;
    return Recipe.fromFirestore(doc);
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await _recipesRef.doc(recipe.id).update({
      'title': recipe.title,
      'category': recipe.category,
      'ingredients': recipe.ingredients,
      'steps': recipe.steps,
      'imageUrl': recipe.imageUrl,
      'userId': recipe.userId,
    });
  }

  Future<void> deleteRecipe(String recipeId) async {
    await _recipesRef.doc(recipeId).delete();
  }
}
