import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../navbar.dart';
import '../../../data/models/chat.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/chat_controller.dart';
import 'chat_view.dart';


// Model untuk hasil pencarian
class SearchResult {
  final String name;
  final Color color;
  final String? lastMessage;
  final String? time;
  final bool isProfile;

  SearchResult({
    required this.name,
    required this.color,
    this.lastMessage,
    this.time,
    required this.isProfile,
  });
}

// Controller untuk mengelola state dan logika
class ChatListController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RxList<Chat> chats = <Chat>[].obs;
  final RxList<Map<String, dynamic>> searchResults = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSearching = false.obs;
  final RxList<Map<String, dynamic>> onlineUsers = <Map<String, dynamic>>[].obs;
  @override
  void onInit() {
    super.onInit();
    loadChats();
    loadOnlineUsers();
  }

void loadOnlineUsers() {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      // First get all users this user has chatted with
      _firestore
          .collection('chats')
          .where('users', arrayContains: currentUserId)
          .snapshots()
          .listen((chatSnapshot) {
            // Extract all unique user IDs from chats
            Set<String> chatUserIds = {};
            for (var doc in chatSnapshot.docs) {
              List<String> users = List<String>.from(doc['users']);
              chatUserIds.addAll(users.where((id) => id != currentUserId));
            }

            // Now listen to online status of only these users
            if (chatUserIds.isNotEmpty) {
              _firestore
                  .collection('users')
                  .where('uid', whereIn: chatUserIds.toList())
                  .where('isOnline', isEqualTo: true)
                  .snapshots()
                  .listen(
                (snapshot) {
                  onlineUsers.value = snapshot.docs.map((doc) {
                    final data = doc.data();
                    return {
                      'uid': doc.id,
                      'displayName': data['displayName'] ?? 'Unknown',
                      'photoURL': data['photoURL'] ?? '',
                      'lastSeen': data['lastSeen'],
                    };
                  }).toList();
                },
              );
            }
          });
    } catch (e) {
      print('Error loading online users: $e');
    }
  }
  void loadChats() {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      // Listen to real-time chat updates
      _firestore
          .collection('chats')
          .where('users', arrayContains: currentUserId)
          .snapshots()
          .listen((snapshot) {
        chats.value = snapshot.docs
            .map((doc) => Chat.fromDocument(doc))
            .toList()
          ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
        isLoading.value = false;
      });
    } catch (e) {
      print('Error loading chats: $e');
      isLoading.value = false;
    }
  }

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      // Search users by displayName
      final querySnapshot = await _firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      searchResults.value = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'displayName': doc['displayName'] as String,
                'photoURL': doc['photoURL'] as String? ?? '',
              })
          .where((user) => user['id'] != _auth.currentUser?.uid) // Exclude current user
          .toList();
    } catch (e) {
      print('Error searching users: $e');
    }
  }

  Future<void> startNewChat(String userId, String username) async {
    try {
      final chatController = Get.find<ChatController>();
      final chatId = await chatController.createOrGetChat(userId, username);
      
      if (chatId != null) {
        Get.to(() => MessagePage(
          recipientId: userId,
          recipientName: username,
          chatId: chatId,
        ));
      }
    } catch (e) {
      print('Error starting new chat: $e');
    }
  }
}

class ChatListPage extends StatelessWidget {
  ChatListPage({super.key});

