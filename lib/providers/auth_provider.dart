import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// 💡 Removed the unused google_sign_in package import to prevent web-build warning linting errors!

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  AuthProvider() {
    // Automatically listen for changes in user authentication state
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Getter to check if the user is logged in anywhere in the app
  User? get user => _user;
  bool get isAuthenticated => _user != null;

  // 1. Sign Up Function
  Future<String?> signUpWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null; // Return null if successful (no error message)
    } on FirebaseAuthException catch (e) {
      return e.message; // Return the specific Firebase error message
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  // Google Sign-In Flow for Web Popups
  Future<String?> signInWithGoogle() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      // 1. Open the Google popup window
      UserCredential userCredential = await _auth.signInWithPopup(googleProvider);

      // 2. CHECK: Is this user brand new to our database?
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        
        // 3. WIPE IT OUT: Delete the accidental account from Firebase immediately!
        await userCredential.user?.delete(); 
        await _auth.signOut(); 
        
        // 4. BLOCK ENTRY: Send back an error message to display on the screen
        return "This Google account isn't registered yet. Please click 'Sign Up' first!";
      }

      notifyListeners();
      return null; // Absolute success (existing user logged in successfully!)
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signUpWithGoogle() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      // Just sign in normally—if they are new, we let them stay!
      await _auth.signInWithPopup(googleProvider);

      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Sign In Function
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null; 
    } on FirebaseAuthException catch (e) {
      // Catch the unregistered user error codes here!
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        return "This account hasn't been registered yet. Please sign up first!";
      }
      return e.message ?? 'An error occurred during sign in.';
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  // 3. Sign Out Function
  Future<void> signOut() async {
    await _auth.signOut();
  }
}