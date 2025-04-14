import 'package:flutter/material.dart';
import 'package:social_sphere/features/auth/screens/login_screen.dart';
import 'package:social_sphere/router.dart';
import 'package:social_sphere/theme/pallete.dart';
import 'package:social_sphere/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

void main() async{
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);

  runApp(const ProviderScope(child: MyApp()),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Social Sphere',
      theme: Pallete.darkModeAppTheme,
       routerDelegate: RoutemasterDelegate(routesBuilder: (context) => loggedOutRoute),
        routeInformationParser: const RoutemasterParser(),
    );
  }
}
