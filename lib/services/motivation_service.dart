import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'date_key.dart';

class MotivationService {
  MotivationService._();

  static final MotivationService instance = MotivationService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No signed-in user.');
    }
    return user.uid;
  }

  Stream<String> watchToday() async* {
    final message = await ensureTodayMotivation();
    yield message;
    yield* _firestore
        .collection('users')
        .doc(_uid)
        .collection('dailyMotivation')
        .doc(dateKey())
        .snapshots()
        .map((snapshot) => snapshot.data()?['message'] as String? ?? message);
  }

  Future<String> ensureTodayMotivation() async {
    final key = dateKey();
    final doc = _firestore
        .collection('users')
        .doc(_uid)
        .collection('dailyMotivation')
        .doc(key);
    final snapshot = await doc.get();
    final existing = snapshot.data()?['message'] as String?;
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final index = DateTime.now().difference(DateTime(2024, 1, 1)).inDays %
        _messages.length;
    final message = _messages[index];
    await doc.set({
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return message;
  }
}

const _messages = [
  'Small choices today become a stronger body tomorrow.',
  'Finish the next healthy action. Momentum will follow.',
  'Your goal does not need perfect. It needs repeated.',
  'Eat with care, move with purpose, rest like it matters.',
  'Today is a fresh page for water, food, sleep, and movement.',
  'Progress is built by honest logs and kind discipline.',
  'Make the healthy choice easy, then do it again.',
];
