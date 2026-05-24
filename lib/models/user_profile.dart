import 'package:cloud_firestore/cloud_firestore.dart';

class UserRecommendations {
  final int dailyCalories;
  final int proteinGrams;
  final int waterMl;
  final int exerciseMinutes;
  final double sleepHours;
  final double bmr;
  final double tdee;

  const UserRecommendations({
    required this.dailyCalories,
    required this.proteinGrams,
    required this.waterMl,
    required this.exerciseMinutes,
    required this.sleepHours,
    required this.bmr,
    required this.tdee,
  });

  Map<String, dynamic> toMap() {
    return {
      'dailyCalories': dailyCalories,
      'proteinGrams': proteinGrams,
      'waterMl': waterMl,
      'exerciseMinutes': exerciseMinutes,
      'sleepHours': sleepHours,
      'bmr': bmr,
      'tdee': tdee,
    };
  }

  factory UserRecommendations.fromMap(Map<String, dynamic>? map) {
    final data = map ?? const <String, dynamic>{};
    return UserRecommendations(
      dailyCalories: (data['dailyCalories'] as num?)?.round() ?? 1800,
      proteinGrams: (data['proteinGrams'] as num?)?.round() ?? 90,
      waterMl: (data['waterMl'] as num?)?.round() ?? 2000,
      exerciseMinutes: (data['exerciseMinutes'] as num?)?.round() ?? 30,
      sleepHours: (data['sleepHours'] as num?)?.toDouble() ?? 8,
      bmr: (data['bmr'] as num?)?.toDouble() ?? 0,
      tdee: (data['tdee'] as num?)?.toDouble() ?? 0,
    );
  }
}

class AppUserProfile {
  final String uid;
  final String fullName;
  final String email;
  final String gender;
  final DateTime dateOfBirth;
  final double weightKg;
  final double heightCm;
  final String healthGoal;
  final double? targetWeightKg;
  final String? activityLevel;
  final String? country;
  final String? photoUrl;
  final bool onboardingComplete;
  final UserRecommendations? recommendations;
  final DateTime? updatedAt;

  const AppUserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.gender,
    required this.dateOfBirth,
    required this.weightKg,
    required this.heightCm,
    required this.healthGoal,
    this.targetWeightKg,
    this.activityLevel,
    this.country,
    this.photoUrl,
    this.onboardingComplete = false,
    this.recommendations,
    this.updatedAt,
  });

  int get age {
    final now = DateTime.now();
    var years = now.year - dateOfBirth.year;
    final hadBirthday = now.month > dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day >= dateOfBirth.day);
    if (!hadBirthday) {
      years--;
    }
    return years.clamp(0, 120);
  }

  bool get needsWeightGoal => healthGoal.toLowerCase() == 'lose weight';

  AppUserProfile copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? gender,
    DateTime? dateOfBirth,
    double? weightKg,
    double? heightCm,
    String? healthGoal,
    double? targetWeightKg,
    bool clearTargetWeight = false,
    String? activityLevel,
    String? country,
    String? photoUrl,
    bool? onboardingComplete,
    UserRecommendations? recommendations,
    DateTime? updatedAt,
  }) {
    return AppUserProfile(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      healthGoal: healthGoal ?? this.healthGoal,
      targetWeightKg:
          clearTargetWeight ? null : targetWeightKg ?? this.targetWeightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      country: country ?? this.country,
      photoUrl: photoUrl ?? this.photoUrl,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      recommendations: recommendations ?? this.recommendations,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'gender': gender,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'weightKg': weightKg,
      'heightCm': heightCm,
      'healthGoal': healthGoal,
      'targetWeightKg': targetWeightKg,
      'activityLevel': activityLevel,
      'country': country,
      'photoUrl': photoUrl,
      'onboardingComplete': onboardingComplete,
      'recommendations': recommendations?.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory AppUserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    final dobValue = data['dateOfBirth'];
    final updatedAtValue = data['updatedAt'];

    return AppUserProfile(
      uid: (data['uid'] as String?) ?? snapshot.id,
      fullName: (data['fullName'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      gender: (data['gender'] as String?) ?? 'Other',
      dateOfBirth: dobValue is Timestamp
          ? dobValue.toDate()
          : DateTime.now().subtract(const Duration(days: 365 * 18)),
      weightKg: (data['weightKg'] as num?)?.toDouble() ?? 0,
      heightCm: (data['heightCm'] as num?)?.toDouble() ?? 0,
      healthGoal: (data['healthGoal'] as String?) ?? 'Stay Active',
      targetWeightKg: (data['targetWeightKg'] as num?)?.toDouble(),
      activityLevel: data['activityLevel'] as String?,
      country: data['country'] as String?,
      photoUrl: data['photoUrl'] as String?,
      onboardingComplete: data['onboardingComplete'] as bool? ?? false,
      recommendations: UserRecommendations.fromMap(
        data['recommendations'] is Map
            ? Map<String, dynamic>.from(data['recommendations'] as Map)
            : null,
      ),
      updatedAt: updatedAtValue is Timestamp ? updatedAtValue.toDate() : null,
    );
  }
}
