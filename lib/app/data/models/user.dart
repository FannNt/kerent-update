import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String? phoneNumber;
  final DateTime? lastSignInTime;
  final DateTime? createdAt;
  final bool isEmailVerified;
  final String? profileImageUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.phoneNumber,
    this.lastSignInTime,
    this.createdAt,
    required this.isEmailVerified,
    this.profileImageUrl,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? 'New User',
      phoneNumber: data['phoneNumber'],
      lastSignInTime: (data['lastSignInTime'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      isEmailVerified: data['isEmailVerified'] ?? false,
      profileImageUrl: data['profileImageUrl'],
    );
  }
}