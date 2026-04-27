import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String id;
  final String title;
  final String category;
  final String ingredients;
  final String steps;
  final String? imageUrl;
  final String userId;
  final DateTime createdAt;

  Recipe({
    required this.id,
    required this.title,
    required this.category,
    required this.ingredients,
    required this.steps,
    this.imageUrl,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'category': category,
      'ingredients': ingredients,
      'steps': steps,
      'imageUrl': imageUrl,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Recipe.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? <String, dynamic>{};
    final createdAtRaw = map['createdAt'];
    DateTime createdAt = DateTime.now();

    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    }

    return Recipe(
      id: doc.id,
      title: map['title'] as String? ?? '',
      category: map['category'] as String? ?? 'Main Course',
      ingredients: map['ingredients'] as String? ?? '',
      steps: map['steps'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      userId: map['userId'] as String? ?? '',
      createdAt: createdAt,
    );
  }

  Recipe copyWith({
    String? id,
    String? title,
    String? category,
    String? ingredients,
    String? steps,
    String? imageUrl,
    String? userId,
    DateTime? createdAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
