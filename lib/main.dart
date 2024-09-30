import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/data/model/food.dart';
import 'package:flutter_project/screens/add/add.dart';
import 'package:flutter_project/screens/food/food_info.dart';
import 'package:flutter_project/screens/home_screen.dart';
import 'package:flutter_project/screens/loginRegister/login.dart';
import 'package:flutter_project/screens/loginRegister/register.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_project/data/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Food Waste App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const AuthWrapper();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'login',
          name: Login.routeName,
          builder: (BuildContext context, GoRouterState state) {
            return const Login();
          },
        ),
        GoRoute(
          path: 'register',
          name: Register.routeName,
          builder: (BuildContext context, GoRouterState state) {
            return const Register();
          },
        ),
        GoRoute(
          path: 'home',
          name: HomeScreen.routeName,
          builder: (BuildContext context, GoRouterState state) {
            return const HomeScreen();
          },
        ),
        GoRoute(
          path: 'add',
          name: Add.routeName,
          builder: (BuildContext context, GoRouterState state) {
            return const Add();
          },
        ),
        GoRoute(
          path: 'food_info',
          name: FoodInfo.routeName,
          builder: (BuildContext context, GoRouterState state) {
            return FoodInfo(food: state.extra as Food);
          },
        )
      ],
    ),
  ],
);

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          return const Login();
        }
      },
    );
  }
}
