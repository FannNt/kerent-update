import 'package:flutter/material.dart';

import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';

class SignInPhoneView extends GetView<AuthController> {
   const SignInPhoneView({super.key});
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildTitle(),
              const SizedBox(height: 16),
              _buildSubtitle(),
              const SizedBox(height: 16),
              _buildPhoneNumberField(),
              const SizedBox(height: 30),
              _buildNextButton(),
              const SizedBox(height: 16),
              _buildTermsText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Continue with Phone',
      style: TextStyle(
        color: Color(0xFF191919),
        fontSize: 20,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSubtitle() {
    return const Opacity(
      opacity: 0.50,
      child: Text(
        'Sign in or sign up with your phone number.',
        style: TextStyle(
          color: Color(0xFF191919),
          fontSize: 16,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPhoneNumberField() {
    return TextFormField(
      controller: controller.phoneNumberController,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        hintText: 'Phone Number',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(9)),
        ),
      ),
      validator: (value) => controller.validatePhoneNumber(value),
    );
  }

  Widget _buildNextButton() {
    return Center(
      child: Obx(() => ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(320, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: const Color(0xFF191919),
        ),
        onPressed: controller.isLoading.value ? null : controller.sendOTP,
        child: controller.isLoading.value
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Send OTP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
      )),
    );
  }

  Widget _buildTermsText() {
    return const Center(
      child: Text(
        'By continuing, you agree to our Terms of Service and Privacy Policy',
        style: TextStyle(fontSize: 12),
      ),
    );
  }
}