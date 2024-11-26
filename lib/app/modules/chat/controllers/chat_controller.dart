import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/chat.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Rx<PrivateChatUser> recipient = PrivateChatUser().obs;
  final RxList<PrivateChatMessage> messages = <PrivateChatMessage>[].obs;

  void setRecipient(PrivateChatUser user) {
    recipient.value = user;
    fetchMessages();
  }

  void fetchMessages() {
  final currentUserId = _auth.currentUser!.uid;
  final recipientId = recipient.value.uid;

  final chatId = currentUserId.compareTo(recipientId) < 0 
      ? '${currentUserId}_$recipientId' 
      : '${recipientId}_$currentUserId';

  _firestore.collection('private_chats')
    .where('chatId', isEqualTo: chatId)
    .orderBy('timestamp', descending: true)
    .limit(50)
    .snapshots()
    .listen((snapshot) {
      messages.value = snapshot.docs.map((doc) => PrivateChatMessage.fromDocument(doc)).toList();
    });
}

void sendMessage(String content) {
  final currentUserId = _auth.currentUser!.uid;
  final currentUserName = _auth.currentUser!.displayName;
  final recipientId = recipient.value.uid;

  // Create chatId in the same way as in fetchMessages
  final chatId = currentUserId.compareTo(recipientId) < 0 
      ? '${currentUserId}_$recipientId' 
      : '${recipientId}_$currentUserId';

  _firestore.collection('private_chats').add({
    'chatId': chatId,
    'content': content,
    'senderId': currentUserId,
    'senderName' : currentUserName,
    'recipientId': recipientId,
    'timestamp': FieldValue.serverTimestamp(),
  });
}
String generateChatId() {
    final currentUserId = _auth.currentUser!.uid;
    final recipientId =recipient.value.uid;
    return currentUserId.compareTo(recipientId) < 0 
        ? '${currentUserId}_$recipientId' 
        : '${recipientId}_$currentUserId';
  }

}
