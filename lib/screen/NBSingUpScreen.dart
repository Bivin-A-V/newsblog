import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:newsblog/screen/NBHomeScreen.dart';
import 'package:newsblog/services/auth_service.dart';
import 'package:newsblog/utils/NBColors.dart';
import 'package:newsblog/utils/NBWidgets.dart';
import 'package:newsblog/utils/user_state.dart';

class NBSingUpScreen extends StatefulWidget {
  static String tag = '/NBSingUpScreen';

  @override
  NBSingUpScreenState createState() => NBSingUpScreenState();
}

class NBSingUpScreenState extends State<NBSingUpScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final ValueNotifier<bool> passwordObscureNotifier = ValueNotifier(true);

  FocusNode nameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  @override
  void dispose() {
    // Dispose controllers, focus nodes, and notifier
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();

    nameFocus.dispose();
    emailFocus.dispose();
    phoneFocus.dispose();
    passwordFocus.dispose();

    passwordObscureNotifier.dispose(); // Dispose the notifier
    super.dispose();
  }

  // Function to handle account creation
  void createAccount() async {
    String email = emailController.text;
    String password = passwordController.text;
    String username = nameController.text;

    try {
      // Call the AuthServiceHelper to create an account
      String result = await AuthServiceHelper.createAccountWithEmail(
          email, password, username);

      if (result == "Account Created") {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Account Created")));

        // Navigate to the home screen after successful account creation
        finish(context);
        push(NBHomeScreen());
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $result")));
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            100.height,
            Text('Create new\naccount', style: boldTextStyle(size: 30)),
            30.height,
            nbAppTextFieldWidget(
              nameController,
              'Name',
              TextFieldType.NAME,
              focus: nameFocus,
              nextFocus: emailFocus,
            ),
            16.height,
            nbAppTextFieldWidget(
              emailController,
              'Email Address',
              TextFieldType.EMAIL,
              focus: emailFocus,
              nextFocus: phoneFocus,
            ),
            16.height,
            nbAppTextFieldWidget(
              phoneController,
              'Phone Number',
              TextFieldType.PHONE,
              focus: phoneFocus,
              nextFocus: passwordFocus,
            ),
            16.height,
            nbAppTextFieldWidget(
              passwordController,
              'Password',
              TextFieldType.PASSWORD,
              focus: passwordFocus,
              obscureTextNotifier: passwordObscureNotifier,
            ),
            50.height,
            nbAppButtonWidget(
              context,
              'Create Account',
              () async {
                await AuthServiceHelper.createAccountWithEmail(
                        emailController.text,
                        passwordController.text,
                        nameController.text)
                    .then((value) {
                  if (value == "Account Created") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Account Created")),
                    );
                    finish(context);
                    push(
                        NBHomeScreen()); // Fixed: Added `context` as the first argument
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $value")),
                    );
                  }
                }).catchError((error) {
                  // Handle errors
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${error.toString()}")),
                  );
                });
              },
            ),
            30.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Have an Account?', style: primaryTextStyle()),
                Text(' Sign In', style: boldTextStyle(color: NBPrimaryColor))
                    .onTap(
                  () {
                    finish(context);
                  },
                ),
              ],
            ),
          ],
        ).paddingOnly(left: 16, right: 16),
      ),
    );
  }
}
