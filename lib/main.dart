import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ohud/controllers/HomeController.dart';
import 'package:ohud/screens/HomeScreen.dart';
import 'package:ohud/screens/SignInScreen.dart';
import 'package:ohud/themes/themes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ohud App',
      locale: const Locale('ar'),
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      initialBinding: HomeBinding(),
      textDirection: TextDirection.rtl,
      theme: Themes.customLightTheme,
      home: isLoggedIn ? HomeScreen() : SigninScreen(),
    );
  }
}
