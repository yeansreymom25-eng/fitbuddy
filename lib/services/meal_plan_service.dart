import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/meal_plan.dart';
import '../models/user_profile.dart';
import 'date_key.dart';
import 'user_profile_service.dart';

class MealPlanService {
  MealPlanService._();

  static final MealPlanService instance = MealPlanService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No signed-in user.');
    }
    return user.uid;
  }

  DocumentReference<Map<String, dynamic>> _doc([String? key]) {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('mealPlans')
        .doc(key ?? dateKey());
  }

  Stream<DailyMealPlan> watchPlanForDate(DateTime date) async* {
    final key = dateKey(date);
    final plan = await ensurePlanForDate(date);
    yield plan;
    yield* _doc(key).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return plan;
      }
      return DailyMealPlan.fromFirestore(snapshot);
    });
  }

  Stream<DailyMealPlan> watchToday() => watchPlanForDate(DateTime.now());

  Future<DailyMealPlan> ensureTodayPlan() => ensurePlanForDate(DateTime.now());

  Future<DailyMealPlan> ensurePlanForDate(DateTime date) async {
    final key = dateKey(date);
    final doc = _doc(key);
    final snapshot = await doc.get();

    if (snapshot.exists) {
      final existing = DailyMealPlan.fromFirestore(snapshot);
      if (existing.meals.isNotEmpty) {
        return existing;
      }
    }

    final profile = await UserProfileService.instance.getCurrentProfile();
    final generated = _generatePlan(key, date, profile);
    await doc.set(generated.toFirestore(), SetOptions(merge: true));
    return generated;
  }

  DailyMealPlan _generatePlan(
    String key,
    DateTime date,
    AppUserProfile? profile,
  ) {
    final rec = profile?.recommendations ?? UserRecommendations.fromMap(null);
    final goal = (profile?.healthGoal ?? 'Stay Active').toLowerCase();
    final country = (profile?.country ?? 'Cambodia').toLowerCase();
    final daySeed = date.difference(DateTime(2024, 1, 1)).inDays;

    final templates = country.contains('cambodia') || country.contains('khmer')
        ? _khmerTemplates
        : _templates;

    final template =
        templates[(daySeed + _goalOffset(goal)) % templates.length];

    final calorieScale = rec.dailyCalories / 1800;

    MealPlanItem mealFrom(Map<String, dynamic> map, double ratio) {
      final baseCalories = (rec.dailyCalories * ratio).round();

      return MealPlanItem(
        id: map['id'] as String,
        title: _goalTitle(goal, map['title'] as String),
        time: map['time'] as String,
        image: map['image'] as String,
        calories: baseCalories,
        carbs: ((baseCalories * 0.45) / 4).round(),
        protein: ((baseCalories * (goal == 'build muscle' ? 0.32 : 0.25)) / 4)
            .round(),
        fat: ((baseCalories * 0.28) / 9).round(),
        description: _goalDescription(goal, map['description'] as String),
        ingredients: (map['ingredients'] as List<String>),
        steps: (map['steps'] as List<String>),
      );
    }

    final meals = [
      mealFrom(template[0], 0.24),
      mealFrom(template[1], 0.34),
      mealFrom(template[2], 0.12),
      mealFrom(template[3], 0.30),
    ];

    return DailyMealPlan(
      id: key,
      meals: meals,
      caloriesTarget: (1800 * calorieScale).round(),
    );
  }

  int _goalOffset(String goal) {
    if (goal == 'lose weight') {
      return 0;
    }
    if (goal == 'build muscle') {
      return 1;
    }
    if (goal == 'sleep better') {
      return 2;
    }
    return 3;
  }

  String _goalTitle(String goal, String title) {
    if (goal == 'lose weight') {
      return 'Light $title';
    }
    if (goal == 'build muscle') {
      return 'Protein $title';
    }
    if (goal == 'sleep better') {
      return 'Calm $title';
    }
    return title;
  }

  String _goalDescription(String goal, String description) {
    if (goal == 'lose weight') {
      return '$description. Smaller carb portion and more vegetables.';
    }
    if (goal == 'build muscle') {
      return '$description. Higher protein portion for muscle recovery.';
    }
    if (goal == 'sleep better') {
      return '$description. Lighter seasoning to support better sleep.';
    }
    return description;
  }
}

