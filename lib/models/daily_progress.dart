import 'package:cloud_firestore/cloud_firestore.dart';

class DailyProgress {
  final String id;
  final int waterMl;
  final int sleepMinutes;
  final int exerciseMinutes;
  final Set<String> completedMealIds;
  final DateTime? updatedAt;

  const DailyProgress({
    required this.id,
    this.waterMl = 0,
    this.sleepMinutes = 0,
    this.exerciseMinutes = 0,
    this.completedMealIds = const <String>{},
    this.updatedAt,
  });

  DailyProgress copyWith({
    int? waterMl,
    int? sleepMinutes,
    int? exerciseMinutes,
    Set<String>? completedMealIds,
    DateTime? updatedAt,
  }) {
    return DailyProgress(
      id: id,
      waterMl: waterMl ?? this.waterMl,
      sleepMinutes: sleepMinutes ?? this.sleepMinutes,
      exerciseMinutes: exerciseMinutes ?? this.exerciseMinutes,
      completedMealIds: completedMealIds ?? this.completedMealIds,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'waterMl': waterMl,
      'sleepMinutes': sleepMinutes,
      'exerciseMinutes': exerciseMinutes,
      'completedMealIds': completedMealIds.toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory DailyProgress.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    final updatedAtValue = data['updatedAt'];
    return DailyProgress(
      id: snapshot.id,
      waterMl: (data['waterMl'] as num?)?.round() ?? 0,
      sleepMinutes: (data['sleepMinutes'] as num?)?.round() ?? 0,
      exerciseMinutes: (data['exerciseMinutes'] as num?)?.round() ?? 0,
      completedMealIds: ((data['completedMealIds'] as List?) ?? const [])
          .cast<String>()
          .toSet(),
      updatedAt: updatedAtValue is Timestamp ? updatedAtValue.toDate() : null,
    );
  }
}
