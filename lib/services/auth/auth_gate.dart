import 'package:chatapp/pages/home_page.dart';
import 'package:chatapp/services/auth/login_or_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Show loading indicator while waiting for the auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle error scenarios gracefully
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Something went wrong: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // User is authenticated
          if (snapshot.hasData) {
            return const HomePage();
          }

          // User is not logged in (show registration or login page)
          return const LoginOrRegister();
        },
      ),
    );
  }
}
