import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/payment.dart';
import '../../../data/models/product.dart';
import '../../../data/models/rentRequest.dart';
import '../../../services/payment_service.dart';

class PaymentController extends GetxController {
  final PaymentService _paymentService = PaymentService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final classController = TextEditingController();
  
  final RxString selectedDuration = '1 Day'.obs;
  final RxBool isLoading = false.obs;
  
  final List<String> durations = [
    '1 Day',
    '3 Days',
    '1 Week',
    '2 Weeks',
    '1 Month'
  ];

  // Calculate return date based on duration
  DateTime calculateReturnDate(String duration) {
    final now = DateTime.now();
    switch (duration) {
      case '1 Day':
        return now.add(Duration(days: 1));
      case '3 Days':
        return now.add(Duration(days: 3));
      case '1 Week':
        return now.add(Duration(days: 7));
      case '2 Weeks':
        return now.add(Duration(days: 14));
      case '1 Month':
        return now.add(Duration(days: 30));
      default:
        return now.add(Duration(days: 1));
    }
  }

  // Calculate rental amount based on duration and product price
  double calculateAmount(Product product, String duration) {
    final basePrice = product.price;
    switch (duration) {
      case '1 Day':
        return basePrice;
      case '3 Days':
        return basePrice * 3;
      case '1 Week':
        return basePrice * 7;
      case '2 Weeks':
        return basePrice * 14;
      case '1 Month':
        return basePrice * 30;
      default:
        return basePrice;
    }
  }

  void _resetForm() {
    nameController.clear();
    classController.clear();
    selectedDuration.value = '1 Day';
  }

  Future<void> createRental(Product product) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;
      
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final rentDate = DateTime.now();
      final returnDate = calculateReturnDate(selectedDuration.value);
      final amount = calculateAmount(product, selectedDuration.value);

      // Create Payment
      final payment = Payment(
        id: '',
        productId: product.id,
        productName: product.name,
        amount: amount,
        userId: user.uid,
        userName: nameController.text,
        userClass: classController.text,
        duration: selectedDuration.value,
        rentDate: rentDate,
        returnDate: returnDate,
        status: 'pending',
        createdAt: DateTime.now(),
        sellerId: product.seller,
      );

      await _paymentService.createPayment(payment);

      // Create RentRequest
      final rentRequest = RentRequest(
        id:'',
        product: product,
        customerName: nameController.text,
        rentalDuration: selectedDuration.value,
        customerClass: classController.text,
        totalPrice: amount.toInt(),
        status: 'Pending',
        customerId: user.uid,
        productOwnerId: product.sellerId,
      );

      // Add to Firestore
      await _firestore.collection('rentRequests').add({
        'product': {
          ...product.toFirestore(),
          'seller': product.seller,
        },
        'customerName': rentRequest.customerName,
        'rentalDuration': rentRequest.rentalDuration,
        'customerClass': rentRequest.customerClass,
        'totalPrice': rentRequest.totalPrice,
        'status': rentRequest.status,
        'customerId': rentRequest.customerId,
        'productOwnerId': rentRequest.productOwnerId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _resetForm(); // Reset the form

      Get.snackbar(
        'Success',
        'Rental request created successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      Get.offAllNamed('/main-menu'); 
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create rental request: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    classController.dispose();
    super.onClose();
  }
}