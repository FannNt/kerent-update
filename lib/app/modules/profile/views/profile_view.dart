import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kerent/app/data/models/chat.dart';
import 'package:kerent/app/modules/profile/controllers/profile_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../controllers/auth_controller.dart';
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
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    final String userId = args?['userId'] ?? authController.uid.value;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.initializeProfileForUser(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildHeader(context),
                      _buildProfileInfoWrapper(),
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    _buildTabBar(),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                _buildBarangDisewakanWrapper(),
                const Center(
                  child: Text(
                    'Review Tab',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
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
          if (isPreview)
            Container(
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
        ],
      ),
    );
  }

  Widget _buildProfileInfoWrapper() {
    return Obx(() => profileController.isLoading.value
      ? const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF8225),
          ),
        )
      : _buildProfileInfo(
          profileController.profileImage.value,
          profileController.username.value,
          profileController.classOrPosition.value,
          profileController.description.value,
        ),
    );
  }

  Widget _buildBarangDisewakanWrapper() {
    return Obx(() => profileController.isLoading.value
      ? const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF8225),
          ),
        )
      : _buildBarangDisewakanGrid(),
    );
  }

  Widget _buildProfileInfo(String profileImage, String username, String classOrPosition, String description) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              // Profile image and basic info
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF8225),
                  image: profileImage.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(profileImage),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: profileImage.isEmpty
                    ? Center(
                        child: Text(
                          username.isNotEmpty ? username[0].toUpperCase() : '',
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              // Followers/Following count - wrapped in Obx
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Get.to(() => const FollowersPage()),
                    child: Text(
                      '${profileController.followersCount} Pengikut',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => Get.to(() => const FollowingPage()),
                    child: Text(
                      '${profileController.followingCount} Mengikuti',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              )),
              const SizedBox(height: 16),
              // Follow/Chat buttons - wrapped in Obx
              Obx(() {
                final args = Get.arguments as Map<String, dynamic>?;
                final isCurrentUser = args?['isCurrentUser'] ?? false;
                final isPreview = args?['isPreview'] ?? false;

                if (isPreview) {
                  return const SizedBox.shrink();
                }

                return Row(
                  children: [
                    if (!isCurrentUser) ...[
                      ElevatedButton(
                        onPressed: () => profileController.toggleFollow(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: profileController.isFollowing.value
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
                          profileController.isFollowing.value ? 'Mengikuti' : 'Ikuti',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final Chat chat = Chat(
                            users: [authController.uid.value ?? '', profileController.targetUserId ?? ''],
                            usernames: [authController.displayName.value, profileController.username.value],
                            lastMessage: '',
                            lastMessageTime: DateTime.now(),
                            unreadCount: 0,
                          );
                          Get.toNamed('/chat', arguments: chat);
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
                      ),
                    ],
                  ],
                );
              }),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  classOrPosition,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
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

  Widget _buildBarangDisewakanGrid() {
    if (profileController.error.isNotEmpty) {
      return Center(
        child: Text(
          profileController.error.value,
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    if (profileController.rentedItems.isEmpty) {
      return const Center(
        child: Text(
          'No items found',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: profileController.rentedItems.length,
      itemBuilder: (context, index) {
        final product = profileController.rentedItems[index];
        return _buildProductCard(
          product['name'] ?? '',
          'Rp ${product['price'] ?? 0}',
          product['images'] ?? '',
        );
      },
    );
  }

  Widget _buildProductCard(String name, String price, String imageUrl) {
    return SizedBox(
      height: 250,
      child: Card(
        elevation: 0,
        color: const Color(0xFF31363F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/placeholder.png',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
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
                price,
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