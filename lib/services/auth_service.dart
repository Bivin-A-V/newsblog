import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AuthServiceHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to save user data to Firestore with a unique ID
  static Future<void> saveUserDataToFirestore(
      String username, String email) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!
          .uid; // Get the current user ID from Firebase Authentication

      // Get the current date
      final formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

      // Save the user document in the 'Users' collection
      await _firestore.collection('Users').doc(userId).set({
        'name': username,
        'email': email,
        'createdAt': formattedDate,
        'profileImageUrl': null, // Initially null, can be updated later
        'articles': 0, // Initialize articles count
        'followers': 0, // Initialize followers count
        'following': 0, // Initialize following count
      });

      print("User document created with ID: $userId");
    } catch (e) {
      print('Error saving user data to Firestore: $e');
    }
  }

  // Method to create an account with email and password
  static Future<String> createAccountWithEmail(
      String email, String password, String username) async {
    try {
      // Create the user with Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save the user data to Firestore using the generated random ID
      await saveUserDataToFirestore(username, email);

      return "Account Created";
    } catch (e) {
      print('Error creating account: $e');
      return 'Error: $e';
    }
  }
}
