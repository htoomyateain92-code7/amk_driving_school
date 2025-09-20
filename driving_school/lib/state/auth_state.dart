// lib/state/auth_state.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api.dart';
import '../services/endpoints.dart';
import '../services/notifications.dart';

enum UserRole { owner, admin, instructor, student, guest }

class AuthState extends ChangeNotifier {
  bool isAuthed = false;
  UserRole role = UserRole.guest;
  int? userId;
  String? username;

  // ---------- ACTIONS ----------
  Future<void> login(String u, String p) async {
    final tokens = await Endpoints.login(u, p);
    await api.setToken(tokens['access'], tokens['refresh']);

    final me = await Endpoints.me();
    userId = me['id'];
    username = me['username'];
    role = _mapRole(me['role']);
    isAuthed = true;
    notifyListeners();

    // register FCM token after we’re authenticated
    await NotificationService.registerTokenWithServer();
  }

  Future<void> register({
    required String username,
    String? email,
    required String password,
  }) async {
    await Endpoints.register(
      username: username,
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await api.clearToken();
    isAuthed = false;
    role = UserRole.guest;
    userId = null;
    username = null;
    notifyListeners();
  }

  // ---------- HELPERS ----------
  UserRole _mapRole(String? r) {
    switch (r) {
      case 'owner':
        return UserRole.owner;
      case 'admin':
        return UserRole.admin;
      case 'instructor':
        return UserRole.instructor;
      case 'student':
        return UserRole.student;
      default:
        return UserRole.guest;
    }
  }
}

// global provider
final authProvider = ChangeNotifierProvider<AuthState>((_) => AuthState());
