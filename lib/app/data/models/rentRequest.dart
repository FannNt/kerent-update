import 'package:cloud_firestore/cloud_firestore.dart';
import 'product.dart';

class RentRequest {
  final String id;
  final Product product;
  final String customerId;
  final String customerName;
  final String rentalDuration;
  final String customerClass;
  final int totalPrice;
  String status;
  final String productOwnerId;
  final bool isRated;
  final double? rating;
  final String? review;

  RentRequest({
    required this.id,
    required this.product,
    required this.customerId,
    required this.customerName,
    required this.rentalDuration,
    required this.customerClass,
    required this.totalPrice,
    required this.status,
    required this.productOwnerId,
    this.isRated = false,
    this.rating,
    this.review,
  });

  // Convert Firestore document to RentRequest object
  factory RentRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final productData = data['product'] as Map<String, dynamic>;
    
    // Ensure product ID is included in the product data
    productData['id'] = productData['id'] ?? data['productId'] ?? '';
    
    return RentRequest(
      id: doc.id,
      product: Product.fromFirestore(productData),
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      rentalDuration: data['rentalDuration'] ?? '',
      customerClass: data['customerClass'] ?? '',
      totalPrice: (data['totalPrice'] ?? 0).toInt(),
      status: data['status'] ?? 'Pending',
      productOwnerId: data['productOwnerId'] ?? '',
      isRated: data['isRated'] ?? false,
      rating: (data['rating'] ?? 0).toDouble(),
      review: data['review'],
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
      'isRated': isRated,
      'rating': rating,
      'review': review,
    };
  }
}