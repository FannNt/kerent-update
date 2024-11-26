import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String id;
  final String productId;
  final String productName;
  final double amount;
  final String userId;
  final String userName;
  final String userClass;
  final String duration;
  final DateTime rentDate;
  final DateTime returnDate;
  final String status; 
  final DateTime createdAt;
  final String sellerId;

  Payment({
    required this.id,
    required this.productId,
    required this.productName,
    required this.amount,
    required this.userId,
    required this.userName,
    required this.userClass,
    required this.duration,
    required this.rentDate,
    required this.returnDate,
    required this.status,
    required this.createdAt, 
    required this.sellerId,
  });

  factory Payment.fromMap(Map<String, dynamic> map, String id) {
    return Payment(
      id: id,
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userClass: map['userClass'] ?? '',
      duration: map['duration'] ?? '',
      rentDate: (map['rentDate'] as Timestamp).toDate(),
      returnDate: (map['returnDate'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(), 
      sellerId: map['sellerId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'amount': amount,
      'userId': userId,
      'userName': userName,
      'userClass': userClass,
      'duration': duration,
      'rentDate': rentDate,
      'returnDate': returnDate,
      'status': status,
      'createdAt': createdAt,
      'sellerId': sellerId,
    };
  }
}