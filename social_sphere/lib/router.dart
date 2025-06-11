import 'package:flutter/material.dart';
import 'package:social_sphere/features/auth/screens/login_screen.dart';
import 'package:social_sphere/features/chat/screens/chat_list_screen.dart';
import 'package:social_sphere/features/chat/screens/chat_screen.dart';
import 'package:social_sphere/features/community/screens/add_mods_screen.dart';
import 'package:social_sphere/features/community/screens/community_screen.dart';
import 'package:social_sphere/features/community/screens/create_community_screen.dart';
import 'package:social_sphere/features/community/screens/edit_community_screen.dart';
import 'package:social_sphere/features/community/screens/mod_tools_screen.dart';
import 'package:social_sphere/features/home/screens/home_screen.dart';
import 'package:social_sphere/features/post/screens/add_post_screen.dart';
import 'package:social_sphere/features/post/screens/add_post_type_screen.dart';
import 'package:social_sphere/features/post/screens/add_post_media_screen.dart';
import 'package:social_sphere/features/post/screens/comments_screen.dart';
import 'package:social_sphere/features/user_profile/screens/edit_profile_screen.dart';
import 'package:social_sphere/features/user_profile/screens/user_profile_screen.dart';
import 'package:social_sphere/features/notification/screens/notification_screen.dart';
import 'package:routemaster/routemaster.dart';

/// This file contains the route maps for the application.

final loggedOutRoute = RouteMap(
  routes: {'/': (_) => const MaterialPage(child: LoginScreen())},
);

final loggedInRoute = RouteMap(
  routes: {
    // Main screens
    '/': (_) => const MaterialPage(child: HomeScreen()),
    '/notifications': (_) => const MaterialPage(child: NotificationScreen()),
    '/chats': (_) => const MaterialPage(child: ChatListScreen()),

    // Community routes
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

    // User profile routes
    '/u/:uid':
        (routeData) => MaterialPage(
          child: UserProfileScreen(uid: routeData.pathParameters['uid']!),
        ),
    '/edit-profile/:uid':
        (routeData) => MaterialPage(
          child: EditProfileScreen(uid: routeData.pathParameters['uid']!),
        ),

    // Post routes
    '/add-post': (_) => const MaterialPage(child: AddPostScreen()),
    '/add-post/:type': (routeData) {
      final type = routeData.pathParameters['type']!;
      if (type == 'image') {
        return const MaterialPage(child: AddPostMediaScreen(type: 'image'));
      }
      return MaterialPage(
        child: AddPostTypeScreen(type: routeData.pathParameters['type']!),
      );
    },
    '/post/:postId/comments':
        (route) => MaterialPage(
          child: CommentsScreen(postId: route.pathParameters['postId']!),
        ),

    // Chat routes
    '/chat/:uid':
        (route) => MaterialPage(
          child: ChatScreen(receiverId: route.pathParameters['uid']!),
        ),
  },
);
