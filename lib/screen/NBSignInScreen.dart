import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:newsblog/screen/NBForgotPasswordScreen.dart';
import 'package:newsblog/screen/NBHomeScreen.dart';
import 'package:newsblog/screen/NBSingUpScreen.dart';
import 'package:newsblog/utils/NBColors.dart';
import 'package:newsblog/utils/NBImages.dart';
import 'package:newsblog/utils/NBWidgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newsblog/utils/user_state.dart';

class NBSignInScreen extends StatefulWidget {
  static String tag = '/NBSignInScreen';

  const NBSignInScreen({super.key});

  @override
  NBSignInScreenState createState() => NBSignInScreenState();
}

class NBSignInScreenState extends State<NBSignInScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final ValueNotifier<bool> obscureTextNotifier = ValueNotifier(true);

  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool isLoading = false;
  String? profileImageUrl;

  @override
  void dispose() {
    obscureTextNotifier.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Only pre-fill the email if it's changed via Edit Profile screen
    if (userState.email.isNotEmpty) {
      emailController.text = userState.email; // Pre-fill with updated email
    } else {
      emailController.clear(); // Clear in case there's no updated email
    }
  }

  Future<void> signInWithEmailPassword() async {
    try {
      setState(() {
        isLoading = true;
      });
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        toast('Sign-in successful');
        NBHomeScreen().launch(context, isNewTask: true);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for this email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password.';
      } else {
        errorMessage = e.message ?? 'Something went wrong. Please try again.';
      }
      toast(errorMessage, gravity: ToastGravity.CENTER);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      toast('An error occurred. Please try again later.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        setState(() {
          isLoading = false;
        });
        return; // The user canceled the sign-in
      }

      // Get the authentication details from Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential for Firebase authentication
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Fetch user's name and photo URL from Google account
        userState.name = googleUser.displayName ?? ''; // Set user's name
        userState.email = googleUser.email; // Set user's email
        userState.profileImageUrl = googleUser.photoUrl;
        toast('Sign-in with Google successful');
        // Fetch and set the user's profile image URL
        setState(() {
          profileImageUrl = googleUser.photoUrl;
        });
        NBHomeScreen().launch(context, isNewTask: true);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      toast(e.message ?? 'Google sign-in failed.');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      toast('An error occurred. Please try again later.');
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
            Text('Welcome to\nNews Blog', style: boldTextStyle(size: 30)),
            30.height,
            nbAppTextFieldWidget(
              emailController,
              'Email Address',
              TextFieldType.EMAIL,
              focus: emailFocus,
              nextFocus: passwordFocus,
            ),
            16.height,
            nbAppTextFieldWidget(
              passwordController,
              'Password',
              TextFieldType.PASSWORD,
              focus: passwordFocus,
              obscureTextNotifier: obscureTextNotifier,
            ),
            16.height,
            Align(
              alignment: Alignment.centerRight,
              child: Text('Forgot Password?',
                      style: boldTextStyle(color: NBPrimaryColor))
                  .onTap(
                () {
                  NBForgotPasswordScreen().launch(context);
                },
              ),
            ),
            16.height,
            nbAppButtonWidget(
              context,
              isLoading ? 'Signing In...' : 'Sign In',
              isLoading ? null : () => signInWithEmailPassword(),
            ),
            30.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Don\'t have an account?', style: primaryTextStyle()),
                Text(' Sign Up', style: boldTextStyle(color: NBPrimaryColor))
                    .onTap(
                  () {
                    NBSingUpScreen().launch(context);
                  },
                ),
              ],
            ),
            50.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Divider(thickness: 2).expand(),
                8.width,
                Text('Or Sign In with', style: secondaryTextStyle()),
                8.width,
                const Divider(thickness: 2).expand(),
              ],
            ),
            50.height,
            Center(
              child: AppButton(
                onTap: signInWithGoogle,
                width: context.width() * 0.7,
                elevation: 0,
                shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(width: 1, color: grey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(NBGoogleLogo, width: 20, height: 20),
                    8.width,
                    Text('Google', style: primaryTextStyle(color: black)),
                  ],
                ),
              ),
            ),
          ],
        ).paddingOnly(left: 16, right: 16),
      ),
    );
  }
}
