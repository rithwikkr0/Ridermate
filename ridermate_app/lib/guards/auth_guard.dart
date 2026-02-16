import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../screens/login_page.dart';
import '../screens/home_screen.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  AuthGuard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          return child;
        } else {
          return LoginPage();
        }
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading while checking auth state
        if (authProvider.firebaseUser == null && authProvider.userProfile == null) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0066FF),
              ),
            ),
          );
        }

        // Show main app if authenticated
        if (authProvider.isAuthenticated) {
          return HomeScreen();
        }

        // Show login page if not authenticated
        return LoginPage();
      },
    );
  }
}
