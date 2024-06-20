import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/dashboard.dart';
import '../starter.dart';
import 'routing_config.dart';
import 'services.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
    navigatorKey: rootNavigatorKey,
    redirect: (context, state) {
      Services.instance.searchCtrl.text = '';
      if (state.fullPath == '/') return null;
      if (['/login', '/signup'].contains(state.fullPath)) {
        return null;
      }
      if (Services.token == null || Services.user == null) return '/login';
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
          path: '/',
          name: AppRouteConstants.starter,
          parentNavigatorKey: rootNavigatorKey,
          builder: (BuildContext context, GoRouterState state) {
            return const SplashScreen();
          }),
      GoRoute(
          path: '/init',
          name: AppRouteConstants.init,
          parentNavigatorKey: rootNavigatorKey,
          builder: (BuildContext context, GoRouterState state) {
            return Container(child: const Text('Init Page'));
          }),
      GoRoute(
          path: '/login',
          name: AppRouteConstants.login,
          parentNavigatorKey: rootNavigatorKey,
          builder: (BuildContext context, GoRouterState state) {
            return Container(child: const Text('Login'));
          }),
      GoRoute(
          path: '/signup',
          name: AppRouteConstants.signUp,
          parentNavigatorKey: rootNavigatorKey,
          builder: (BuildContext context, GoRouterState state) {
            return Container(child: const Text('Sign Up'));
          }),
      ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return Container(child: child);
          },
          routes: <RouteBase>[
            GoRoute(
                path: '/dashboard',
                name: AppRouteConstants.dashboard,
                builder: (BuildContext context, GoRouterState state) {
                  return DashboardPage(key: Key(DateTime.now().toString()));
                }),
            GoRoute(
                path: '/profil',
                name: AppRouteConstants.profil,
                builder: (BuildContext context, GoRouterState state) {
                  return Container(child: const Text('Profil'));
                })
          ])
    ]);
