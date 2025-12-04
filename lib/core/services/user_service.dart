import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static final _users = FirebaseFirestore.instance.collection('users');


/// Fetch current user's info from FirebaseAuth + Firestore
static Future<Map<String, dynamic>?> getCurrentUserInfo() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await _users.doc(user.uid).get();
    final firestoreData = doc.exists ? doc.data() ?? {} : {};

    return {
      "uid": user.uid,
      "email": user.email,
      ...firestoreData, // merge Firestore fields
    };
  } catch (e) {
    print("Error fetching user info: $e");
    return null;
  }
}


  /// Update user's Firestore profile fields
  static Future<void> updateUserProfile({
    required String username,
    String? password,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("No user logged in");

   

    // Update password if provided
    if (password != null && password.isNotEmpty) {
      await user.updatePassword(password);
    }

    // Update Firestore fields
    await _users.doc(user.uid).set({
      'username': username,
    }, SetOptions(merge: true));
  }
}
