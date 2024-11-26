
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';

import '../../../data/models/chat.dart';

class SelectRecipientPage extends StatefulWidget {
  @override
  _SelectRecipientPageState createState() => _SelectRecipientPageState();
}

class _SelectRecipientPageState extends State<SelectRecipientPage> {
  final ChatController controller = Get.find();
  final TextEditingController searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<PrivateChatUser> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchAllUsers();
  }

  void _fetchAllUsers() {
    _firestore.collection('users').snapshots().listen((snapshot) {
      filteredUsers = snapshot.docs.map((doc) => PrivateChatUser.fromDocument(doc)).toList();
      setState(() {});
    });
  }

  void _searchUsers(String query) {
    // filteredUsers = controller.allUsers.where((user) => user.name.toLowerCase().contains(query.toLowerCase())).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Recipient')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: _searchUsers,
              decoration: InputDecoration(
                hintText: 'Search users',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(user.name.isNotEmpty ? user.name[0] : 'U'),
                  ),
                  title: Text(user.name),
                  onTap: () {
                    // controller.setRecipient(user);
                    // Get.back();
                    // Get.to(() => PrivateChatPage());
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}