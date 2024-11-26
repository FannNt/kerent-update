import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kerent/app/modules/chat/views/chat_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/models/product.dart';
import '../../../data/models/rentRequest.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TabController? _tabController;
  Stream<QuerySnapshot>? _sellerRequestsStream;
  Stream<QuerySnapshot>? _customerRequestsStream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _setupRequestsStreams();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _setupRequestsStreams() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Stream for requests where user is the customer (renter)
      _customerRequestsStream = _firestore
          .collection('rentRequests')
          .where('customerId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .snapshots();

      // Stream for requests where user is the product owner
      _sellerRequestsStream = _firestore
          .collection('rentRequests')
          .where('productOwnerId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
  }

  Future<void> _updateRequestStatus(RentRequest request, String newStatus) async {
    try {
      // Update request status with timestamp
      await _firestore.collection('rentRequests').doc(request.id).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
        if (newStatus == 'Confirmed') 'confirmedAt': FieldValue.serverTimestamp(),
        if (newStatus == 'Rejected') 'rejectedAt': FieldValue.serverTimestamp(),
      });

      // If confirmed, update product availability
      if (newStatus == 'Confirmed') {
        await _firestore.collection('products').doc(request.product.id).update({
          'isAvailable': false,
          'currentRenterId': request.customerId,
          'rentedAt': FieldValue.serverTimestamp(),
        });
      }

      // Show success message
      Get.snackbar(
        'Success',
        'Request ${newStatus.toLowerCase()} successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error updating request status: $e');
      Get.snackbar(
        'Error',
        'Failed to update request status',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _handleRentRequest(RentRequest request, bool isConfirmed) async {
    final newStatus = isConfirmed ? 'Confirmed' : 'Rejected';
    
    try {
      // Update the request status
      await _updateRequestStatus(request, newStatus);

      if (isConfirmed) {
        // Navigate to chat for confirmed requests
        _navigateToMessage(
          request,
          "Hi, ${request.customerName}, pesananmu yang ini diterima nih. Mau ketemuan kapan dan dimana",
        );
      } else {
        // Show rejection dialog
        _showRejectionDialog(request);
      }
    } catch (e) {
      print('Error handling rent request: $e');
      Get.snackbar(
        'Error',
        'Failed to process request',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Add this method to handle request completion
  Future<void> _markAsReturned(RentRequest request) async {
    try {
      // Update request status
      await _firestore.collection('rentRequests').doc(request.id).update({
        'status': 'Returned',
        'returnedAt': FieldValue.serverTimestamp(),
      });

      // Update product availability
      await _firestore.collection('products').doc(request.product.id).update({
        'isAvailable': true,
        'currentRenterId': null,
        'rentedAt': null,
      });

      Get.snackbar(
        'Success',
        'Product marked as returned',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error marking as returned: $e');
      Get.snackbar(
        'Error',
        'Failed to mark as returned',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _navigateToMessage(RentRequest request, String message) {
    Get.to(() => ChatView(
      recipientName: request.customerName,
      profileColor: Colors.orange,
      initialMessage: message,
      rentRequest: request,
    ));
  }

  void _showRejectionDialog(RentRequest request) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF262626),
        title: const Text(
          'Alasan Penolakan',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Masukkan alasan penolakan',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToMessage(
                request,
                "Hi, ${request.customerName}, maaf pesananmu kami batalkan karena ${controller.text}.",
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange,
            ),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF262626),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Inbox',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController!,
          indicatorColor: Colors.orange,
          tabs: const [
            Tab(text: 'My Rentals'),
            Tab(text: 'My Products'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController!,
        children: [
          // Tab 1: Requests made by the user (as customer)
          _buildRequestsList(_customerRequestsStream, isCustomer: true),
          
          // Tab 2: Requests received for user's products (as seller)
          _buildRequestsList(_sellerRequestsStream, isCustomer: false),
        ],
      ),
    );
  }

  Widget _buildRequestsList(Stream<QuerySnapshot>? stream, {required bool isCustomer}) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white)),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
        }

        final requests = snapshot.data?.docs
            .map((doc) => RentRequest.fromFirestore(doc))
            .toList() ??
            [];

        if (requests.isEmpty) {
          return Center(
            child: Text(
              isCustomer 
                ? 'You haven\'t made any rental requests yet'
                : 'No requests for your products yet',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _buildRequestCard(request, isCustomer);
          },
        );
      },
    );
  }

  Widget _buildRequestCard(RentRequest request, bool isCustomer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(request.product.images ?? ''),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.product.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('Duration', request.rentalDuration),
                      _buildInfoRow(
                        isCustomer ? 'Owner' : 'Renter', 
                        isCustomer ? request.product.seller : request.customerName
                      ),
                      _buildInfoRow('Total Price', 'Rp ${request.totalPrice}'),
                      const SizedBox(height: 8),
                      _buildStatusBadge(request.status),
                    ],
                  ),
                ),
              ],
            ),
            // Action buttons
            if (!isCustomer) ...[
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (request.status == 'Pending') ...[
                      _buildActionButton(
                        'Accept',
                        Colors.green,
                        () => _handleRentRequest(request, true),
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        'Reject',
                        Colors.red,
                        () => _handleRentRequest(request, false),
                      ),
                    ] else if (request.status == 'Confirmed') ...[
                      _buildActionButton(
                        'Mark as Returned',
                        Colors.blue,
                        () => _markAsReturned(request),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Color(0xFFB0B0B0),
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final Color backgroundColor;
    final Color textColor;

    switch (status) {
      case 'Pending':
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange;
        break;
      case 'Confirmed':
        backgroundColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green;
        break;
      case 'Returned':
        backgroundColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue;
        break;
      default: // Rejected
        backgroundColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Status: $status',
        style: TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(text),
    );
  }
}