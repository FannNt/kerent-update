import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../controllers/auth_controller.dart';
import '../../../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  final email = ''.obs;
  final password = ''.obs;

  Rx<User?> user = Rx<User?>(null);

  Future<void> initializeAuth() async {
    await Future.delayed(Duration(seconds: 2)); // Simulated delay, remove in production
    user.value = _auth.currentUser;
  }

  @override
  void onInit() {
    super.onInit();
    ever(user, _handleAuthChanged);
    user.bindStream(_auth.authStateChanges());
  }

  void _handleAuthChanged(User? user) {
    if (user == null) {
      Get.offAllNamed('/home');
    } else {
      Get.offAllNamed('/main-menu');
    }
  }


  Future<void> login() async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.value,
        password: password.value,
      );
      await _authService.saveUserData(userCredential.user!);
      await updateOnlineStatus(true);
      
      // Load user data after successful login
      await Get.find<AuthController>().loadUserData();
      
      Get.offAllNamed('/main-menu');
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Error',
        e.message ?? 'An error occurred during login',
      );
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _authService.signInWithGoogle();
      // Load user data after successful Google sign-in
      await Get.find<AuthController>().loadUserData();
      Get.offAllNamed('/main-menu');
    } catch (e) {
      print('Error signing in with Google: $e');
    }
  }

  Future<void> resetPassword() async {
    if (email.value.isNotEmpty) {
      try {
        await _auth.sendPasswordResetEmail(email: email.value);
        Get.snackbar(
          'Success',
          'Password reset email sent. Check your inbox.',
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to send password reset email: $e',
        );
      }
    } else {
      Get.snackbar(
        'Error',
        'Please enter your email address',
      );
    }
  }

  Future<void> logout() async {
    await updateOnlineStatus(false);
    await _authService.signOut();
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> updateOnlineStatus(bool isOnline) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  void onClose() {
    updateOnlineStatus(false);
    super.onClose();
  }
}