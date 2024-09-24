import 'package:flutter/material.dart';
import 'package:flutter_project/data/services/auth_service.dart';
import 'package:flutter_project/screens/loginRegister/login.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const routeName = "home";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              context.pushNamed(Login.routeName);
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome! 123'),
      ),
    );
  }
}
