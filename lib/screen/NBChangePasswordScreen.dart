import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:newsblog/utils/NBWidgets.dart';

class NBChangePasswordScreen extends StatefulWidget {
  @override
  _NBChangePasswordScreenState createState() => _NBChangePasswordScreenState();
}

class _NBChangePasswordScreenState extends State<NBChangePasswordScreen> {
  TextEditingController oldPassCont = TextEditingController();
  TextEditingController newPassCont = TextEditingController();
  TextEditingController confirmPassCont = TextEditingController();

  FocusNode oldPassFocus = FocusNode();
  FocusNode newPassFocus = FocusNode();
  FocusNode confirmPassFocus = FocusNode();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _changePassword() async {
    String oldPassword = oldPassCont.text.trim();
    String newPassword = newPassCont.text.trim();
    String confirmPassword = confirmPassCont.text.trim();

    if (newPassword != confirmPassword) {
      toasty(context, 'Passwords do not match');
      return;
    }

    try {
      // Reauthenticate user
      User? user = _auth.currentUser;
      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: oldPassword,
        );

        await user.reauthenticateWithCredential(credential);

        // Update password
        await user.updatePassword(newPassword);

        toasty(context, 'Password changed successfully');
        finish(context);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      if (e.code == 'wrong-password') {
        errorMessage = 'The old password is incorrect.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The new password is too weak.';
      } else {
        errorMessage = 'An error occurred: ${e.message}';
      }

      toasty(context, errorMessage);
    } catch (e) {
      toasty(context, 'An unexpected error occurred');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: nbAppBarWidget(context, title: 'Change Password'),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              nbAppTextFieldWidget(
                oldPassCont,
                'Old Password',
                TextFieldType.PASSWORD,
                focus: oldPassFocus,
                nextFocus: newPassFocus,
              ),
              16.height,
              nbAppTextFieldWidget(
                newPassCont,
                'New Password',
                TextFieldType.PASSWORD,
                focus: newPassFocus,
                nextFocus: confirmPassFocus,
              ),
              16.height,
              nbAppTextFieldWidget(confirmPassCont, 'Repeat New Password',
                  TextFieldType.PASSWORD,
                  focus: confirmPassFocus),
              16.height,
              nbAppButtonWidget(
                context,
                'Continue',
                _changePassword,
              ),
            ],
          ).paddingAll(16),
        ),
      ),
    );
  }
}
