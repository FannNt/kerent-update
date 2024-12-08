import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/chat.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final RxList<Chat> chats = <Chat>[].obs;
  final RxBool isLoading = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadChats();
  }

  Future<void> loadChats() async {
    try {
      isLoading.value = true;
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      // Listen to chats where current user is involved
      _firestore
          .collection('chats')
          .where('users', arrayContains: currentUserId)
          .snapshots()
          .listen((snapshot) {
        chats.value = snapshot.docs
            .map((doc) => Chat.fromDocument(doc))
            .toList()
          ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      });
    } catch (e) {
      print('Error loading chats: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage(String chatId, String message) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'senderId': currentUserId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update last message in chat document
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<String?> createOrGetChat(String otherUserId, String otherUsername) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return null;

      // Get current username from Firestore
      final currentUserDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();
      
      final currentUsername = currentUserDoc.data()?['username'] ?? 'Unknown User';

      // Check if chat already exists
      final querySnapshot = await _firestore
          .collection('chats')
          .where('users', arrayContains: currentUserId)
          .get();

      for (var doc in querySnapshot.docs) {
        List<String> users = List<String>.from(doc['users']);
        if (users.contains(otherUserId)) {
          // Update usernames in case they've changed
          await doc.reference.update({
            'usernames': [currentUsername, otherUsername]
          });
          return doc.id;
        }
      }

      // Create new chat if it doesn't exist
      final chatDoc = await _firestore.collection('chats').add({
        'users': [currentUserId, otherUserId],
        'usernames': [currentUsername, otherUsername],
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': 0,
      });

      return chatDoc.id;
    } catch (e) {
      print('Error creating/getting chat: $e');
      return null;
    }
  }

  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
