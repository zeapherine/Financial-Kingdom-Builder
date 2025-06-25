import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/kingdom/presentation/screens/kingdom_screen.dart';
import '../../features/education/presentation/screens/education_screen.dart';
import '../../features/trading/presentation/screens/trading_screen.dart';
import '../../features/social/presentation/screens/social_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../shared/presentation/screens/home_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/kingdom',
        name: 'kingdom',
        builder: (context, state) => const KingdomScreen(),
      ),
      GoRoute(
        path: '/education',
        name: 'education',
        builder: (context, state) => const EducationScreen(),
      ),
      GoRoute(
        path: '/trading',
        name: 'trading',
        builder: (context, state) => const TradingScreen(),
      ),
      GoRoute(
        path: '/social',
        name: 'social',
        builder: (context, state) => const SocialScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});