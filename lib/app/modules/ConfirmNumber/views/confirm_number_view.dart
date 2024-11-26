import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';


class ConfirmNumberView extends GetView<AuthController> {
  const ConfirmNumberView({super.key});

  @override
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: controller.otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter OTP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : () {
                try {
                  controller.verifyOTP();
                } catch (e) {
                  print('Error during OTP verification: $e');
                  Get.snackbar('Error', 'Failed to verify OTP: $e');
                }
              },
              child: controller.isLoading.value
                ? const CircularProgressIndicator()
                : const Text('Verify OTP'),
            )),
          ],
        ),
      ),
    );
  }
}