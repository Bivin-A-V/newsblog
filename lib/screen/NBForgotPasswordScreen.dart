import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newsblog/screen/NBSignInScreen.dart';
import 'package:newsblog/utils/NBWidgets.dart';

class NBForgotPasswordScreen extends StatefulWidget {
  const NBForgotPasswordScreen({super.key});

  @override
  NBForgotPasswordScreenState createState() => NBForgotPasswordScreenState();
}

class NBForgotPasswordScreenState extends State<NBForgotPasswordScreen> {
  TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      toast('Password reset email sent. Check your inbox.');

      // Use nb_utils to navigate to NBSignInScreen after sending the password reset email
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const NBSignInScreen()));
    } catch (e) {
      toast('Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget('Forgot Password',
          elevation: 0, color: context.cardColor),
      body: Column(
        children: [
          16.height,
          nbAppTextFieldWidget(
              emailController, 'Email Address', TextFieldType.EMAIL),
          16.height,
          nbAppButtonWidget(
            context,
            'Send Password',
            () async {
              if (emailController.text.isNotEmpty &&
                  emailController.text.contains('@')) {
                try {
                  await sendPasswordResetEmail(emailController.text);
                  toast('Password reset email sent. Check your inbox.');
                } catch (e) {
                  toast('Failed to send email. Please try again.');
                }
              } else {
                toast('Please enter a valid email address');
              }
            },
          ),
        ],
      ).paddingOnly(left: 16, right: 16),
    );
  }
}
