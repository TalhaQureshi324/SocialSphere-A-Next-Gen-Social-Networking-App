import 'package:flutter/material.dart';
import 'package:social_sphere/core/common/error_text.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/core/common/offline_screen.dart';
import 'package:social_sphere/core/providers/ads_provider.dart';
import 'package:social_sphere/core/providers/connectivity_provider.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:social_sphere/firebase_options.dart';
import 'package:social_sphere/models/user_model.dart';
import 'package:social_sphere/router.dart';
import 'package:social_sphere/theme/pallete.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:connectivity_plus/connectivity_plus.dart';

// NEW IMPORTS for Ads
import 'package:social_sphere/core/ads/ads_controller.dart'; // Update path as per your project structure
import 'package:social_sphere/core/providers/ads_provider.dart';    // Update path as per your project structure

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize AdsController
  final adsController = AdsController();
  await adsController.initialize();

  timeago.setLocaleMessages('en', timeago.EnMessages());

  runApp(
    ProviderScope(
      overrides: [
        adsControllerProvider.overrideWithValue(adsController),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  UserModel? userModel;

  void getData(WidgetRef ref, User data) async {
    userModel = await ref
        .watch(authControllerProvider.notifier)
        .getUserData(data.uid)
        .first;
    ref.read(userProvider.notifier).update((state) => userModel);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final connectivityState = ref.watch(connectivityProvider);

    return connectivityState.when(
      data: (isConnected) {
        if (!isConnected) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Social Sphere',
            theme: ref.watch(themeNotifierProvider),
            home: const OfflineScreen(),
          );
        }

        return ref.watch(authStateChangeProvider).when(
          data: (data) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Social Sphere',
              theme: ref.watch(themeNotifierProvider),
              scaffoldMessengerKey: scaffoldMessengerKey,
              routerDelegate: RoutemasterDelegate(
                routesBuilder: (context) {
                  if (data != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && userModel == null) {
                        getData(ref, data);
                      }
                    });
                    if (userModel != null) {
                      return loggedInRoute;
                    }
                  }
                  return loggedOutRoute;
                },
              ),
              routeInformationParser: const RoutemasterParser(),
            );
          },
          error: (error, stackTrace) => MaterialApp(
            home: Scaffold(
              body: ErrorText(error: error.toString()),
            ),
          ),
          loading: () => const MaterialApp(
            home: Scaffold(body: Loader()),
          ),
        );
      },
      error: (error, stackTrace) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: ErrorText(error: 'Connectivity error: ${error.toString()}'),
          ),
        ),
      ),
      loading: () => const MaterialApp(
        home: Scaffold(body: Loader()),
      ),
    );
  }
}
