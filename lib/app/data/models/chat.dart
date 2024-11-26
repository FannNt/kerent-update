import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String content;
  final String senderId;
  final String senderName;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
  });

  factory ChatMessage.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      content: data['content'],
      senderId: data['senderId'],
      senderName: data['senderName'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}

class ChatUser {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime lastMessageTimestamp;

  ChatUser({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTimestamp,
  });

  factory ChatUser.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatUser(
      id: doc.id,
      name: data['name'],
      lastMessage: data['lastMessage'],
      lastMessageTimestamp: (data['lastMessageTimestamp'] as Timestamp).toDate(),
    );
  }
}

class PrivateChatMessage {
  final String id;
  final String content;
  final String senderId;
  final String senderName;
  final DateTime timestamp;

  PrivateChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
  });

  factory PrivateChatMessage.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PrivateChatMessage(
      id: doc.id,
      content: data['content'],
      senderId: data['senderId'],
      senderName: data['senderName'] ?? 'asd',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}

class PrivateChatUser {
  final String uid;
  final String name;

  PrivateChatUser({this.uid = '', this.name = ''});

  factory PrivateChatUser.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PrivateChatUser(
      uid: doc.id,
      name: data['username'] ?? 'kjnkj',
    );
  }
}
