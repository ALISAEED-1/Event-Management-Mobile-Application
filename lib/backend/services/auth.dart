
import 'package:firebase_auth/firebase_auth.dart';

class authservices {
  Future<User> registeruser(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await userCredential.user!.sendEmailVerification();
      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw 'Password is too weak. Use at least 6 characters.';
        case 'email-already-in-use':
          throw 'An account with this email already exists.';
        case 'invalid-email':
          throw 'Please enter a valid email address.';
        case 'operation-not-allowed':
          throw 'Email/password sign-up is not enabled.';
        default:
          throw e.message ?? 'Registration failed. Please try again.';
      }
    } catch (e) {
      throw 'Registration failed. Please check your connection and try again.';
    }
  }

  Future<User> loginuser(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw 'No account found with this email.';
        case 'wrong-password':
          throw 'Incorrect password. Please try again.';
        case 'invalid-credential':
          throw 'Invalid email or password. Please try again.';
        case 'invalid-email':
          throw 'Please enter a valid email address.';
        case 'user-disabled':
          throw 'This account has been disabled.';
        case 'too-many-requests':
          throw 'Too many failed attempts. Please try again later.';
        default:
          throw e.message ?? 'Login failed. Please try again.';
      }
    } catch (e) {
      throw 'Login failed. Please check your connection and try again.';
    }
  }

  Future resetpassword(String email) async {
    try {
      return await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw 'No account found with this email.';
        case 'invalid-email':
          throw 'Please enter a valid email address.';
        default:
          throw e.message ?? 'Password reset failed. Please try again.';
      }
    } catch (e) {
      throw 'Password reset failed. Please check your connection and try again.';
    }
  }
}