  final ChatListController chatController = Get.put(ChatListController());
  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Obx(() => chatController.isSearching.value
                ? _buildSearchBar()
                : const SizedBox.shrink()),
            const SizedBox(height: 16),
            _buildOnlineUsers(context),
            const SizedBox(height: 20),
            _buildChatsHeader(),
            _buildSearchResults(context),
          ],
        ),
      ),
      currentIndex: 1,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selamat Siang',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text(
                '${profileController.username}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold
                )
              )),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.person_add, color: Colors.blue),
                    onPressed: () => _showSearchUserDialog(context),
                  ),
                  IconButton(
                    icon: Obx(() => Icon(
                      chatController.isSearching.value ? Icons.close : Icons.search,
                      color: Colors.blue
                    )),
                    onPressed: () => _handleSearchToggle(context),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSearchUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF31363F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Cari Pengguna',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Masukkan nama pengguna...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF222831),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => chatController.searchUsers(value),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: Obx(() {
                    if (chatController.searchResults.isEmpty) {
                      return const Center(
                        child: Text(
                          'Tidak ada pengguna ditemukan',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: chatController.searchResults.length,
                      itemBuilder: (context, index) {
                        final user = chatController.searchResults[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFFF8225),
                            backgroundImage: user['photoURL'].isNotEmpty
                                ? NetworkImage(user['photoURL'])
                                : null,
                            child: user['photoURL'].isEmpty
                                ? Text(
                                    user['displayName'][0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  )
                                : null,
                          ),
                          title: Text(
                            user['displayName'],
                            style: const TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            Get.back(); // Close dialog
                            chatController.startNewChat(
                              user['id'],
                              user['displayName'],
                            );
                          },
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Cari chat...',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF31363F),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          chatController.searchUsers(value);
          if (value.isEmpty) {
            chatController.searchResults.value = 
                chatController.searchResults.where((item) => !item['isProfile']).toList();
          } else {
            chatController.searchResults.value = chatController.searchResults.where((item) {
              if (item['isProfile']) return false;
              final matchesName = item['displayName'].toLowerCase().contains(value.toLowerCase());
              final matchesMessage = 
                item['lastMessage']?.toLowerCase().contains(value.toLowerCase()) ?? false;
              return matchesName || matchesMessage;
            }).toList();
          }
        },
      ),
    );
  }

  Widget _buildOnlineUsers(BuildContext context) {
    return SizedBox(
      height: 110,
      child: Obx(() {
        if (chatController.onlineUsers.isEmpty) {
          return const Center(
            child: Text(
              'No online users',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: chatController.onlineUsers.length,
          itemBuilder: (context, index) {
            final user = chatController.onlineUsers[index];
            final lastSeen = user['lastSeen'] != null 
                ? (user['lastSeen'] as Timestamp).toDate() 
                : null;
            
            String lastSeenText = 'Offline';
            if (user['isOnline'] == true) {
              lastSeenText = 'Online';
            } else if (lastSeen != null) {
              final now = DateTime.now();
              final difference = now.difference(lastSeen);

              if (difference.inSeconds < 60) {
                lastSeenText = 'Just now';
              } else if (difference.inMinutes < 60) {
                lastSeenText = '${difference.inMinutes}m ago';
              } else if (difference.inHours < 24) {
                lastSeenText = '${difference.inHours}h ago';
              } else if (difference.inDays < 7) {
                lastSeenText = '${difference.inDays}d ago';
              }
            }

            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () {
                  final chatController = Get.put(ChatController());
                  chatController.createOrGetChat(
                    user['uid'],
                    user['displayName'],
                  ).then((chatId) {
                    if (chatId != null) {
                      Get.to(() => MessagePage(
                        recipientId: user['uid'],
                        recipientName: user['displayName'],
                        chatId: chatId,
                      ));
                    }
                  });
                },
                child: Container(
                  width: 90,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF31363F),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: const Color(0xFFFF8225),
                            backgroundImage: user['photoURL'].isNotEmpty
                                ? NetworkImage(user['photoURL'])
                                : null,
                            child: user['photoURL'].isEmpty
                                ? Text(
                                    user['displayName'][0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: user['isOnline'] == true 
                                    ? Colors.green 
                                    : Colors.grey,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF31363F),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user['displayName'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        lastSeenText,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildChatsHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        'Chats',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    return Expanded(
      child: Obx(() {
        if (chatController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF8225)),
          );
        }

        if (chatController.chats.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada chat',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: chatController.chats.length,
          itemBuilder: (context, index) {
            final chat = chatController.chats[index];
            final otherUserIndex = chat.users.indexOf(chatController._auth.currentUser!.uid) == 0 ? 1 : 0;
            
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFFF8225),
                child: Text(
                  chat.usernames[otherUserIndex][0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                chat.usernames[otherUserIndex],
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                chat.lastMessage,
                style: const TextStyle(color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                _formatTime(chat.lastMessageTime),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              onTap: () {
                final chatController = Get.put(ChatController());
                
                Get.to(() => MessagePage(
                  recipientId: chat.users[otherUserIndex],
                  recipientName: chat.usernames[otherUserIndex],
                  chatId: chat.id!,
                ));
              },
            );
          },
        );
      }),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _handleSearchToggle(BuildContext context) {
    chatController.isSearching.value = !chatController.isSearching.value;
    if (!chatController.isSearching.value) {
      chatController.searchUsers(''); // Reset search
    }
  }
}