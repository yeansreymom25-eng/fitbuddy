import '../models/user_profile.dart';

class FoodAiResult {
  final String title;
  final String summary;
  final String time;
  final String difficulty;
  final List<String> steps;
  final List<String> healthNotes;
  final Map<String, double> split;
  final String ingredientSummary;

  const FoodAiResult({
    required this.title,
    required this.summary,
    required this.time,
    required this.difficulty,
    required this.steps,
    required this.healthNotes,
    required this.split,
    required this.ingredientSummary,
  });
}

class FoodAiService {
  const FoodAiService._();

  static FoodAiResult analyze({
    required List<String> ingredients,
    required AppUserProfile? profile,
  }) {
    final clean = ingredients
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    final items = clean.map((item) => item.toLowerCase()).toList();
    final ingredientSummary =
        clean.isEmpty ? 'your ingredients' : clean.take(8).join(', ');
    final country = (profile?.country ?? 'Cambodia').toLowerCase();
    final goal = (profile?.healthGoal ?? 'Eat Healthier').toLowerCase();
    final protein = _firstMatch(items, _proteins) ?? _fallbackProtein(items);
    final vegetables = _matches(items, _vegetables);
    final carbs = _matches(items, _carbs);
    final mainVegetable = vegetables.isEmpty ? 'vegetables' : vegetables.first;
    final mainCarb = carbs.isEmpty ? 'rice' : carbs.first;
    final style = _countryStyle(country);
    final loseWeight = goal == 'lose weight';
    final buildMuscle = goal == 'build muscle';
    final title = _titleForGoal(
      goal: goal,
      country: country,
      protein: protein,
      carb: mainCarb,
      vegetable: mainVegetable,
    );

    return FoodAiResult(
      title: title,
      summary:
          'I checked $ingredientSummary. This idea matches ${profile?.healthGoal ?? 'your goal'} and ${profile?.country ?? 'your country'} food style.',
      time: clean.length > 5 ? '25 min' : '15 min',
      difficulty: 'Easy',
      steps: [
        'Wash and cut all ingredients into small bite-size pieces.',
        'Cook $protein first in a pan with a little oil, garlic, or onion.',
        if (vegetables.isNotEmpty)
          'Add ${vegetables.join(', ')} and stir for 3 to 5 minutes.'
        else
          'Add any vegetables you have and stir for 3 to 5 minutes.',
        if (style.isNotEmpty) style,
        if (loseWeight)
          'Use a small portion of $mainCarb and add more vegetables.'
        else if (buildMuscle)
          'Add a bigger portion of $protein for more protein.'
        else
          'Serve with a normal portion of $mainCarb.',
        'Taste it, keep the seasoning light, then serve warm.',
      ],
      healthNotes: _healthNotes(clean, items, goal),
      split: {
        'Protein': buildMuscle ? .42 : .32,
        'Vegetables': loseWeight ? .48 : .38,
        'Carbs': loseWeight ? .20 : .30,
      },
      ingredientSummary: ingredientSummary,
    );
  }

  static List<String> _healthNotes(
    List<String> clean,
    List<String> items,
    String goal,
  ) {
    if (clean.isEmpty) {
      return const [
        'Add at least one protein, one vegetable, and one carb for a balanced meal.',
      ];
    }
    return [
      for (var i = 0; i < clean.length; i++)
        '${clean[i]}: ${_noteFor(items[i], goal)}',
    ];
  }

  static String _noteFor(String item, String goal) {
    if (_containsAny(item, _proteins)) {
      return goal == 'build muscle'
          ? 'good protein for muscle recovery.'
          : 'helps you feel full for longer.';
    }
    if (_containsAny(item, _vegetables)) {
      return 'adds fiber, vitamins, and makes the plate healthier.';
    }
    if (_containsAny(item, _carbs)) {
      return goal == 'lose weight'
          ? 'good energy, but keep the portion small.'
          : 'gives energy for your day and exercise.';
    }
    if (item.contains('burger') || item.contains('fries')) {
      return 'high calorie food, so eat small portion and add vegetables.';
    }
    if (item.contains('banana') || item.contains('apple')) {
      return 'good fruit for quick energy and vitamins.';
    }
    return 'can be used, but balance it with protein and vegetables.';
  }

  static String _fallbackProtein(List<String> items) {
    if (items.any((item) => item.contains('meat'))) {
      return 'meat';
    }
    return 'egg or tofu';
  }

  static String _titleForGoal({
    required String goal,
    required String country,
    required String protein,
    required String carb,
    required String vegetable,
  }) {
    if (country.contains('cambodia') || country.contains('khmer')) {
      if (goal == 'lose weight') {
        return 'Light Khmer $protein With $vegetable';
      }
      if (goal == 'build muscle') {
        return 'High Protein Khmer $protein Rice Bowl';
      }
      return 'Healthy Khmer $protein and $carb';
    }
    if (goal == 'lose weight') {
      return 'Light $protein and $vegetable Plate';
    }
    if (goal == 'build muscle') {
      return 'High Protein $protein Bowl';
    }
    return 'Balanced $protein and $carb Meal';
  }

  static String _countryStyle(String country) {
    if (country.contains('cambodia') || country.contains('khmer')) {
      return 'For Khmer taste, add a little fish sauce, lime, garlic, and herbs if you have them.';
    }
    if (country.contains('thai')) {
      return 'For Thai taste, add lime, garlic, chili, and a little fish sauce.';
    }
    if (country.contains('korea')) {
      return 'For Korean taste, add a small spoon of gochujang or sesame oil if you have it.';
    }
    if (country.contains('japan')) {
      return 'For Japanese taste, add a little soy sauce and sesame if you have them.';
    }
    return '';
  }

  static List<String> _matches(List<String> items, List<String> options) {
    return [
      for (final option in options)
        if (items.any((item) => item.contains(option))) option,
    ];
  }

  static String? _firstMatch(List<String> items, List<String> options) {
    for (final option in options) {
      if (items.any((item) => item.contains(option))) {
        return option;
      }
    }
    return null;
  }

  static bool _containsAny(String item, List<String> options) {
    return options.any((option) => item.contains(option));
  }
}

const _proteins = [
  'chicken',
  'egg',
  'tofu',
  'fish',
  'salmon',
  'tuna',
  'beef',
  'pork',
  'meat',
  'turkey',
  'yogurt',
  'bean',
];

const _vegetables = [
  'broccoli',
  'spinach',
  'tomato',
  'carrot',
  'cucumber',
  'lettuce',
  'salad',
  'pepper',
  'mushroom',
  'cabbage',
  'morning glory',
];

const _carbs = [
  'rice',
  'potato',
  'oat',
  'bread',
  'pasta',
  'quinoa',
  'corn',
  'noodle',
  'banana',
];
