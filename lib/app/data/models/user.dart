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
  final bool isOnline;
  final DateTime? lastSeen;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.phoneNumber,
    this.lastSignInTime,
    this.createdAt,
    required this.isEmailVerified,
    this.profileImageUrl,
    this.isOnline = false,
    this.lastSeen,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      username: data['username'],
      phoneNumber: data['phoneNumber'],
      lastSignInTime: (data['lastSignInTime'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      isEmailVerified: data['isEmailVerified'] ?? false,
      isOnline: data['isOnline'] ?? false,
      profileImageUrl: data['profileImageUrl'],
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
    );
  }

  String getLastSeenText() {
    if (isOnline) return 'Online';
    if (lastSeen == null) return 'Offline';

    final now = DateTime.now();
    final difference = now.difference(lastSeen!);

    if (difference.inSeconds < 60) {
      return 'Active just now';
    } else if (difference.inMinutes < 60) {
      return 'Active ${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return 'Active ${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return 'Active ${difference.inDays}d ago';
    } else {
      return 'Offline';
    }
  }
}