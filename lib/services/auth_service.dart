import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' show log;

/// Authentication service using Firebase Auth and SharedPreferences.
class AuthService {
  static const String _kIsLoggedInKey = 'is_logged_in';
  static const String _kHasAccountKey = 'has_account';

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Gets the current Firebase user
  static User? get currentUser => _auth.currentUser;

  /// Checks if the user is currently logged in with Firebase
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final localLoggedIn = prefs.getBool(_kIsLoggedInKey) ?? false;

    // Must be logged in both locally and in Firebase
    final firebaseUser = _auth.currentUser;
    final isAuthenticated = localLoggedIn && firebaseUser != null;

    log(
      'Auth check - Local: $localLoggedIn, Firebase: ${firebaseUser != null}, Result: $isAuthenticated',
    );

    return isAuthenticated;
  }

  /// Checks if the device has an existing account.
  static Future<bool> hasAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getBool(_kHasAccountKey) ?? false;
  }

  /// Signs the user in with email and password.
  /// Returns true if successful, throws exception otherwise.
  static Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      log('Attempting sign in for: $email');

      // Sign in with Firebase
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Sign in failed - no user returned');
      }

      log('Firebase sign in successful for: ${userCredential.user!.email}');

      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kIsLoggedInKey, true);
      await prefs.setBool(_kHasAccountKey, true);

      return true;
    } on FirebaseAuthException catch (e) {
      log('Firebase Auth Error: ${e.code} - ${e.message}');

      // Handle specific Firebase errors
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage =
              'No account found with this email. Please create an account.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address format.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later.';
          break;
        case 'invalid-credential':
          errorMessage =
              'Invalid credentials. Please check your email and password.';
          break;
        default:
          errorMessage =
              e.message ?? 'Authentication failed. Please try again.';
      }

      throw Exception(errorMessage);
    } catch (e) {
      log('Sign in error: $e');
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  /// Creates a new account with email, password, and name.
  /// Returns true if successful, throws exception otherwise.
  static Future<bool> createAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      log('Attempting to create account for: $email');

      // Create user with Firebase
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Account creation failed - no user returned');
      }

      log('Firebase account created for: ${userCredential.user!.email}');

      // Update user profile with display name
      await userCredential.user!.updateDisplayName(name);
      await userCredential.user!.reload();

      log('User profile updated with name: $name');

      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kHasAccountKey, true);
      await prefs.setBool(_kIsLoggedInKey, true);

      return true;
    } on FirebaseAuthException catch (e) {
      log('Firebase Auth Error: ${e.code} - ${e.message}');

      // Handle specific Firebase errors
      String errorMessage;

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage =
              'An account already exists with this email. Please sign in instead.';
          break;
        case 'weak-password':
          errorMessage =
              'Password is too weak. Please use a stronger password.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address format.';
          break;
        case 'operation-not-allowed':
          errorMessage =
              'Email/password accounts are not enabled. Please contact support.';
          break;
        default:
          errorMessage =
              e.message ?? 'Account creation failed. Please try again.';
      }

      throw Exception(errorMessage);
    } catch (e) {
      log('Account creation error: $e');
      throw Exception('Account creation failed: ${e.toString()}');
    }
  }

  /// Signs the user out from both Firebase and local storage.
  static Future<void> signOut() async {
    try {
      log('Signing out user: ${_auth.currentUser?.email}');

      // Sign out from Firebase
      await _auth.signOut();

      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kIsLoggedInKey, false);

      log('Sign out successful');
    } catch (e) {
      log('Sign out error: $e');
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  /// Gets the current user's display name
  static String? getCurrentUserName() {
    return _auth.currentUser?.displayName;
  }

  /// Gets the current user's email
  static String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }

  /// Gets the current user's UID
  static String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Checks if email is verified
  static bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// Sends email verification
  static Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      log('Email verification error: $e');
      throw Exception('Failed to send verification email');
    }
  }
}
