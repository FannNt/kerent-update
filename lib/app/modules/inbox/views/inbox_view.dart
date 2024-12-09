import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kerent/app/modules/chat/views/chat_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../data/models/rentRequest.dart';
import '../../chat/controllers/chat_controller.dart';

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
  final chatController = Get.put(ChatController());


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

      if (isConfirmed) {
        final chatId = await chatController.createOrGetChat(
          request.customerId,
          request.customerName,
        );

        if (chatId != null) {
          // Send initial message
          await _sendMessage(
            chatId,
            "Hi, ${request.customerName}, pesananmu yang ini diterima nih. Mau ketemuan kapan dan dimana",
            request.customerId,
          );
          // Update the request status
          await _updateRequestStatus(request, newStatus);

          // Update product stock and availability
          int newStock = request.product.stock - 1;
          await _firestore.collection('products').doc(request.product.id).update({
            'stock': newStock,
          });
          await _updateProductAvailability(request.product.id, newStock);

          // Navigate to chat
          Get.off(() => MessagePage(
            recipientId: request.customerId,
            recipientName: request.customerName,
            chatId: chatId,
          ));
        }
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
      final chatId = await chatController.createOrGetChat(
        request.customerId,
        request.customerName,
      );
      if (chatId != null) {
      Get.to(() => MessagePage(
        recipientId: request.customerId,
        recipientName: request.customerName,
        chatId: chatId,
      ));
        await _sendMessage(
          chatId,
          "Hi, ${request.customerName}, Terima kasih sudah rental produk ${request.product.name} nya. Kami harap anda puas dengan produk yang kami sediakan",
          request.customerId,
        );
      }

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
        'stock': FieldValue.increment(1),
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
            onPressed: () async {
              if (controller.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter a reason for rejection',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              Navigator.of(context).pop();
              
              try {
                final chatId = await chatController.createOrGetChat(
                  request.customerId,
                  request.customerName,
                );

                if (chatId != null) {
                  // Navigate to chat
                  Get.off(() => MessagePage(
                    recipientId: request.customerId,
                    recipientName: request.customerName,
                    chatId: chatId,
                  ));

                  // Send rejection message
                  await _sendMessage(
                    chatId,
                    "Hi, ${request.customerName}, maaf pesananmu untuk produk ${request.product.name} kami batalkan karena ${controller.text}.",
                    request.customerId,
                  );


                  // Update request status to Rejected
                  await _firestore.collection('rentRequests').doc(request.id).update({
                    'status': 'Rejected',
                    'rejectedAt': FieldValue.serverTimestamp(),
                  });

                }
              } catch (e) {
                print('Error sending rejection message: $e');
                Get.snackbar(
                  'Error',
                  'Failed to send rejection message',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
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

  Future<void> _sendMessage(String chatId, String message, String receiverId) async {
    await _firestore.collection('chats').doc(chatId).collection('messages').add({
      'senderId': FirebaseAuth.instance.currentUser!.uid,
      'receiverId': receiverId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // Update lastMessage and lastMessageTime in the chat document
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateProductAvailability(String productId, int stock) async {
    bool isAvailable = stock > 0;
    await _firestore.collection('products').doc(productId).update({
      'isAvailable': isAvailable,
    });
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
    final formattedPrice = NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(request.totalPrice);

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
                      image: NetworkImage(request.product.images),
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
                      _buildInfoRow('Total Price', formattedPrice),
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
            if (isCustomer && request.status == 'Returned' && !request.isRated) ...[
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton(
                      'Rate Product',
                      const Color(0xFFFF8225),
                      () => _showRatingDialog(request),
                    ),
                  ],
                ),
              ),
            ]else if (isCustomer && request.isRated) ...[
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    const Text(
                      'Your Rating: ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          size: 16,
                          color: index < (request.rating ?? 0).floor()
                              ? const Color(0xFFFF8225)
                              : Colors.grey,
                        ),
                      ),
                    ),
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
  void _showRatingDialog(RentRequest request) {
  double rating = 0;
  final reviewController = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF262626),
      title: Text(
        'Rate ${request.product.name}',
        style: const TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RatingBar.builder(
            initialRating: 0,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 40,
            unratedColor: Colors.grey,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Color(0xFFFF8225),
            ),
            onRatingUpdate: (value) {
              rating = value;
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: reviewController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Write your review (optional)',
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFF8225)),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextButton(
          onPressed: () async {
            if (rating == 0) {
              Get.snackbar(
                'Error',
                'Please select a rating',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
              return;
            }
            await _submitRating(request, rating, reviewController.text);
            Navigator.pop(context);
          },
          child: const Text(
            'Submit',
            style: TextStyle(color: Color(0xFFFF8225)),
          ),
        ),
      ],
    ),
  );
}
Future<void> _submitRating(RentRequest request, double rating, String review) async {
  try {
    // Update the request with rating
    await _firestore.collection('rentRequests').doc(request.id).update({
      'rating': rating,
      'review': review,
      'isRated': true,
      'ratedAt': FieldValue.serverTimestamp(),
    });

    // Update product's average rating
    final productRef = _firestore.collection('products').doc(request.product.id);
    final productDoc = await productRef.get();
    final currentRating = productDoc.data()?['rating'] ?? 0.0;
    final totalReviews = productDoc.data()?['totalReviews'] ?? 0;
    
    final newTotalReviews = totalReviews + 1;
    final newRating = ((currentRating * totalReviews) + rating) / newTotalReviews;

    await productRef.update({
      'rating': newRating,
      'totalReviews': newTotalReviews,
    });

    Get.snackbar(
      'Success',
      'Thank you for your rating!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  } catch (e) {
    print('Error submitting rating: $e');
    Get.snackbar(
      'Error',
      'Failed to submit rating',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
}
