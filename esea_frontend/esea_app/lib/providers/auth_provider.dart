import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final AppLinks _appLinks = AppLinks();

  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _isInitialized = false;

  StreamSubscription<Uri>? _linkSub;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  // ============================
  // INIT
  // ============================
  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    try {
      print("🔄 Initializing AuthProvider...");

      final cachedUser = await _storageService.getUser();
      if (cachedUser != null) {
        _user = cachedUser;
        _isAuthenticated = true;
      }

      await refreshProfile();
      await _startDeepLinkListener();
    } catch (e) {
      print("❌ INIT ERROR: $e");
    }

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  // ============================
  // LOGIN WITH TOKEN (🔥 FINAL FIX)
  // ============================
  Future<void> loginWithToken(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      print("🔐 Logging in with token...");

      // ✅ USE SERVICE METHOD (IMPORTANT)
      final user = await _authService.loginWithToken(token);

      if (user != null) {
        _user = user;
        _isAuthenticated = true;

        print("✅ Login success → user set");
      } else {
        print("❌ Login failed → no user");
      }
    } catch (e) {
      print("❌ LOGIN ERROR: $e");
    }

    _isLoading = false;
    notifyListeners(); // 🔥 THIS TRIGGERS UI REDIRECT
  }

  // ============================
  // SSO LOGIN URL
  // ============================
  Future<String?> getSSOLoginUrl() async {
    _isLoading = true;
    notifyListeners();

    String? url;
    try {
      url = await _authService.getSSOLoginUrl();
    } catch (e) {
      print("❌ SSO URL ERROR: $e");
      url = null;
    }

    _isLoading = false;
    notifyListeners();

    return url;
  }

  // ============================
  // DEEP LINK HANDLER (SSO)
  // ============================
  Future<void> _startDeepLinkListener() async {
    final Uri? initialUri = await _appLinks.getInitialLink();

    if (initialUri != null) {
      await _handleDeepLink(initialUri);
    }

    _linkSub = _appLinks.uriLinkStream.listen(_handleDeepLink);
  }

  Future<void> _handleDeepLink(Uri uri) async {
    print("🔗 Deep link received: $uri");

    if (uri.scheme == 'esea' &&
        uri.host == 'auth' &&
        uri.path == '/callback') {
      final token = uri.queryParameters['token'];

      if (token != null) {
        await loginWithToken(token);
      }
    }
  }

  // ============================
  // REFRESH PROFILE
  // ============================
  Future<void> refreshProfile() async {
    try {
      print("🔄 Fetching user profile...");

      final freshUser = await _authService.fetchCurrentUser();

      if (freshUser != null) {
        _user = freshUser;
        _isAuthenticated = true;

        await _storageService.saveUser(freshUser);

        // Update notification subscriptions
        await NotificationService().initNotifications(
          isEseaMember: freshUser.eseaId != null && freshUser.eseaId!.isNotEmpty,
          isStudent: freshUser.role == 'student' || freshUser.role == 'Student',
        );

        print("✅ User updated from API");
      } else {
        _user = null;
        _isAuthenticated = false;

        print("⚠️ No valid user → logged out");
      }
    } catch (e) {
      print("❌ REFRESH ERROR: $e");
    }

    notifyListeners();
  }

  // ============================
  // LOGOUT
  // ============================
  Future<void> logout() async {
    print("🚪 Logging out...");

    await _authService.logout();

    _user = null;
    _isAuthenticated = false;

    notifyListeners();
  }

  // ============================
  // DISPOSE
  // ============================
  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }
}