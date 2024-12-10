import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kerent/app/data/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

import '../../../controllers/auth_controller.dart';
import '../../../services/auth_service.dart';
import '../../payment/views/payment_view.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/check_out_controller.dart';
import 'image_carousel.dart';

class CheckoutPage extends StatefulWidget {
  final Product produk;
  CheckoutPage({super.key, required this.produk}); 

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final ProfileController profileController = Get.put(ProfileController());
  final CheckoutController controller = Get.put(CheckoutController());
  bool _isExpanded = false;
  ElevatedButton? chatSellerButton;
  final AuthController _authController = Get.find<AuthController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxString sellerName = ''.obs;
  final RxBool isLoading = true.obs;
  final RxString lastActiveText = ''.obs;

  @override
  void initState() {
    super.initState();
    loadSellerInfo();
    
    // Initialize imgList with product images
    imgList.clear(); // Clear any existing images
    
    // Add main product image if it exists
    if (widget.produk.images.isNotEmpty) {
      imgList.add(widget.produk.images);
    }
    
    // If no images are available, add a placeholder
    if (imgList.isEmpty) {
      imgList.add('https://via.placeholder.com/400x300/111111/FFFFFF/?text=No+Image');
    }
  }

  Future<void> loadSellerInfo() async {
    try {
      isLoading.value = true;
      final sellerDoc = await _firestore
          .collection('users')
          .doc(widget.produk.sellerId)
          .get();
      
      final userData = sellerDoc.data();
      sellerName.value = userData?['username'] ?? 'Unknown Seller';
      
      // Get lastLogin timestamp
      final lastLogin = userData?['lastLogin'] as Timestamp?;
      if (lastLogin != null) {
        final now = DateTime.now();
        final difference = now.difference(lastLogin.toDate());

        if (difference.inSeconds < 60) {
          lastActiveText.value = 'Aktif baru saja';
        } else if (difference.inMinutes < 60) {
          lastActiveText.value = 'Aktif ${difference.inMinutes} menit yang lalu';
        } else if (difference.inHours < 24) {
          lastActiveText.value = 'Aktif ${difference.inHours} jam yang lalu';
        } else if (difference.inDays < 7) {
          lastActiveText.value = 'Aktif ${difference.inDays} hari yang lalu';
        } else {
          lastActiveText.value = 'Offline';
        }
      } else {
        lastActiveText.value = 'Status tidak tersedia';
      }
    } catch (e) {
      print('Error loading seller info: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool get isProductOwner => 
    widget.produk.sellerId == _authController.currentUser?.uid;

  final List<String> imgList = [];

  @override
  Widget build(BuildContext context) {
    chatSellerButton = !isProductOwner && widget.produk.sellerId.isNotEmpty 
        ? ElevatedButton(
            onPressed: () {
              controller.onChatPressed(
                widget.produk.sellerId,
                widget.produk.seller
              );
            },
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
          )
        : null;

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
                            RatingBarIndicator(
                              rating: widget.produk.rating,
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Color(0xFFFF8225),
                              ),
                              itemCount: 5,
                              itemSize: 20,
                              unratedColor: Colors.grey[700],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.produk.rating.toStringAsFixed(1),
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          NumberFormat.currency(
                            locale: 'id', 
                            symbol: 'Rp. ', 
                            decimalDigits: 0
                          ).format(widget.produk.price),
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
                              onTap: () => {
                                // controller.navigateToSellerProfile(widget.produk.sellerId)
                                },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF8225),
                                  shape: BoxShape.circle,
                                  image: widget.produk.seller.isNotEmpty && profileController.profileImage.value.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(profileController.profileImage.value),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: widget.produk.seller.isEmpty || profileController.profileImage.value.isNotEmpty
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
                                onTap: () {
                                  // controller.navigateToSellerProfile(widget.produk.sellerId);
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Obx(() => isLoading.value
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                                          ),
                                        )
                                      : Text(
                                          sellerName.value,
                                          style: const TextStyle(
                                            color: Color(0xFFF8F8F8),
                                            fontSize: 14,
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                    ),
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
                            if (chatSellerButton != null) ...[
                              const SizedBox(width: 8),
                              chatSellerButton!,
                            ],
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
              backgroundColor: widget.produk.isAvailable 
                  ? const Color(0xFFFF8225)
                  : Colors.grey,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: widget.produk.isAvailable
              ? () {
                  Get.to(() => PaymentView(product: widget.produk));
                }
              : null,
            child: Text(
              widget.produk.isAvailable ? 'Rent Now' : 'Not Available',
              style: const TextStyle(
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

  void _showFullScreenImage(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                PageView.builder(
                  controller: PageController(initialPage: index),
                  itemCount: imgList.length,
                  itemBuilder: (context, index) {
                    return InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Center(
                        child: Image.network(
                          imgList[index],
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: const Color(0xFFFF8225),
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        fullscreenDialog: true,
      ),
    );
  }
}