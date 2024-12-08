import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kerent/app/data/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../controllers/auth_controller.dart';
import '../../payment/views/payment_view.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/check_out_controller.dart';
import 'image_carousel.dart';

class CheckoutPage extends StatefulWidget {
  final Product produk;
  final profileController = Get.put(ProfileController());
  final controller = Get.put(CheckoutController());
  CheckoutPage({super.key, required this.produk}); 

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isExpanded = false;
  ElevatedButton? chatSellerButton;
  final AuthController _authController = Get.find<AuthController>();
  final controller = Get.find<CheckoutController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxString sellerName = ''.obs;

  @override
  void initState() {
    super.initState();
    loadSellerInfo();
  }

  Future<void> loadSellerInfo() async {
    try {
      final sellerDoc = await _firestore
          .collection('users')
          .doc(widget.produk.sellerId)
          .get();
      
      sellerName.value = sellerDoc.data()?['username'] ?? 'Unknown Seller';
    } catch (e) {
      print('Error loading seller info: $e');
    }
  }

  bool get isProductOwner => 
    widget.produk.sellerId == _authController.currentUser?.uid;

  final List<String> imgList = [
  ];

  @override
  Widget build(BuildContext context) {
    chatSellerButton = ElevatedButton(
      onPressed: widget.produk.sellerId.isNotEmpty 
          ? () {
              controller.onChatPressed(
                widget.produk.sellerId,
                widget.produk.seller
              );
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFFF8225),
        elevation: 0,
        side: const BorderSide(
          color: Color(0xFFFF8225),
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
      ),
      child: const Text(
        'Chat Seller',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (isProductOwner)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                Get.toNamed('/edit-product', arguments: widget.produk);
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomImageCarousel(imgList: imgList),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.produk.name,
                          style: const TextStyle(
                            color: Color(0xFFF8F8F8),
                            fontSize: 16,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w700,
                            height: 0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.yellow, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              widget.produk.rating.toString(),
                              style: TextStyle(color: Colors.grey[400], fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.produk.price.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.class_, color: Colors.grey[400], size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Kelas: ${widget.produk.kelas}',
                              style: TextStyle(color: Colors.grey[400], fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.production_quantity_limits, color: Colors.grey[400], size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Stock: ${widget.produk.stock}',
                              style: TextStyle(color: Colors.grey[400], fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            InkWell(
                              onTap: () => Get.to(
                                () => const PublicProfilePage(), 
                                arguments: {
                                  'userId': widget.produk.sellerId,
                                  'isCurrentUser': true,
                                }
                              ),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF8225),
                                  shape: BoxShape.circle,
                                  image: widget.produk.seller.isNotEmpty && widget.profileController.profileImage.value.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(widget.profileController.profileImage.value),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: widget.produk.seller.isEmpty || widget.profileController.profileImage.value.isNotEmpty
                                    ? null
                                    : Center(
                                        child: Text(
                                          widget.produk.seller.isNotEmpty 
                                              ? widget.produk.seller[0].toUpperCase() 
                                              : '?',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell( 
                                onTap: () => Get.to(
                                  () => const PublicProfilePage(), 
                                  arguments: {
                                    'userId': widget.produk.sellerId,
                                    'isCurrentUser': true,
                                  }
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Obx(() => Text(
                                      sellerName.value,
                                      style: const TextStyle(
                                        color: Color(0xFFF8F8F8),
                                        fontSize: 14,
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )),
                                    const Text(
                                      'Aktif 2 jam yang lalu',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontFamily: 'Plus Jakarta Sans',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            chatSellerButton!,
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoSection('Kondisi: ', widget.produk.kondisi),
                        _buildInfoSection('Etalase', widget.produk.etalase),
                        _buildInfoSection('Deskripsi Produk', widget.produk.deskripsi),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: isProductOwner 
                  ? _buildOwnerActions() 
                  : _buildCustomerActions(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    const int wordLimit = 50;
    List<String> words = content.split(' ');

    String displayedText = _isExpanded || words.length <= wordLimit
        ? content
        : '${words.take(wordLimit).join(' ')}...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            text: displayedText,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w600            
            ),
            children: [
              if (words.length > wordLimit)
                TextSpan(
                  text: _isExpanded ? ' Lihat lebih sedikit' : ' \nLihat selengkapnya',
                  style: const TextStyle(
                    color: Colors.blue
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildOwnerActions() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF8225),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        // Navigate to edit product page
        // Implement your edit product navigation here
      },
      child: const Text(
        'Edit Product',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCustomerActions() {
    return Row(
      children: [
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8225),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // Existing rent functionality
              Get.to(() => PaymentView(product: widget.produk));
            },
            child: const Text(
              'Rent Now',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}