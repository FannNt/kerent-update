import 'package:cloud_firestore/cloud_firestore.dart';
import 'product.dart';

class RentRequest {
  final String id;
  final Product product;
  final String customerName;
  final String rentalDuration;
  final String customerClass;
  final int totalPrice;
  String status;
  final String customerId;
  final String productOwnerId;

  RentRequest({
    required this.id,
    required this.product,
    required this.customerName,
    required this.rentalDuration,
    required this.customerClass,
    required this.totalPrice,
    required this.status,
    required this.customerId,
    required this.productOwnerId,
  });

  // Convert Firestore document to RentRequest object
  factory RentRequest.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Get the product data
    Map<String, dynamic> productData = data['product'] as Map<String, dynamic>;
    
    return RentRequest(
      id: doc.id,
      product: Product.fromFirestore(productData),
      customerName: data['customerName'] ?? '',
      rentalDuration: data['rentalDuration'] ?? '',
      customerClass: data['customerClass'] ?? '',
      totalPrice: (data['totalPrice'] ?? 0).toInt(),
      status: data['status'] ?? 'Pending',
      customerId: data['customerId'] ?? '',
      productOwnerId: data['productOwnerId'] ?? '',
    );
  }

  // Convert RentRequest object to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'product': product.toFirestore(),
      'customerName': customerName,
      'rentalDuration': rentalDuration,
      'customerClass': customerClass,
      'totalPrice': totalPrice,
      'status': status,
      'customerId': customerId,
      'productOwnerId': productOwnerId,
    };
  }
}