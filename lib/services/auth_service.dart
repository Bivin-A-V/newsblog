import 'package:firebase_auth/firebase_auth.dart';

class AuthServiceHelper {
  static Future<String> createAccountWithEmail(
      String email, String password) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return "Account Created";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    } catch (e) {
      return e.toString();
    }
  }

  //login
  static Future<String> loginWithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return "Sign In Successful";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    } catch (e) {
      return e.toString();
    }
  }

  //Logout
  static Future logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    } catch (e) {
      return e.toString();
    }
  }

  //check User
  static Future<bool> isUserLoggedIn() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null ? true : false;
  }
}
