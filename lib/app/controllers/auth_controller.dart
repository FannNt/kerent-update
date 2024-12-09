import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/models/user.dart';
import '../services/auth_service.dart';
class AuthController extends GetxController {


  final formKey = GlobalKey<FormState>();
  final phoneNumberController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get currentUser => _auth.currentUser;
  final AuthService _authService = Get.find<AuthService>();

  RxBool isLoading = false.obs;
  Rx<User?> get user => _authService.user;
  Rx<String?> get uid => _authService.userUid.obs;
  
  final Rx<String> displayName = ''.obs;
  final Rx<String> phoneNumber = ''.obs;
  final Rx<String> email = ''.obs;
  final Rx<String> image = ''.obs;
  final Rx<String> classOrPosition = ''.obs;
  final Rx<String> description = ''.obs;
  
  @override
  void onClose() {
    phoneNumberController.dispose();
    updateUserOnlineStatus(false);
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
  loadUserData();
 }

  Future<void> signOut()async{
  await _authService.signOut();
  Get.delete<AuthController>();
  }

  @override
  void onInit() {
    super.onInit();
    updateUserOnlineStatus(true);
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
          // Update both Firebase Auth and local state
          final username = userData.data()?['username'] ?? '';
          displayName.value = username;
          
          // Update Firebase Auth display name if it's different
          if (user.displayName != username) {
            await user.updateDisplayName(username);
          }
          
          // Update other user data
          phoneNumber.value = userData.data()?['phoneNumber'] ?? '';
          email.value = userData.data()?['email'] ?? '';
          image.value = userData.data()?['profileImageUrl'] ?? '';
          
          // Force UI update
          update();
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

  void updateUserOnlineStatus(bool isOnline) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<UserModel> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;
      
      // Create the user document with all required fields
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'username': user.displayName ?? email.split('@')[0], // or any default username logic
        'phoneNumber': '',
        'lastSignInTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'isEmailVerified': false,
        'profileImageUrl': '',
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
        'userPreferences': {
          'notifications': false,
          'theme': '',
        },
      });
      loadUserData();
      // Create the user model
      return UserModel(
        uid: user.uid,
        email: email,
        username: user.displayName ?? email.split('@')[0],
        isEmailVerified: false,
        isOnline: true,
      );
    } catch (e) {
      print('Error in createUserWithEmailAndPassword: $e');
      rethrow;
    }
  }

  void clearUserData() {
    displayName.value = '';
    phoneNumber.value = '';
    email.value = '';
    image.value = '';
    classOrPosition.value = '';
    description.value = '';
  }

}