const _templates = [
  [
    {
      'id': 'breakfast',
      'title': 'Greek Yogurt Oat Bowl',
      'time': '7:00 AM',
      'image': 'assets/images/dashboard/breakfast.png',
      'description': 'Greek yogurt, oats, banana, berries, chia, and almonds',
      'ingredients': [
        'Greek yogurt',
        'Rolled oats',
        'Banana',
        'Berries',
        'Chia seeds'
      ],
      'steps': [
        'Mix yogurt and oats.',
        'Slice banana and rinse berries.',
        'Top with chia and almonds.',
        'Rest 5 minutes before eating.'
      ],
    },
    {
      'id': 'lunch',
      'title': 'Chicken Brown Rice Plate',
      'time': '12:00 PM',
      'image': 'assets/images/dashboard/lunch.png',
      'description':
          'Grilled chicken with brown rice, broccoli, carrots, and lemon',
      'ingredients': [
        'Chicken breast',
        'Brown rice',
        'Broccoli',
        'Carrots',
        'Lemon'
      ],
      'steps': [
        'Cook brown rice.',
        'Season and grill chicken.',
        'Steam vegetables until tender.',
        'Serve with lemon juice.'
      ],
    },
    {
      'id': 'snack',
      'title': 'Apple Peanut Snack',
      'time': '4:00 PM',
      'image': 'assets/images/dashboard/snack.png',
      'description': 'Apple slices with peanut butter and cinnamon',
      'ingredients': ['Apple', 'Peanut butter', 'Cinnamon'],
      'steps': [
        'Slice the apple.',
        'Spread peanut butter thinly.',
        'Sprinkle cinnamon.',
        'Serve immediately.'
      ],
    },
    {
      'id': 'dinner',
      'title': 'Salmon Sweet Potato',
      'time': '6:30 PM',
      'image': 'assets/images/dashboard/dinner.png',
      'description': 'Baked salmon with sweet potato and green beans',
      'ingredients': [
        'Salmon',
        'Sweet potato',
        'Green beans',
        'Olive oil',
        'Garlic'
      ],
      'steps': [
        'Bake sweet potato wedges.',
        'Season salmon with garlic.',
        'Bake salmon until flaky.',
        'Serve with steamed beans.'
      ],
    },
  ],
  [
    {
      'id': 'breakfast',
      'title': 'Egg Avocado Toast',
      'time': '7:00 AM',
      'image': 'assets/images/dashboard/breakfast.png',
      'description': 'Whole grain toast with eggs, avocado, tomato, and greens',
      'ingredients': [
        'Whole grain bread',
        'Eggs',
        'Avocado',
        'Tomato',
        'Spinach'
      ],
      'steps': [
        'Toast bread.',
        'Cook eggs to preference.',
        'Mash avocado with pepper.',
        'Layer toast and serve with spinach.'
      ],
    },
    {
      'id': 'lunch',
      'title': 'Turkey Quinoa Bowl',
      'time': '12:00 PM',
      'image': 'assets/images/dashboard/lunch.png',
      'description': 'Lean turkey, quinoa, cucumber, corn, and yogurt sauce',
      'ingredients': [
        'Lean turkey',
        'Quinoa',
        'Cucumber',
        'Corn',
        'Plain yogurt'
      ],
      'steps': [
        'Cook quinoa.',
        'Brown turkey with light seasoning.',
        'Chop vegetables.',
        'Top with yogurt sauce.'
      ],
    },
    {
      'id': 'snack',
      'title': 'Cottage Cheese Berries',
      'time': '4:00 PM',
      'image': 'assets/images/dashboard/snack.png',
      'description': 'Cottage cheese with berries and pumpkin seeds',
      'ingredients': ['Cottage cheese', 'Berries', 'Pumpkin seeds'],
      'steps': [
        'Spoon cottage cheese into a bowl.',
        'Add berries.',
        'Sprinkle seeds.',
        'Serve chilled.'
      ],
    },
    {
      'id': 'dinner',
      'title': 'Tofu Veggie Stir Fry',
      'time': '6:30 PM',
      'image': 'assets/images/dashboard/dinner.png',
      'description': 'Tofu with mixed vegetables and a small rice portion',
      'ingredients': [
        'Firm tofu',
        'Mixed vegetables',
        'Rice',
        'Soy sauce',
        'Ginger'
      ],
      'steps': [
        'Press and cube tofu.',
        'Stir fry tofu until golden.',
        'Add vegetables and ginger.',
        'Serve with rice.'
      ],
    },
  ],
  [
    {
      'id': 'breakfast',
      'title': 'Protein Smoothie Bowl',
      'time': '7:00 AM',
      'image': 'assets/images/dashboard/breakfast.png',
      'description': 'Milk, banana, spinach, oats, and protein-rich yogurt',
      'ingredients': ['Milk', 'Banana', 'Spinach', 'Oats', 'Greek yogurt'],
      'steps': [
        'Blend milk, banana, spinach, and yogurt.',
        'Pour into a bowl.',
        'Top with oats.',
        'Eat cold.'
      ],
    },
    {
      'id': 'lunch',
      'title': 'Tuna Pasta Salad',
      'time': '12:00 PM',
      'image': 'assets/images/dashboard/lunch.png',
      'description': 'Tuna, whole wheat pasta, cucumber, tomato, and olive oil',
      'ingredients': [
        'Tuna',
        'Whole wheat pasta',
        'Cucumber',
        'Tomato',
        'Olive oil'
      ],
      'steps': [
        'Cook pasta and cool it.',
        'Flake tuna.',
        'Chop vegetables.',
        'Mix with olive oil.'
      ],
    },
    {
      'id': 'snack',
      'title': 'Hummus Veggie Cup',
      'time': '4:00 PM',
      'image': 'assets/images/dashboard/snack.png',
      'description': 'Hummus with carrots, cucumber, and whole grain crackers',
      'ingredients': ['Hummus', 'Carrots', 'Cucumber', 'Whole grain crackers'],
      'steps': [
        'Slice vegetables.',
        'Spoon hummus into a cup.',
        'Add crackers.',
        'Dip and enjoy.'
      ],
    },
    {
      'id': 'dinner',
      'title': 'Lean Beef Veg Plate',
      'time': '6:30 PM',
      'image': 'assets/images/dashboard/dinner.png',
      'description': 'Lean beef, potatoes, mushroom, and greens',
      'ingredients': ['Lean beef', 'Potatoes', 'Mushrooms', 'Greens', 'Pepper'],
      'steps': [
        'Roast potatoes.',
        'Cook beef strips.',
        'Saute mushrooms and greens.',
        'Plate together.'
      ],
    },
  ],
];

