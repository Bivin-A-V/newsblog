import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newsblog/screen/NBSignInScreen.dart';
import 'package:nb_utils/nb_utils.dart';

Future<void> showLogoutDialog(BuildContext context) async {
  // Show confirmation dialog
  bool? confirmLogout = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Are you sure you want to sign out?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              // If 'No' is pressed, close the dialog and do nothing
              Navigator.of(context).pop(false);
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              // If 'Yes' is pressed, log out and navigate to sign-in screen
              Navigator.of(context).pop(true);
            },
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );

  // If the user confirmed logout, proceed with sign-out and navigation
  if (confirmLogout == true) {
    try {
      // Log the user out from Firebase
      await FirebaseAuth.instance.signOut();

      // Navigate to the sign-in screen
      const NBSignInScreen().launch(context, isNewTask: true);
    } catch (e) {
      log("Error logging out: $e");
      // Optionally, show an error message if logout fails
    }
  }
}
