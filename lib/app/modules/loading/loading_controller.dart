import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoadingController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    print('LoadingController initialized'); // Debug print
    checkAuth();
  }

  Future<void> checkAuth() async {
    try {
      // Wait for animation
      await Future.delayed(const Duration(seconds: 3));
      
      print('Checking auth state...'); // Debug print
      final user = _auth.currentUser;
      print('Current user: ${user?.uid}'); // Debug print

      if (user != null) {
        // User is logged in
        print('User is logged in, updating online status...'); // Debug print
        await _updateOnlineStatus(true);
        print('Navigating to main menu...'); // Debug print
        Get.offAllNamed('/main-menu');
      } else {
        // No user logged in
        print('No user logged in, navigating to login...'); // Debug print
        Get.offAllNamed('/login');
      }
    } catch (e) {
      print('Error in checkAuth: $e');
      // Default to login page on error
      Get.offAllNamed('/login');
    }
  }

  Future<void> _updateOnlineStatus(bool isOnline) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'isOnline': isOnline,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating online status: $e');
    }
  }

  @override
  void onClose() {
    _updateOnlineStatus(false);
    super.onClose();
  }
}
