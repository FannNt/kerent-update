import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Check if user is logged in
    if (FirebaseAuth.instance.currentUser != null) {
      // User is logged in, redirect to main menu
      return const RouteSettings(name: '/main-menu');
    } else {
      // User is not logged in, redirect to login
      return const RouteSettings(name: '/login');
    }
  }
} 