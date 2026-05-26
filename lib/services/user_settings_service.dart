import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserSettingsService {
  UserSettingsService._();

  static final UserSettingsService instance = UserSettingsService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _doc {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No signed-in user.');
    }
    return _firestore.collection('users').doc(user.uid);
  }

  Stream<UserFoodPreferences> watchFoodPreferences() {
    return _doc.snapshots().map((snapshot) {
      return UserFoodPreferences.fromMap(snapshot.data()?['foodPreferences']);
    });
  }

  Stream<UserBudgetSettings> watchBudget() {
    return _doc.snapshots().map((snapshot) {
      return UserBudgetSettings.fromMap(snapshot.data()?['budget']);
    });
  }

  Stream<UserFeedbackSettings> watchFeedback() {
    return _doc.snapshots().map((snapshot) {
      return UserFeedbackSettings.fromMap(snapshot.data()?['feedback']);
    });
  }

  Future<UserFoodPreferences> getFoodPreferences() async {
    final snapshot = await _doc.get();
    return UserFoodPreferences.fromMap(snapshot.data()?['foodPreferences']);
  }

  Future<UserBudgetSettings> getBudget() async {
    final snapshot = await _doc.get();
    return UserBudgetSettings.fromMap(snapshot.data()?['budget']);
  }

  Future<void> saveFoodPreferences(UserFoodPreferences preferences) {
    return _doc.set(
      {
        'foodPreferences': preferences.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> saveBudget(UserBudgetSettings budget) {
    return _doc.set(
      {
        'budget': budget.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> saveFeedback(UserFeedbackSettings feedback) {
    return _doc.set(
      {
        'feedback': feedback.toMap(),
        'achievements.feedbackSent': true,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}

class UserFoodPreferences {
  final String dietStyle;
  final String preferredProtein;
  final String spiceLevel;
  final List<String> allergies;
  final List<String> dislikedFoods;

  const UserFoodPreferences({
    required this.dietStyle,
    required this.preferredProtein,
    required this.spiceLevel,
    required this.allergies,
    required this.dislikedFoods,
  });

  factory UserFoodPreferences.defaults() {
    return const UserFoodPreferences(
      dietStyle: 'Balanced',
      preferredProtein: 'Any',
      spiceLevel: 'Medium',
      allergies: [],
      dislikedFoods: [],
    );
  }

  factory UserFoodPreferences.fromMap(Object? value) {
    if (value is! Map) {
      return UserFoodPreferences.defaults();
    }
    final map = Map<String, dynamic>.from(value);
    return UserFoodPreferences(
      dietStyle: map['dietStyle'] as String? ?? 'Balanced',
      preferredProtein: map['preferredProtein'] as String? ?? 'Any',
      spiceLevel: map['spiceLevel'] as String? ?? 'Medium',
      allergies: _stringList(map['allergies']),
      dislikedFoods: _stringList(map['dislikedFoods']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dietStyle': dietStyle,
      'preferredProtein': preferredProtein,
      'spiceLevel': spiceLevel,
      'allergies': allergies,
      'dislikedFoods': dislikedFoods,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserFoodPreferences copyWith({
    String? dietStyle,
    String? preferredProtein,
    String? spiceLevel,
    List<String>? allergies,
    List<String>? dislikedFoods,
  }) {
    return UserFoodPreferences(
      dietStyle: dietStyle ?? this.dietStyle,
      preferredProtein: preferredProtein ?? this.preferredProtein,
      spiceLevel: spiceLevel ?? this.spiceLevel,
      allergies: allergies ?? this.allergies,
      dislikedFoods: dislikedFoods ?? this.dislikedFoods,
    );
  }
}

class UserBudgetSettings {
  final int weeklyBudget;
  final String currency;
  final String shoppingStyle;
  final String cookingTime;

  const UserBudgetSettings({
    required this.weeklyBudget,
    required this.currency,
    required this.shoppingStyle,
    required this.cookingTime,
  });

  factory UserBudgetSettings.defaults() {
    return const UserBudgetSettings(
      weeklyBudget: 30,
      currency: 'USD',
      shoppingStyle: 'Balanced',
      cookingTime: '30 min',
    );
  }

  factory UserBudgetSettings.fromMap(Object? value) {
    if (value is! Map) {
      return UserBudgetSettings.defaults();
    }
    final map = Map<String, dynamic>.from(value);
    return UserBudgetSettings(
      weeklyBudget: (map['weeklyBudget'] as num?)?.round() ?? 30,
      currency: map['currency'] as String? ?? 'USD',
      shoppingStyle: map['shoppingStyle'] as String? ?? 'Balanced',
      cookingTime: map['cookingTime'] as String? ?? '30 min',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'weeklyBudget': weeklyBudget,
      'currency': currency,
      'shoppingStyle': shoppingStyle,
      'cookingTime': cookingTime,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserBudgetSettings copyWith({
    int? weeklyBudget,
    String? currency,
    String? shoppingStyle,
    String? cookingTime,
  }) {
    return UserBudgetSettings(
      weeklyBudget: weeklyBudget ?? this.weeklyBudget,
      currency: currency ?? this.currency,
      shoppingStyle: shoppingStyle ?? this.shoppingStyle,
      cookingTime: cookingTime ?? this.cookingTime,
    );
  }
}

class UserFeedbackSettings {
  final String rating;
  final String mood;
  final String comment;

  const UserFeedbackSettings({
    required this.rating,
    required this.mood,
    required this.comment,
  });

  factory UserFeedbackSettings.defaults() {
    return const UserFeedbackSettings(
      rating: 'Good',
      mood: 'Motivated',
      comment: '',
    );
  }

  factory UserFeedbackSettings.fromMap(Object? value) {
    if (value is! Map) {
      return UserFeedbackSettings.defaults();
    }
    final map = Map<String, dynamic>.from(value);
    return UserFeedbackSettings(
      rating: map['rating'] as String? ?? 'Good',
      mood: map['mood'] as String? ?? 'Motivated',
      comment: map['comment'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rating': rating,
      'mood': mood,
      'comment': comment,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserFeedbackSettings copyWith({
    String? rating,
    String? mood,
    String? comment,
  }) {
    return UserFeedbackSettings(
      rating: rating ?? this.rating,
      mood: mood ?? this.mood,
      comment: comment ?? this.comment,
    );
  }
}

List<String> _stringList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value
      .whereType<String>()
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}
