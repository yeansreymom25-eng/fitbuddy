import 'package:cloud_firestore/cloud_firestore.dart';

class AppReminder {
  final String id;
  final String title;
  final String note;
  final String time;
  final String category;
  final String repeat;
  final bool enabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AppReminder({
    required this.id,
    required this.title,
    required this.note,
    required this.time,
    required this.category,
    this.repeat = 'Daily',
    this.enabled = true,
    this.createdAt,
    this.updatedAt,
  });

  AppReminder copyWith({
    String? id,
    String? title,
    String? note,
    String? time,
    String? category,
    String? repeat,
    bool? enabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      time: time ?? this.time,
      category: category ?? this.category,
      repeat: repeat ?? this.repeat,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore({bool includeCreatedAt = true}) {
    return {
      'title': title,
      'note': note,
      'time': time,
      'category': category,
      'repeat': repeat,
      'enabled': enabled,
      if (includeCreatedAt) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory AppReminder.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    final createdAtValue = data['createdAt'];
    final updatedAtValue = data['updatedAt'];

    return AppReminder(
      id: snapshot.id,
      title: (data['title'] as String?) ?? 'Reminder',
      note: (data['note'] as String?) ?? '',
      time: (data['time'] as String?) ?? '7 AM',
      category: (data['category'] as String?) ?? 'Water',
      repeat: (data['repeat'] as String?) ?? 'Daily',
      enabled: (data['enabled'] as bool?) ?? true,
      createdAt: createdAtValue is Timestamp ? createdAtValue.toDate() : null,
      updatedAt: updatedAtValue is Timestamp ? updatedAtValue.toDate() : null,
    );
  }
}
