import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth_service.dart';
class AuthController extends GetxController {


  final formKey = GlobalKey<FormState>();
  final phoneNumberController = TextEditingController();
  final otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get currentUser => _auth.currentUser;
  final AuthService _authService = Get.find<AuthService>();

  RxBool isLoading = false.obs;
  Rx<User?> get user => _authService.user;
  final Rx<String> displayName = ''.obs;
  final Rx<String> phoneNumber = ''.obs;
  final Rx<String> email = ''.obs;
  final Rx<String> image = ''.obs;

  @override
  void onClose() {
    phoneNumberController.dispose();
    otpController.dispose();
    super.onClose();
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (!value.contains(RegExp(r'^[0-9]+$'))) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

 Future<void> signInWithGoogle() async {  
  await _authService.signInWithGoogle();
 }

  Future<void> signOut()async{
    await _authService.signOut();
  }

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userData = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (userData.exists) {
          updateUserData(
            displayName: userData.data()?['username'] ?? '',
            phoneNumber: userData.data()?['phoneNumber'] ?? '',
            email: userData.data()?['email'] ?? '',
            image: userData.data()?['profileImageUrl'] ?? '',
          );
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  void updateUserData({
    required String displayName,
    required String phoneNumber,
    required String email,
    required String image,
  }) {
    this.displayName.value = displayName;
    this.phoneNumber.value = phoneNumber;
    this.email.value = email;
    this.image.value = image;
  }
}
