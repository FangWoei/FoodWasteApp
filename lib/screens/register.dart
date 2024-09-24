import 'package:flutter/material.dart';
import 'package:flutter_project/data/repo/user_repo.dart';
import 'package:flutter_project/screens/home_screen.dart';
import 'package:flutter_project/screens/login.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_project/data/model/user.dart' as model;

class Register extends StatefulWidget {
  const Register({super.key});
  static const routeName = "register";

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController conPasswordController = TextEditingController();

  String? nameError;
  String? emailError;
  String? passwordError;
  String? conPasswordError;
  String? registerError;

  void _register() async {
    final name = nameController.text;
    final email = emailController.text;
    final password = passwordController.text;
    final conPassword = conPasswordController.text;

    setState(() {
      nameError = name.isEmpty ? 'Please enter your username' : null;

      final emailRegex =
          RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (email.isEmpty) {
        emailError = 'Please enter your email';
      } else if (!emailRegex.hasMatch(email)) {
        emailError = 'Please enter a valid email';
      } else {
        emailError = null;
      }

      if (password.isEmpty) {
        passwordError = 'Please enter your password';
      } else if (password.length < 8) {
        passwordError = 'Password must be at least 8 characters long';
      } else {
        passwordError = null;
      }
      conPasswordError = conPassword != password
          ? 'Your Confirm Password and Password do not match'
          : null;
    });

    if (name.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        conPassword == password) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        final userRepo = UserRepo();
        final user = model.User(
          userId: userCredential.user!.uid,
          name: name,
          email: email,
        );
        await userRepo.createUser(user);

        context.pushNamed(HomeScreen.routeName);
      } catch (e) {
        if (e is FirebaseAuthException) {
          if (e.code == 'email-already-in-use') {
            setState(() {
              registerError =
                  'This email is already registered. Please try logging in.';
            });
          } else {
            print('Registration failed: ${e.message}');
          }
        } else {
          print('An unknown error occurred: $e');
        }
      }
    }
  }

  void _login() async {
    await context.pushNamed(Login.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Register",
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 10.0),
              child: SizedBox(
                width: 300,
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                      labelText: "Username",
                      errorText: nameError,
                      border: const OutlineInputBorder()),
                ),
              ),
            ),
            SizedBox(
              width: 300,
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                    labelText: "Email",
                    errorText: emailError,
                    border: const OutlineInputBorder()),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
              child: SizedBox(
                width: 300,
                child: TextField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: InputDecoration(
                      labelText: "Password",
                      errorText: passwordError,
                      border: const OutlineInputBorder()),
                ),
              ),
            ),
            SizedBox(
              width: 300,
              child: TextField(
                obscureText: true,
                controller: conPasswordController,
                decoration: InputDecoration(
                    labelText: "Confirm Password",
                    errorText: conPasswordError,
                    border: const OutlineInputBorder()),
              ),
            ),
            if (registerError != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  registerError!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 10.0, 0, 10.0),
              child: ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue[400],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Register'),
              ),
            ),
            ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.blue,
                ),
                child: const Text('Login',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue,
                    )))
          ],
        ),
      ),
    );
  }
}
