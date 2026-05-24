import 'package:cloud_firestore/cloud_firestore.dart';

class MealPlanItem {
  final String id;
  final String title;
  final String time;
  final String image;
  final int calories;
  final int carbs;
  final int protein;
  final int fat;
  final String description;
  final List<String> ingredients;
  final List<String> steps;

  const MealPlanItem({
    required this.id,
    required this.title,
    required this.time,
    required this.image,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.description,
    required this.ingredients,
    required this.steps,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'image': image,
      'calories': calories,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
    };
  }

  factory MealPlanItem.fromMap(Map<String, dynamic> map) {
    return MealPlanItem(
      id: map['id'] as String,
      title: map['title'] as String,
      time: map['time'] as String,
      image: map['image'] as String,
      calories: (map['calories'] as num).round(),
      carbs: (map['carbs'] as num).round(),
      protein: (map['protein'] as num).round(),
      fat: (map['fat'] as num).round(),
      description: map['description'] as String,
      ingredients: ((map['ingredients'] as List?) ?? const []).cast<String>(),
      steps: ((map['steps'] as List?) ?? const []).cast<String>(),
    );
  }
}

class DailyMealPlan {
  final String id;
  final List<MealPlanItem> meals;
  final int caloriesTarget;
  final DateTime? updatedAt;

  const DailyMealPlan({
    required this.id,
    required this.meals,
    required this.caloriesTarget,
    this.updatedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'meals': meals.map((meal) => meal.toMap()).toList(),
      'caloriesTarget': caloriesTarget,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory DailyMealPlan.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    final updatedAtValue = data['updatedAt'];
    return DailyMealPlan(
      id: snapshot.id,
      meals: ((data['meals'] as List?) ?? const [])
          .map((item) =>
              MealPlanItem.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList(),
      caloriesTarget: (data['caloriesTarget'] as num?)?.round() ?? 1800,
      updatedAt: updatedAtValue is Timestamp ? updatedAtValue.toDate() : null,
    );
  }
}
