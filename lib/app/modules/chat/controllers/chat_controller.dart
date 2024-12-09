import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/chat.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final RxList<Chat> chats = <Chat>[].obs;
  final RxBool isLoading = true.obs;
  final RxList<Map<String, dynamic>> onlineUsers = <Map<String, dynamic>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadChats();
    loadOnlineUsers();
    updateUserOnlineStatus(true); // Set user as online when app starts
  }

  @override
  void onClose() {
    updateUserOnlineStatus(false); // Set user as offline when controller is closed
    super.onClose();
  }

  Future<void> loadChats() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      // Listen to real-time chat updates
      _firestore
          .collection('chats')
          .where('users', arrayContains: currentUserId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isEmpty) {
          chats.value = [];
          isLoading.value = false;
          return;
        }

        chats.value = snapshot.docs.map((doc) {
          final data = doc.data();
          // Ensure lastMessageTime exists
          if (!data.containsKey('lastMessageTime') || data['lastMessageTime'] == null) {
            // Update the chat document with a timestamp if it's missing
            doc.reference.update({
              'lastMessageTime': FieldValue.serverTimestamp(),
            });
          }
          return Chat.fromDocument(doc);
        }).toList();

        isLoading.value = false;
      }, onError: (error) {
        print('Error loading chats: $error');
        isLoading.value = false;
      });
    } catch (e) {
      print('Error in loadChats: $e');
      isLoading.value = false;
    }
  }

  Future<void> sendMessage(String chatId, String message) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      // Add message to subcollection
      await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'senderId': currentUserId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // Update chat document
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderId': currentUserId,
        'unreadCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<String?> createOrGetChat(String otherUserId, String otherUsername) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return null;

      // Get current user's username
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

      // Find existing chat
      for (var doc in querySnapshot.docs) {
        List<String> users = List<String>.from(doc['users']);
        if (users.contains(otherUserId)) {
          // Get the correct order of usernames based on users array
          List<String> usernames = [];
          for (String userId in users) {
            if (userId == currentUserId) {
              usernames.add(currentUsername);
            } else {
              usernames.add(otherUsername);
            }
          }
          
          // Update usernames in the same order as users
          await doc.reference.update({
            'usernames': usernames
          });
          return doc.id;
        }
      }

      // Create new chat if it doesn't exist
      final users = [currentUserId, otherUserId];
      final usernames = [currentUsername, otherUsername];
      
      final chatDoc = await _firestore.collection('chats').add({
        'users': users,
        'usernames': usernames,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': 0,
        'lastSenderId': '',
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

  Stream<List<Chat>> getChats() {
    return _firestore.collection('chats')
        .where('users', arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Chat.fromDocument(doc)).toList();
        });
  }

  void loadOnlineUsers() {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      // Listen to online users
      _firestore
          .collection('users')
          .where('isOnline', isEqualTo: true)
          .snapshots()
          .listen((snapshot) {
            onlineUsers.value = snapshot.docs
                .where((doc) => doc.id != currentUserId) // Exclude current user
                .map((doc) {
                  final data = doc.data();
                  return {
                    'uid': doc.id,
                    'username': data['username'] ?? 'Unknown',
                    'photoURL': data['photoURL'] ?? '',
                    'lastSeen': data['lastSeen'],
                    'isOnline': data['isOnline'] ?? false,
                  };
                })
                .toList();
            }, onError: (error) {
              print('Error loading online users: $error');
            });
    } catch (e) {
      print('Error in loadOnlineUsers: $e');
    }
  }

  // Add method to update user online status
  Future<void> updateUserOnlineStatus(bool isOnline) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      await _firestore.collection('users').doc(currentUserId).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating online status: $e');
    }
  }

  Future<void> markChatAsRead(String chatId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      // Get chat document
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      final chatData = chatDoc.data();

      // Only reset unread count if the last message was sent by the other user
      if (chatData != null && chatData['lastSenderId'] != currentUserId) {
        await _firestore.collection('chats').doc(chatId).update({
          'unreadCount': 0,
        });

        // Mark all messages as read
        final messages = await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .where('isRead', isEqualTo: false)
            .where('senderId', isNotEqualTo: currentUserId)
            .get();

        final batch = _firestore.batch();
        for (var doc in messages.docs) {
          batch.update(doc.reference, {'isRead': true});
        }
        await batch.commit();
      }
    } catch (e) {
      print('Error marking chat as read: $e');
    }
  }
}
