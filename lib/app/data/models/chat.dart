import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String? id;
  final List<String> users;
  final List<String> usernames;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String lastSenderId;

  Chat({
    this.id,
    required this.users,
    required this.usernames,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.lastSenderId,
  });

  factory Chat.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Chat(
      id: doc.id,
      users: List<String>.from(data['users'] ?? []),
      usernames: List<String>.from(data['usernames'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCount: data['unreadCount'] ?? 0,
      lastSenderId: data['lastSenderId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'users': users,
      'usernames': usernames,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'unreadCount': unreadCount,
      'lastSenderId': lastSenderId,
    };
  }
}
