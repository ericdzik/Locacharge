import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Connexion avec email et mot de passe
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint("Erreur login email : ${e.code} - ${e.message}");
      rethrow;
    }
  }

  /// Création de compte avec email et mot de passe
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint("Erreur signup email : ${e.code} - ${e.message}");
      rethrow;
    }
  }

  /// Connexion via Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Pour mobile
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'CANCELLED',
          message: "Connexion annulée par l'utilisateur",
        );
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      debugPrint("Erreur Google Sign-In : ${e.code} - ${e.message}");
      rethrow;
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      // Éviter l'initialisation automatique de Google Sign-In
      try {
        final googleSignIn = GoogleSignIn();
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
        }
      } catch (e) {
        // Ignorer les erreurs Google Sign-In pour éviter les problèmes de configuration
        debugPrint("Google Sign-In non configuré ou erreur ignorée: $e");
      }
    } catch (e) {
      debugPrint("Erreur déconnexion : $e");
      rethrow;
    }
  }

  /// Suivre l'état de connexion
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Utilisateur courant
  User? get currentUser => _auth.currentUser;
}
