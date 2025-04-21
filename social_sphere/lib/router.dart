import 'package:routemaster/routemaster.dart';
import 'package:flutter/material.dart';
import 'package:social_sphere/features/auth/screens/login_screen.dart';
import 'package:social_sphere/features/community/screens/add_mods_screen.dart';
import 'package:social_sphere/features/community/screens/edit_community_screen.dart';
import 'package:social_sphere/features/home/screens/home_screen.dart';
import 'package:social_sphere/features/community/screens/create_community_screen.dart';
import 'package:social_sphere/features/community/screens/community_screen.dart';
import 'package:social_sphere/features/community/screens/mod_tools_screen.dart';

final loggedOutRoute = RouteMap(
  routes: {'/': (_) => const MaterialPage(child: LoginScreen())},
);

final loggedInRoute = RouteMap(
  routes: {
    '/': (_) => const MaterialPage(child: HomeScreen()),
    '/create-community':
        (_) => const MaterialPage(child: CreateCommunityScreen()),
    '/r/:name':
        (route) => MaterialPage(
          child: CommunityScreen(name: route.pathParameters['name']!),
        ),
    '/mod-tools/:name':
        (routeData) => MaterialPage(
          child: ModToolsScreen(name: routeData.pathParameters['name']!),
        ),
    '/edit-community/:name':
        (routeData) => MaterialPage(
          child: EditCommunityScreen(name: routeData.pathParameters['name']!),
        ),
    '/add-mods/:name':
        (routeData) => MaterialPage(
          child: AddModsScreen(name: routeData.pathParameters['name']!),
        ),
  },
);
