import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

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
                userState.signupName = nameController.text;
                userState.name = nameController.text;
                await AuthServiceHelper.createAccountWithEmail(
                  emailController.text,
                  passwordController.text,
                ).then((value) {
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
