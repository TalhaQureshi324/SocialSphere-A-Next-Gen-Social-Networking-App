import 'package:flutter/material.dart';
import 'package:social_sphere/features/auth/screens/login_screen.dart';
import 'package:social_sphere/theme/pallete.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Social Sphere',
      theme: Pallete.darkModeAppTheme,
      home: const LoginScreen(),
    );
  }
}
