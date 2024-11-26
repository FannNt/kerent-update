import 'package:flutter/material.dart';
import 'package:get/get.dart';
import "../../../controllers/auth_controller.dart";


class ProfileView extends GetView<AuthController> {
  const ProfileView({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
        title: Obx(() => Text('Welcome')),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: controller.signOut,
          ),
        ],
      ),
      body: Text(' ${controller.user}'),
    );
  }
}
