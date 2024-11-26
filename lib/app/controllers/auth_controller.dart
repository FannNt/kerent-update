import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../modules/ConfirmNumber/views/confirm_number_view.dart';
import '../../config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
class AuthController extends GetxController {


  final formKey = GlobalKey<FormState>();
  final phoneNumberController = TextEditingController();
  final otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;
  final AuthService _authService = Get.find<AuthService>();

  RxBool isLoading = false.obs;
  Rx<User?> get user => _authService.user;
  String? get displayName => _authService.currentUser?.displayName;
  String? get uid => _authService.currentUser?.uid;
  RxString image =''.obs;
  // Infobip credentials
  final String baseUrl = Config.baseUrl; //enter base url
  final String apiKey = Config.apiKey; //Enter api key

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

  String generateOTP() {
    return (100000 + Random().nextInt(900000)).toString();
  }
  
  Future<void> saveOTP(String otp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('otp', otp);
  }



  Future<void> sendOTP() async {
    print('sending otp');
    if (formKey.currentState == null) {
      print('formKey.currentState is null'); // Debug print
      return;
    } 
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        String otp = generateOTP();
        await sendSmsViaInfobip(phoneNumberController.text, otp);
        print('SMS sent via Infobip'); // Debug print
        await saveOTP(otp);
        print('otp saved: $otp');
        isLoading.value = false;
        print('Navigating to /confirm-otp'); // Debug print
        try {
          await Get.toNamed('/confirm-otp');
          print('Navigation completed successfully');
        } catch (navError) {
          print('Navigation error: $navError');
          // Fallback navigation
          Get.to(() => const ConfirmNumberView());
        }
      } catch (e, stackTrace) {
        print('Error in sendOTP: $e'); // Debug print
        print('Stack trace: $stackTrace');
        isLoading.value = false;
        Get.snackbar('Error', 'Failed to send OTP: ${e.toString()}');
      }
      }else{
          print('Form validation failed'); // Debug print
      }
    }
  Future<void> sendSmsViaInfobip(String phoneNumber, String otp) async {
    var url = Uri.parse('$baseUrl/sms/2/text/advanced');
    
    var headers = {
      'Authorization': 'App $apiKey',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    var body = jsonEncode({
      "messages": [
        {
          "destinations": [{"to": phoneNumber}],
          "from": "YourApp",
          "text": "Your OTP is: $otp"
        }
      ]
    });
    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode != 200) {
      throw Exception('Failed to send SMS: ${response.body}');
    }
  }

  Future<void> verifyOTP() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedOTP = prefs.getString('otp');
      print('Saved OTP: $savedOTP'); // Debug print
      print('Entered OTP: ${otpController.text}'); // Debug
      if (savedOTP == null) {
      throw Exception('No saved OTP found');
    }
      if (savedOTP == otpController.text) {
        isLoading.value = false;
        Get.offAllNamed('/profile');
      } else {
        throw Exception('Invalid OTP');
      }
    } catch (e) {
      print('Error in verifyOTP: $e');
      isLoading.value = false;
      Get.snackbar('Error', 'Invalid OTP');
    }
  }
 Future<void> signInWithGoogle() async {  
  await _authService.signInWithGoogle();
 }

  Future<void> signOut()async{
    await _authService.signOut();
  }
}
