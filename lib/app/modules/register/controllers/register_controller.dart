import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email.value,
          password: password.value,
        );
        await _saveUserData(userCredential.user!, isNewUser: true);
        Get.snackbar('Success', 'Registration successful');
        Get.offAllNamed("/main-menu");
      } on FirebaseAuthException catch (e) {
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
        Get.snackbar('Error', errorMessage);
      } catch (e) {
        Get.snackbar('Error', 'Registration failed: $e');
      }
    }
  }

  Future<void> _saveUserData(User user, {required bool isNewUser}) async {
    try {
      final userData = {
        'username': username.value.isNotEmpty ? username.value : user.displayName ?? 'New User',
        'email': user.email ?? email.value,
        'phoneNumber': user.phoneNumber ?? phoneNumber.value,
        'lastSignInTime': FieldValue.serverTimestamp(),
        'isEmailVerified': user.emailVerified,
        'profileImageUrl': user.photoURL,
      };

      if (isNewUser) {
        userData['createdAt'] = FieldValue.serverTimestamp();
        userData['userPreferences'] = {
          'theme': '',
          'notifications': false
        };
      }

      await _firestore.collection('users').doc(user.uid).set(userData, SetOptions(merge: true));

      if (isNewUser && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      print('Error saving user data: $e');
      // Consider how you want to handle this error. You might want to show a snackbar or log it.
    }
  }
}