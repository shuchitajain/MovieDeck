import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movie_deck/data/local/session_storage.dart';
import 'package:movie_deck/ui/config.dart';

class AuthState {
  final User? user;
  final String? errorMessage;

  const AuthState({this.user, this.errorMessage});

  AuthState copyWith(
      {User? user,
      String? errorMessage,
      bool clearError = false,
      bool clearUser = false}) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late final FirebaseAuth _auth;
  late final SessionStorage _session;

  @override
  AuthState build() {
    _auth = FirebaseAuth.instance;
    _session = SessionStorage(App.fss);
    return const AuthState();
  }

  Stream<User?> get authState => _auth.idTokenChanges();

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<int> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final auth = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = auth.user;
      await user!.updateDisplayName(name);
      await user.reload();
      User? updatedUser = _auth.currentUser;
      if (updatedUser != null) {
        await _session.saveUser(updatedUser);
      }
      state = state.copyWith(user: updatedUser);
      return -1;
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") return 0;
      if (e.code == "weak-password") return 1;
      return 2;
    } catch (e) {
      state = state.copyWith(
          errorMessage: 'An unexpected error occurred. Please try again.');
      debugPrint('signUp error: $e');
      return 2;
    }
  }

  Future<int> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final auth = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = auth.user;
      if (user != null) {
        await _session.saveUser(user);
      }
      state = state.copyWith(user: user);
      return -1;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return 0;
      if (e.code == 'wrong-password') return 1;
      return 2;
    } catch (e) {
      state = state.copyWith(
          errorMessage: 'An unexpected error occurred. Please try again.');
      debugPrint('signIn error: $e');
      return 2;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final auth = await _auth.signInWithCredential(credential);
      final user = auth.user;
      if (user != null) {
        await _session.saveUser(user);
      }
      state = state.copyWith(user: user);
      return true;
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      return false;
    }
  }

  Future signOut() async {
    try {
      await _auth.signOut();
      await _session.clearAll();
      state = state.copyWith(clearUser: true);
    } catch (e) {
      state =
          state.copyWith(errorMessage: 'Failed to sign out. Please try again.');
      debugPrint('signOut error: $e');
    }
  }
}
