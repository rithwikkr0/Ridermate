import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../services/authentication_service.dart';
import '../services/user_profile_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthenticationService _authService = AuthenticationService();
  final UserProfileService _profileService = UserProfileService();

  firebase_auth.User? _firebaseUser;
  User? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  firebase_auth.User? get firebaseUser => _firebaseUser;
  User? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isEmailVerified => _authService.isEmailVerified;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _authService.authStateChanges.listen((user) async {
      _firebaseUser = user;
      if (user != null) {
        await _loadUserProfile(user.uid);
        await _profileService.updateLastLogin(user.uid);
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      _userProfile = await _profileService.getUserProfile(userId);
    } catch (e) {
      _errorMessage = 'Failed to load user profile: $e';
    }
  }

  Future<bool> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final credential = await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
        name: name,
      );

      if (credential.user != null) {
        await _profileService.createUserProfile(
          userId: credential.user!.uid,
          email: email,
          name: name,
          photoUrl: credential.user!.photoURL,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final credential = await _authService.signInWithGoogle();

      if (credential.user != null) {
        // Check if user profile exists, create if not
        final existingProfile = await _profileService.getUserProfile(credential.user!.uid);
        if (existingProfile == null) {
          await _profileService.createUserProfile(
            userId: credential.user!.uid,
            email: credential.user!.email ?? '',
            name: credential.user!.displayName ?? 'User',
            photoUrl: credential.user!.photoURL,
          );
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInAnonymously() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final credential = await _authService.signInAnonymously();

      if (credential.user != null) {
        await _profileService.createUserProfile(
          userId: credential.user!.uid,
          email: 'anonymous@ridermate.app',
          name: 'Guest User',
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.sendPasswordResetEmail(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> reloadUser() async {
    await _authService.reloadUser();
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _userProfile = null;
      _firebaseUser = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    try {
      if (_firebaseUser == null) return false;

      await _profileService.updateUserProfile(_firebaseUser!.uid, updates);
      await _loadUserProfile(_firebaseUser!.uid);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
