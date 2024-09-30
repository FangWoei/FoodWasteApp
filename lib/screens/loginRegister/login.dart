import 'package:flutter/material.dart';
import 'package:flutter_project/data/services/auth_service.dart';
import 'package:flutter_project/main.dart';
import 'package:flutter_project/screens/home_screen.dart';
import 'package:flutter_project/screens/loginRegister/register.dart';
import 'package:go_router/go_router.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  static const routeName = "login";

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  String? emailError;
  String? passwordError;
  String? loginError;

  void _login() async {
    final email = emailController.text;
    final password = passwordController.text;

    setState(() {
      emailError = email.isEmpty ? 'Please enter your email' : null;
      passwordError = password.isEmpty ? 'Please enter your password' : null;
      loginError = null;
    });

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        await _authService.signInWithEmailAndPassword(email, password);
        context.pushNamed(HomeScreen.routeName);
      } catch (e) {
        setState(() {
          loginError = 'Login failed. Please check your email or password.';
        });
      }
    }
  }

  void _register() async {
    await context.pushNamed(Register.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Login"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Login",
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 30.0),
              child: SizedBox(
                width: 300,
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                      labelText: "Email",
                      errorText: emailError,
                      border: const OutlineInputBorder()),
                ),
              ),
            ),
            SizedBox(
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
            Container(
              margin: const EdgeInsets.fromLTRB(0, 50.0, 0, 20.0),
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue[400],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Login'),
              ),
            ),
            if (loginError != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  loginError!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.blue,
                ),
                child: const Text('Register',
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
