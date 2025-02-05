import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // Sign in with Email and Password
  Future<UserCredential> signInWithEmailandPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _fireStore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      }, SetOptions(merge: true));

      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during sign-in: ${e.code}');
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found for that email. Please register.');
        case 'wrong-password':
          throw Exception('Incorrect password. Please try again.');
        case 'invalid-email':
          throw Exception('Invalid email format.');
        default:
          throw Exception('Authentication error: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error during sign-in: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  // Sign up with Email and Password
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Log for debugging user registration
      print('User registered with UID: ${userCredential.user!.uid}');

      // Add user data to Firestore
      await _fireStore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      });

      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during sign-up: ${e.code}');
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('This email is already in use.');
        case 'invalid-email':
          throw Exception('The email address is not valid.');
        case 'weak-password':
          throw Exception('The password is too weak (minimum 6 characters).');
        default:
          throw Exception('Registration failed: ${e.message}');
      }
    } catch (e) {
      print('Unknown error during sign-up: $e');
      throw Exception('Unknown error: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await firebaseAuth.signOut();
    notifyListeners();
  }

  // Helper to get current user
  User? get currentUser => firebaseAuth.currentUser;

  // Listen for auth state changes
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();
}
