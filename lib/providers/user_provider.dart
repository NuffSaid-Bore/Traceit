import 'package:flutter/material.dart';
import '../core/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  String? uid;
  String username = '';
  String email = '';

  bool loading = false;

  UserProvider() {
    loadUser();
  }

  Future<void> loadUser() async {
    loading = true;
    notifyListeners();

    final data = await UserService.getCurrentUserInfo();
    if (data != null) {
      username = data['username'] ?? '';
      uid = data['uid'] ?? null;
    }

    loading = false;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String newUsername,
    String? newPassword,
  }) async {
    loading = true;
    notifyListeners();

    try {
      await UserService.updateUserProfile(
        username: newUsername,
        password: newPassword,
      );

      username = newUsername;
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
