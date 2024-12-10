import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kerent/app/data/models/chat.dart';
import 'package:kerent/app/modules/profile/controllers/profile_controller.dart';
import 'package:intl/intl.dart';
import '../../../data/models/product.dart';
import '../../CheckOut/views/check_out_view.dart';

import '../../../controllers/auth_controller.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../chat/views/chat_view.dart';
import 'follower_view.dart';
import 'following_view.dart';


class PublicProfilePage extends StatefulWidget {
  const PublicProfilePage({super.key});

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  final ProfileController profileController = Get.find<ProfileController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final isPreview = args?['isPreview'] ?? false;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(context),
                  GetBuilder<ProfileController>(
                    builder: (controller) => _buildProfileInfo(controller),
                  ),
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      children: [
                        SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: _buildUserProducts(),
                          ),
                        ),
                        const Center(
                          child: Text(
                            'Review Tab',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isPreview)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    color: Colors.grey[800],
                    child: const Center(
                      child: Text(
                        'This is how others see your profile',
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final isPreview = args?['isPreview'] ?? false;

    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 16, top: 8, bottom: 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              if (isPreview)
                const Expanded(
                  child: Center(
                    child: Text(
                      'Preview Mode',
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(ProfileController controller) {
    final args = Get.arguments as Map<String, dynamic>?;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF8225),
                  image: controller.profileImage.value.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(controller.profileImage.value),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: controller.profileImage.value.isEmpty
                    ? Center(
                        child: Text(
                          controller.username.value.isNotEmpty 
                              ? controller.username.value[0].toUpperCase() 
                              : '',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // Profile Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.username.value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (controller.classOrPosition.value.isNotEmpty)
                      Text(
                        controller.classOrPosition.value,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildFollowButton(controller),
                        const SizedBox(width: 8),
                        _buildChatButton(controller, args),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Followers and Following count
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.to(() => const FollowersPage()),
                child: Text(
                  '${controller.followersCount} Followers',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => Get.to(() => const FollowingPage()),
                child: Text(
                  '${controller.followingCount} Following',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          if (controller.description.value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                controller.description.value,
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.black,
      child: TabBar(
        indicatorColor: const Color(0xFFFF8225),
        tabs: const [
          Tab(text: 'Barang Disewakan'),
          Tab(text: 'Review'),
        ],
        labelStyle: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildUserProducts() {
    return GetBuilder<ProfileController>(
      builder: (controller) {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFF8225),
            ),
          );
        }

        if (controller.userProducts.isEmpty) {
          return const Center(
            child: Text(
              'No products listed yet',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: controller.userProducts.length,
          itemBuilder: (context, index) {
            final product = controller.userProducts[index];
            return _buildProductCard(product);
          },
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final formattedPrice = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(product.price);

    return Card(
      elevation: 0,
      color: const Color(0xFF31363F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => Get.to(() => CheckoutPage(produk: product)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black26,
                  ),
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.images,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF8F8F8),
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                ),
              ),
              Text(
                formattedPrice,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Color(0xFFF8F8F8),
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFollowButton(ProfileController controller) {
    final args = Get.arguments as Map<String, dynamic>?;
    final isCurrentUser = args?['isCurrentUser'] ?? false;
    final isPreview = args?['isPreview'] ?? false;

    if (isPreview) {
      return const SizedBox.shrink();
    }

    if (isCurrentUser) {
      return const SizedBox.shrink();
    }

    return GetBuilder<ProfileController>(
      builder: (controller) => ElevatedButton(
        onPressed: () => controller.toggleFollow(),
        style: ElevatedButton.styleFrom(
          backgroundColor: controller.isFollowing.value
              ? Colors.grey[800]
              : const Color(0xFF25C8FF),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: const Size(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          controller.isFollowing.value ? 'Mengikuti' : 'Ikuti',
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildChatButton(ProfileController controller, Map<String, dynamic>? args) {
    final isCurrentUser = args?['isCurrentUser'] ?? false;
    final isPreview = args?['isPreview'] ?? false;

    if (isPreview) {
      return const SizedBox.shrink();
    }

    if (isCurrentUser) {
      return const SizedBox.shrink();
    }

    return ElevatedButton(
      onPressed: () {
        final chatController = Get.put(ChatController());
        final targetUserId = args?['userId'] ?? authController.uid.value;
        
        chatController.createOrGetChat(
          targetUserId,
          controller.username.value.isNotEmpty 
              ? controller.username.value 
              : 'Unknown Seller',
        ).then((chatId) {
          if (chatId != null) {
            Get.to(() => MessagePage(
              recipientId: targetUserId,
              recipientName: controller.username.value.isNotEmpty 
                  ? controller.username.value 
                  : 'Unknown Seller',
              chatId: chatId,
            ));
          }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF222222),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(0, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        'Chat',
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Get.delete<ProfileController>();
    super.dispose();
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => 48.0;
  @override
  double get maxExtent => 48.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.black,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}