import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ConfirmNumberController extends GetxController {
  final code = List.generate(6, (_) => '').obs;
  final formKey = GlobalKey<FormState>();
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
  final isLoading = false.obs;
  final canShowSnackbar = true.obs;

  @override
  void onClose() {
    for (var node in focusNodes) {
      node.dispose();
    }
    super.onClose();
  }

  void updateCode(int index, String value) {
    code[index] = value;
    if (value.length == 1 && index < 5) {
      focusNodes[index + 1].requestFocus();
    }
  }

  void submit() async {
    if (isLoading.value) return; // Prevent multiple submissions
    
    if (formKey.currentState!.validate()) {
      final submittedCode = code.join();
      if (submittedCode.length != 6 || submittedCode.contains('')) {
        _showSnackbar('Error', 'Please enter a valid 6-digit code.');
        return;
      }

      isLoading.value = true;
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Check if code is correct (replace with your actual validation logic)
      if (submittedCode == '123456') {
        _showSnackbar('Success', 'Code verified successfully');
        Get.toNamed("/menu");
      } else {
        _showSnackbar('Error', 'Invalid code. Please try again.');
      }

      isLoading.value = false;
    }
  }

  void _showSnackbar(String title, String message) {
    if (canShowSnackbar.value) {
      canShowSnackbar.value = false;
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      Future.delayed(const Duration(seconds: 3), () {
        canShowSnackbar.value = true;
      });
    }
  }
}