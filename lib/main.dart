import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:mad_project/screens/dashboard.dart';
import 'package:mad_project/screens/login.dart';
import 'package:mad_project/screens/register.dart';
import 'package:mad_project/screens/resetPassScreen.dart';
import 'package:mad_project/screens/splash.dart'; // Import the custom splash screen
// import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/mainScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) =>
            const SplashScreen(), // Set the custom splash screen as the initial route
        '/mainscreen': (context) => const MainScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/resetpass': (context) => ResetPassScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
