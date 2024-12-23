import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:newsblog/firebase_options.dart';
import 'package:newsblog/screen/NBHomeScreen.dart';
import 'package:newsblog/screen/NBWalkThroughScreen.dart';
import 'package:newsblog/store/AppStore.dart';
import 'package:newsblog/utils/AppTheme.dart';
import 'package:newsblog/utils/NBDataProviders.dart';
import 'package:easy_localization/easy_localization.dart';

AppStore appStore = AppStore();

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await initialize(aLocaleLanguageList: languageList());

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  appStore.toggleDarkMode(value: getBoolAsync('isDarkModeOnPref'));

  defaultRadius = 10;
  defaultToastGravityGlobal = ToastGravity.BOTTOM;
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('es', 'ES'),
        Locale('zh', 'CN'),
        Locale('fr', 'FR'),
        Locale('ms', 'MY'),
      ],
      path:
          'assets/langs', // Specify the folder where your json files are stored
      fallbackLocale: const Locale('en', 'US'),
      child: MyApp(),
    ),
  );

  Future.delayed(const Duration(seconds: 3), () {
    FlutterNativeSplash.remove();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '${'News Blog'}${!isMobile ? ' ${platformName()}' : ''}',
        localizationsDelegates: [
          EasyLocalization.of(context)!.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: EasyLocalization.of(context)!.supportedLocales,
        locale: EasyLocalization.of(context)!.locale,
        home: FutureBuilder<bool>(
          future: _getInitialScreen(), // Determines the initial screen
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Show a loader while checking
            }

            if (snapshot.hasError) {
              return const Center(child: Text("Error occurred"));
            }

            // Navigate based on the result
            return snapshot.data == true
                ? const NBWalkThroughScreen()
                : NBHomeScreen();
          },
        ),
        theme: !appStore.isDarkModeOn
            ? AppThemeData.lightTheme
            : AppThemeData.darkTheme,
        navigatorKey: navigatorKey,
        scrollBehavior: SBehavior(),
      ),
    );
  }

  Future<bool> _getInitialScreen() async {
    // Check if the user is opening the app for the first time
    bool isFirstLaunch = getBoolAsync('isFirstLaunch', defaultValue: true);

    if (isFirstLaunch) {
      await setValue('isFirstLaunch', false); // Set first launch to false
      return true; // Show NBWalkThroughScreen
    }

    // Check if a user is signed in using Firebase
    User? currentUser = FirebaseAuth.instance.currentUser;
    return currentUser == null; // Show NBWalkThroughScreen if no user
  }
}