const _khmerTemplates = [
  [
    {
      'id': 'breakfast',
      'title': 'Rice Porridge With Egg',
      'time': '7:00 AM',
      'image': 'assets/images/dashboard/breakfast.png',
      'description': 'Khmer-style borbor with egg, herbs, and light pepper',
      'ingredients': ['Rice', 'Egg', 'Green onion', 'Garlic', 'Pepper'],
      'steps': [
        'Cook rice with extra water until soft.',
        'Stir in egg until cooked.',
        'Add garlic and green onion.',
        'Season lightly and serve warm.'
      ],
    },
    {
      'id': 'lunch',
      'title': 'Chicken Lok Lak Plate',
      'time': '12:00 PM',
      'image': 'assets/images/dashboard/lunch.png',
      'description': 'Chicken lok lak with rice, cucumber, tomato, and lettuce',
      'ingredients': ['Chicken', 'Rice', 'Cucumber', 'Tomato', 'Lettuce'],
      'steps': [
        'Cut chicken into small pieces.',
        'Cook chicken with garlic and light soy sauce.',
        'Prepare cucumber, tomato, and lettuce.',
        'Serve with rice and lime pepper sauce.'
      ],
    },
    {
      'id': 'snack',
      'title': 'Banana Peanut Snack',
      'time': '4:00 PM',
      'image': 'assets/images/dashboard/snack.png',
      'description': 'Banana with peanuts for simple energy',
      'ingredients': ['Banana', 'Peanuts'],
      'steps': [
        'Slice banana.',
        'Add a small spoon of peanuts.',
        'Eat as a light snack.',
        'Drink water with it.'
      ],
    },
    {
      'id': 'dinner',
      'title': 'Fish Sour Soup',
      'time': '6:30 PM',
      'image': 'assets/images/dashboard/dinner.png',
      'description':
          'Khmer fish sour soup with vegetables and small rice portion',
      'ingredients': ['Fish', 'Rice', 'Tomato', 'Morning glory', 'Lime'],
      'steps': [
        'Boil water with garlic.',
        'Add fish and cook until done.',
        'Add vegetables and tomato.',
        'Season with lime and serve with rice.'
      ],
    },
  ],
  [
    {
      'id': 'breakfast',
      'title': 'Grilled Chicken Rice',
      'time': '7:00 AM',
      'image': 'assets/images/dashboard/breakfast.png',
      'description': 'Simple bai sach moan style with cucumber',
      'ingredients': ['Chicken', 'Rice', 'Cucumber', 'Garlic'],
      'steps': [
        'Grill or pan-cook chicken.',
        'Cook rice.',
        'Slice cucumber.',
        'Serve together with light sauce.'
      ],
    },
    {
      'id': 'lunch',
      'title': 'Pork Vegetable Stir Fry',
      'time': '12:00 PM',
      'image': 'assets/images/dashboard/lunch.png',
      'description': 'Lean pork with mixed vegetables and rice',
      'ingredients': ['Pork', 'Rice', 'Cabbage', 'Carrot', 'Garlic'],
      'steps': [
        'Slice pork thinly.',
        'Cook pork with garlic.',
        'Add cabbage and carrot.',
        'Serve with rice.'
      ],
    },
    {
      'id': 'snack',
      'title': 'Fresh Fruit Cup',
      'time': '4:00 PM',
      'image': 'assets/images/dashboard/snack.png',
      'description': 'Local fruit with yogurt if available',
      'ingredients': ['Banana', 'Apple', 'Yogurt'],
      'steps': ['Cut fruit.', 'Add yogurt.', 'Mix gently.', 'Serve cold.'],
    },
    {
      'id': 'dinner',
      'title': 'Chicken Vegetable Soup',
      'time': '6:30 PM',
      'image': 'assets/images/dashboard/dinner.png',
      'description': 'Clear chicken soup with vegetables',
      'ingredients': ['Chicken', 'Cabbage', 'Carrot', 'Mushroom', 'Rice'],
      'steps': [
        'Boil chicken until cooked.',
        'Add vegetables.',
        'Season lightly.',
        'Serve with small rice portion.'
      ],
    },
  ],
  [
    {
      'id': 'breakfast',
      'title': 'Egg Rice Bowl',
      'time': '7:00 AM',
      'image': 'assets/images/dashboard/breakfast.png',
      'description': 'Rice bowl with egg and vegetables',
      'ingredients': ['Egg', 'Rice', 'Spinach', 'Tomato'],
      'steps': [
        'Cook egg.',
        'Warm rice.',
        'Add spinach and tomato.',
        'Serve in one bowl.'
      ],
    },
    {
      'id': 'lunch',
      'title': 'Khmer Beef Salad',
      'time': '12:00 PM',
      'image': 'assets/images/dashboard/lunch.png',
      'description': 'Beef salad with cucumber, tomato, herbs, and lime',
      'ingredients': ['Beef', 'Cucumber', 'Tomato', 'Lime', 'Herbs'],
      'steps': [
        'Cook beef strips.',
        'Cut cucumber and tomato.',
        'Mix with lime and herbs.',
        'Serve with small rice portion if needed.'
      ],
    },
    {
      'id': 'snack',
      'title': 'Boiled Egg Snack',
      'time': '4:00 PM',
      'image': 'assets/images/dashboard/snack.png',
      'description': 'Boiled egg with fruit',
      'ingredients': ['Egg', 'Banana'],
      'steps': [
        'Boil egg for 8 to 10 minutes.',
        'Peel egg.',
        'Eat with banana.',
        'Drink water.'
      ],
    },
    {
      'id': 'dinner',
      'title': 'Tofu Morning Glory',
      'time': '6:30 PM',
      'image': 'assets/images/dashboard/dinner.png',
      'description': 'Tofu with morning glory and rice',
      'ingredients': ['Tofu', 'Morning glory', 'Rice', 'Garlic'],
      'steps': [
        'Cut tofu into cubes.',
        'Cook tofu until golden.',
        'Add morning glory and garlic.',
        'Serve with rice.'
      ],
    },
  ],
];
