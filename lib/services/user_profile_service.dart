import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/user_profile.dart';
import 'recommendation_calculator.dart';

class UserProfileService {
  UserProfileService._();

  static final UserProfileService instance = UserProfileService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  String get currentUid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No signed-in user.');
    }
    return user.uid;
  }

  Future<AppUserProfile?> getCurrentProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    final snapshot = await _userDoc(user.uid).get();
    if (!snapshot.exists) {
      return null;
    }
    return AppUserProfile.fromFirestore(snapshot);
  }

  Stream<AppUserProfile?> watchCurrentProfile() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return _userDoc(user.uid).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return AppUserProfile.fromFirestore(snapshot);
    });
  }

  Future<void> saveProfile(AppUserProfile profile) async {
    final enriched = _withRecommendations(profile);
    await _userDoc(enriched.uid)
        .set(enriched.toFirestore(), SetOptions(merge: true));
  }

  Future<void> updateCurrentProfile(Map<String, dynamic> values) async {
    final uid = currentUid;
    await _userDoc(uid).set(
      {
        ...values,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    final profile = await getCurrentProfile();
    if (profile != null) {
      await saveProfile(profile);
    }
  }

  Future<String> uploadProfilePhoto({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final uid = currentUid;
    final ref = _storage.ref('users/$uid/profile/$fileName');
    await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final url = await ref.getDownloadURL();
    await _userDoc(uid).set(
      {
        'photoUrl': url,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    return url;
  }

  Future<void> ensureAuthProfile({
    required String fullName,
    required String email,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }
    await _userDoc(user.uid).set(
      {
        'uid': user.uid,
        'fullName': fullName,
        'email': email,
        'onboardingComplete': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  AppUserProfile _withRecommendations(AppUserProfile profile) {
    final recommendations = RecommendationCalculator.calculate(profile);
    return profile.copyWith(recommendations: recommendations);
  }
}
