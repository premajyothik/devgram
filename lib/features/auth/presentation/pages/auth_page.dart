import 'package:devgram/features/auth/presentation/pages/login_page.dart';
import 'package:devgram/features/auth/presentation/pages/signup_page.dart';
import 'package:flutter/material.dart';

// This is the main page for authentication, which can be used to navigate between login and signup pages.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLoginPage = true;
  void togglePage() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(togglePage: togglePage);
    } else {
      return SignupPage(togglePage: togglePage);
    }
  }
}
