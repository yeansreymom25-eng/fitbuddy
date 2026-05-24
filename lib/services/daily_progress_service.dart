import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/daily_progress.dart';
import 'date_key.dart';

class DailyProgressService {
  DailyProgressService._();

  static final DailyProgressService instance = DailyProgressService._();

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
        .collection('dailyProgress')
        .doc(key ?? dateKey());
  }

  Stream<DailyProgress> watchToday() {
    final key = dateKey();
    return _doc(key).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return DailyProgress(id: key);
      }
      return DailyProgress.fromFirestore(snapshot);
    });
  }

  Future<void> logWater(int amountMl, int targetMl) async {
    final snapshot = await _doc().get();
    final current = snapshot.exists
        ? DailyProgress.fromFirestore(snapshot)
        : DailyProgress(id: dateKey());
    await _doc().set(
      current
          .copyWith(
            waterMl: (current.waterMl + amountMl).clamp(0, targetMl).round(),
          )
          .toFirestore(),
      SetOptions(merge: true),
    );
  }

  Future<void> logSleep(int minutes, int targetMinutes) async {
    final snapshot = await _doc().get();
    final current = snapshot.exists
        ? DailyProgress.fromFirestore(snapshot)
        : DailyProgress(id: dateKey());
    await _doc().set(
      current
          .copyWith(
            sleepMinutes: (current.sleepMinutes + minutes)
                .clamp(0, targetMinutes)
                .round(),
          )
          .toFirestore(),
      SetOptions(merge: true),
    );
  }

  Future<void> logExercise(int minutes, int targetMinutes) async {
    final snapshot = await _doc().get();
    final current = snapshot.exists
        ? DailyProgress.fromFirestore(snapshot)
        : DailyProgress(id: dateKey());
    await _doc().set(
      current
          .copyWith(
            exerciseMinutes: (current.exerciseMinutes + minutes)
                .clamp(0, targetMinutes)
                .round(),
          )
          .toFirestore(),
      SetOptions(merge: true),
    );
  }

  Future<void> setMealCompleted(String mealId, bool completed) async {
    final snapshot = await _doc().get();
    final current = snapshot.exists
        ? DailyProgress.fromFirestore(snapshot)
        : DailyProgress(id: dateKey());
    final meals = {...current.completedMealIds};
    completed ? meals.add(mealId) : meals.remove(mealId);
    await _doc().set(
      current.copyWith(completedMealIds: meals).toFirestore(),
      SetOptions(merge: true),
    );
  }
}
