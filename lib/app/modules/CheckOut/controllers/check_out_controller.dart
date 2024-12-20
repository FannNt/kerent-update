import 'package:get/get.dart';
import '../../../data/models/product.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../chat/views/chat_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../profile/controllers/profile_controller.dart';
import '../../profile/views/profile_view.dart';

class CheckoutController extends GetxController {
  var currentIndex = 0.obs;
  late Rx<Product> product;
  RxBool isExpanded = false.obs;

  final List<String> imgList = [

  ];


  void toggleExpanded() {
    isExpanded.toggle();
  }

  String getDisplayedText(String content, int wordLimit) {
    List<String> words = content.split(' ');
    return isExpanded.value || words.length <= wordLimit
        ? content
        : words.take(wordLimit).join(' ') + '...';
  }

  void onCheckoutPressed() {
    // Implement checkout logic here
    Get.snackbar('Checkout', 'Processing your order...');
  }

  void onHomePressed() {
    // Implement home navigation logic here
    Get.offNamed('/main-menu');
  }

  void onChatPressed(String sellerId, String sellerName) async {
    try {
      final chatController = Get.put(ChatController());
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      
      // Fetch current seller username from Firestore
      final sellerDoc = await _firestore
          .collection('users')
          .doc(sellerId)
          .get();
      
      final currentSellerName = sellerDoc.data()?['username'] ?? 'Unknown Seller';
      
      final chatId = await chatController.createOrGetChat(
        sellerId,
        currentSellerName, // Use the current username from Firestore
      );
      
      if (chatId != null) {
        Get.to(() => MessagePage(
          recipientId: sellerId,
          recipientName: currentSellerName,
          chatId: chatId,
        ));
      }
    } catch (e) {
      print('Error starting chat: $e');
      Get.snackbar(
        'Error',
        'Failed to start chat',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void onAddPressed() {
    // Implement add item logic here
    Get.snackbar('Add Item', 'Adding new item...');
  }

  void navigateToSellerProfile(String sellerId) {
    print('Navigating to seller profile with ID: $sellerId');
    
    // First, delete existing controller
    Get.delete<ProfileController>(force: true);
    
    // Create new controller
    final profileController = Get.put(ProfileController());
    
    // Navigate with arguments
    Get.to(
      () => const PublicProfilePage(),
      arguments: {
        'userId': sellerId,
      },
      preventDuplicates: false,
    );
  }
}

