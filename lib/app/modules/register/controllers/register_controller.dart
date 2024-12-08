import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../controllers/auth_controller.dart';

class RegisterController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final formKey = GlobalKey<FormState>();
  
  final username = ''.obs;
  final email = ''.obs;
  final phoneNumber = ''.obs;
  final password = ''.obs;
  final confirmPassword = ''.obs;

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      await _saveUserData(userCredential.user!, isNewUser: userCredential.additionalUserInfo?.isNewUser ?? false);
      Get.offAllNamed("/main-menu");
      Get.snackbar('Success', 'Signed in with Google');
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign in with Google: $e');
    }
  }

  Future<void> signInWithPhone() async {
    // Implement phone authentication logic here
    // This typically involves sending an OTP and verifying it
    Get.snackbar('Info', 'Phone authentication not implemented in this example');
  }

  String? validateField(String? value, bool isPassword, bool isConfirmPassword, bool isEmail) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (isPassword) {
      if (value.length < 8) {
        return 'Password must be at least 8 characters';
      }
    }
    if (isConfirmPassword && value != password.value) {
      return 'Passwords do not match';
    }
    if (isEmail && !GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  Future<void> register() async {
    if (formKey.currentState!.validate()) {
      try {
        print('Starting registration process...'); // Debug print
        print('Username: ${username.value}'); // Debug print
        print('Email: ${email.value}'); // Debug print
        print('Phone: ${phoneNumber.value}'); // Debug print

        // Show loading indicator
        Get.dialog(
          const Center(
            child: CircularProgressIndicator(),
          ),
          barrierDismissible: false,
        );

        // Create user in Firebase Auth
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email.value,
          password: password.value,
        );

        print('User created in Firebase Auth'); // Debug print

        // Prepare user data for Firestore
        final userData = {
          'username': username.value,
          'email': email.value,
          'phoneNumber': phoneNumber.value,
          'createdAt': FieldValue.serverTimestamp(),
          'lastSignInTime': FieldValue.serverTimestamp(),
          'isEmailVerified': userCredential.user?.emailVerified ?? false,
          'profileImageUrl': userCredential.user?.photoURL ?? '',
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
          'userPreferences': {
            'theme': '',
            'notifications': false
          }
        };

        print('Saving user data to Firestore...'); // Debug print

        // Save to Firestore
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userData);

        print('User data saved to Firestore'); // Debug print

        // Update display name in Firebase Auth
        await userCredential.user!.updateDisplayName(username.value);

        print('Display name updated in Firebase Auth'); // Debug print

        // Update AuthController
        final authController = Get.find<AuthController>();
        authController.updateUserData(
          displayName: username.value,
          phoneNumber: phoneNumber.value,
          email: email.value,
          image: userCredential.user?.photoURL ?? '',
        );

        print('AuthController updated'); // Debug print

        // Close loading dialog
        Get.back();

        // Show success message and navigate
        Get.snackbar(
          'Success',
          'Registration successful',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        Get.offAllNamed("/main-menu");
      } on FirebaseAuthException catch (e) {
        // Close loading dialog
        Get.back();
        
        String errorMessage;
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'The password provided is too weak.';
            break;
          case 'email-already-in-use':
            errorMessage = 'The account already exists for that email.';
            break;
          default:
            errorMessage = 'An error occurred during registration: ${e.message}';
        }
        print('Firebase Auth Error: ${e.code} - $errorMessage'); // Debug print
        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } catch (e) {
        // Close loading dialog
        Get.back();
        
        print('General Error: $e'); // Debug print
        Get.snackbar(
          'Error',
          'Registration failed: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      print('Form validation failed'); // Debug print
      Get.snackbar(
        'Error',
        'Please fill all required fields correctly',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _saveUserData(User user, {required bool isNewUser}) async {
    try {
      final userData = {
        'username': username.value.isNotEmpty ? username.value : user.displayName ?? 'New User',
        'email': user.email ?? email.value,
        'phoneNumber': phoneNumber.value,
        'lastSignInTime': FieldValue.serverTimestamp(),
        'isEmailVerified': user.emailVerified,
        'profileImageUrl': user.photoURL,
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
      };

      if (isNewUser) {
        userData['createdAt'] = FieldValue.serverTimestamp();
        userData['userPreferences'] = {
          'theme': '',
          'notifications': false
        };
      }

      // Save to Firestore
      await _firestore.collection('users').doc(user.uid).set(
        userData,
        SetOptions(merge: true)
      );

      // Update AuthController with the new user data
      final authController = Get.find<AuthController>();
      authController.updateUserData(
        displayName: username.value,
        phoneNumber: phoneNumber.value,
        email: user.email ?? email.value,
        image: user.photoURL ?? '',
      );

      if (isNewUser && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      print('Error saving user data: $e');
      Get.snackbar('Error', 'Failed to save user data');
    }
  }
}