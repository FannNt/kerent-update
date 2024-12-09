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

  final userName = ''.obs;
  final userClass = ''.obs;
  final amount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        userName.value = userData['username'] ?? '';
        userClass.value = userData['classOrPosition'] ?? '';
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

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
    try {
      isLoading.value = true;
      
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final rentDate = DateTime.now();
      final returnDate = calculateReturnDate(selectedDuration.value);
      final amount = calculateAmount(product, selectedDuration.value);

      // Create Payment document data
      final paymentData = {
        'productId': product.id,
        'productName': product.name,
        'amount': amount,
        'userId': user.uid,
        'userName': userName.value,
        'userClass': userClass.value,
        'duration': selectedDuration.value,
        'rentDate': rentDate,
        'returnDate': returnDate,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'sellerId': product.sellerId,
      };

      // Log the payment data for debugging
      print('Creating payment with data: $paymentData');

      // Create payment document
      final paymentRef = await _firestore.collection('payments').add(paymentData);
      print('Payment created with ID: ${paymentRef.id}');

      // Create RentRequest document data
      final rentRequestData = {
        'product': {
          ...product.toFirestore(),
          'id': product.id,
          'seller': product.seller,
        },
        'productId': product.id,
        'customerName': userName.value,
        'rentalDuration': selectedDuration.value,
        'customerClass': userClass.value,
        'totalPrice': amount.toInt(),
        'status': 'Pending',
        'customerId': user.uid,
        'productOwnerId': product.sellerId,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Log the rent request data
      print('Creating RentRequest with data: $rentRequestData');

      // Create rent request document
      await _firestore.collection('rentRequests').add(rentRequestData);

      // Update product availability
      await _firestore.collection('products').doc(product.id).update({
        'isAvailable': false,
        'currentRenter': user.uid,
        'lastRentDate': FieldValue.serverTimestamp(),
      });

      _resetForm();

      Get.snackbar(
        'Success',
        'Rental request created successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      Get.offAllNamed('/main-menu'); 
    } catch (e) {
      print('Error creating rental: $e'); // Detailed error logging
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