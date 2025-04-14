

import 'package:routemaster/routemaster.dart';
import 'package:flutter/material.dart';
import 'package:social_sphere/features/auth/screens/login_screen.dart';

final loggedOutRoute = RouteMap(routes: {'/': (_)=>const MaterialPage(child: LoginScreen())});

