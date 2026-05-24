import '../models/user_profile.dart';

class RecommendationCalculator {
  const RecommendationCalculator._();

  static UserRecommendations calculate(AppUserProfile profile) {
    final weight = profile.weightKg <= 0 ? 60.0 : profile.weightKg;
    final height = profile.heightCm <= 0 ? 165.0 : profile.heightCm;
    final age = profile.age <= 0 ? 25 : profile.age;
    final gender = profile.gender.toLowerCase();

    final base = 10 * weight + 6.25 * height - 5 * age;
    final bmr = gender == 'male' ? base + 5 : base - 161;
    final tdee = bmr * _activityFactor(profile.activityLevel);
    final goal = profile.healthGoal.toLowerCase();

    final calories = _goalCalories(goal, tdee);
    final protein = _proteinGrams(goal, weight);
    final water = _waterMl(goal, weight, profile.activityLevel);
    final exercise = _exerciseMinutes(goal, profile.activityLevel);
    final sleep = age < 18 ? 8.5 : 8.0;

    return UserRecommendations(
      dailyCalories: calories.round(),
      proteinGrams: protein.round(),
      waterMl: water.round(),
      exerciseMinutes: exercise,
      sleepHours: sleep,
      bmr: double.parse(bmr.toStringAsFixed(1)),
      tdee: double.parse(tdee.toStringAsFixed(1)),
    );
  }

  static double _activityFactor(String? activityLevel) {
    switch ((activityLevel ?? '').toLowerCase()) {
      case 'lightly active':
        return 1.375;
      case 'moderately active':
        return 1.55;
      case 'very active':
        return 1.725;
      case 'sedentary':
      default:
        return 1.2;
    }
  }

  static double _goalCalories(String goal, double tdee) {
    if (goal == 'lose weight') {
      return (tdee - 450).clamp(1200, 4000).toDouble();
    }
    if (goal == 'build muscle') {
      return (tdee + 250).clamp(1400, 4500).toDouble();
    }
    return tdee.clamp(1200, 4200).toDouble();
  }

  static double _proteinGrams(String goal, double weightKg) {
    if (goal == 'build muscle') {
      return weightKg * 1.8;
    }
    if (goal == 'lose weight') {
      return weightKg * 1.6;
    }
    return weightKg * 1.2;
  }

  static double _waterMl(String goal, double weightKg, String? activityLevel) {
    var water = weightKg * 35;
    if (goal == 'stay active' ||
        goal == 'build muscle' ||
        activityLevel == 'Very Active') {
      water += 400;
    }
    return water.clamp(1500, 4500).toDouble();
  }

  static int _exerciseMinutes(String goal, String? activityLevel) {
    if (goal == 'sleep better') {
      return 20;
    }
    if (goal == 'build muscle') {
      return 45;
    }
    if (goal == 'lose weight') {
      return 40;
    }
    if (activityLevel == 'Very Active') {
      return 30;
    }
    return 25;
  }
}
