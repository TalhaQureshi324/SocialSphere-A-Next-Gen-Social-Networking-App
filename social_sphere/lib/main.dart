import 'package:flutter/material.dart';
import 'package:social_sphere/core/common/error_text.dart';
import 'package:social_sphere/models/user_model.dart';
import 'package:social_sphere/router.dart';
import 'package:social_sphere/theme/pallete.dart';
import 'package:social_sphere/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    timeago.setLocaleMessages('en', timeago.EnMessages());


  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  UserModel? userModel;

  void getData(WidgetRef ref, User data) async {
    userModel =
        await ref
            .watch(authControllerProvider.notifier)
            .getUserData(data.uid)
            .first;
    ref.read(userProvider.notifier).update((state) => userModel);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(authStateChangeProvider)
        .when(
          data:
              (data) => MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'Social Sphere',
                theme: ref.watch(themeNotifierProvider),
                scaffoldMessengerKey: scaffoldMessengerKey, // Add this line

                routerDelegate: RoutemasterDelegate(
                  routesBuilder: (context) {
                    // if (data != null) {
                    //   getData(ref, data);
                    //   if (userModel != null) {
                    //     return loggedInRoute;
                    //   }
                    // }
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
              ),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
