import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kerent/app/modules/CheckOut/views/check_out_view.dart';
import 'package:kerent/app/modules/profile/controllers/profile_controller.dart';
import 'package:kerent/app/modules/profile/views/profile_view.dart';
import 'dart:async';


import '../../../controllers/auth_controller.dart';
import '../../../data/models/product.dart';
import '../../../services/auth_service.dart';
import 'follower_view.dart';
import 'following_view.dart';


class ProfileEditView extends StatefulWidget {
  const ProfileEditView({super.key});

  @override
  _ProfileEditViewState createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends State<ProfileEditView> {
  final AuthService _authService = Get.find();
  final AuthController _authController = Get.find();
  final ProfileController _profileEditController = Get.put(ProfileController());
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newValueController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  Timer? _timer;
  final RxInt _countDown = 60.obs;
  final RxBool _isTimerRunning = false.obs;

    @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _countDown.value = 60;
    _isTimerRunning.value = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      
      if (_countDown.value == 0) {
        timer.cancel();
        _isTimerRunning.value = false;
      } else {
        _countDown.value--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: SingleChildScrollView( // Added SingleChildScrollView here
            child: SizedBox( // Added SizedBox to provide height
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded( // Wrapped the scrollable content in Expanded
                    child: SingleChildScrollView( // Added another SingleChildScrollView for the content
                      child: Column(
                        children: [
                          _buildProfileInfo(),
                          _buildTabBar(),
                          SizedBox( // Used SizedBox with fixed height for TabBarView
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: _buildTabBarView(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 16, top: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Row(
            children: [
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.check, color: Colors.white),
                onPressed: _saveProfileChanges,
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.red),
                onPressed: _showLogoutConfirmationDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }

Widget _buildProfileInfo() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        // Centered profile picture
        Center(
          child: Column(
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: _selectProfilePicture,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8225),
                        shape: BoxShape.circle,
                        image: _profileEditController.profileImage.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(_profileEditController.profileImage.value),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _profileEditController.profileImage.isEmpty
                          ? Center(
                              child: Text(
                                _profileEditController.username.value.isNotEmpty
                                    ? _profileEditController.username.value.toUpperCase()
                                    : '',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8225),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16,),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Get.to(() => const FollowersPage()),
                      child: Obx(() => Text(
                        '${_profileEditController.followersCount} Pengikut',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                        ),
                      )),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => Get.to(() => const FollowingPage()),
                      child: Obx(() => Text(
                        '${_profileEditController.followingCount} Mengikuti',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                        ),
                      )),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        // Input fields aligned to the left
        _buildEditableFieldWithIcon(
          value: _profileEditController.username.value,
          onChanged: _profileEditController.username,
          icon: Icons.person_outline,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Plus Jakarta Sans',
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildEditableFieldWithIcon(
          value: _profileEditController.classOrPosition.value,
          onChanged: _profileEditController.classOrPosition,
          icon: Icons.work_outline,
          style: const TextStyle(
            fontSize: 14.0,
            color: Colors.grey,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        const SizedBox(height: 16),
        _buildEditableFieldWithIcon(
          value: _profileEditController.description.value,
          onChanged: _profileEditController.description,
          icon: Icons.description_outlined,
          style: const TextStyle(
            fontSize: 14.0,
            fontFamily: 'Plus Jakarta Sans',
            color: Colors.white,
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        _buildContactField(
          value: _profileEditController.telephone.value,
          onTap: _showPhoneChangeDialog,
          icon: Icons.phone_outlined,
          style: const TextStyle(
            fontSize: 14.0,
            fontFamily: 'Plus Jakarta Sans',
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildContactField(
          value: '••••••••',
          onTap: _showPasswordChangeDialog,
          icon: Icons.lock_outlined,
          style: const TextStyle(
            fontSize: 14.0,
            fontFamily: 'Plus Jakarta Sans',
            color: Colors.white,
          ),
        ),
        if (_authService.userUid != _profileEditController.targetUserId) 
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Obx(() => ElevatedButton(
              onPressed: () => _profileEditController.toggleFollow(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _profileEditController.isFollowing.value
                    ? Colors.grey[800]
                    : const Color(0xFF25C8FF),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                minimumSize: const Size(120, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _profileEditController.isFollowing.value ? 'Mengikuti' : 'Ikuti',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            )),
          ),
      ],
    ),
  );
}

Widget _buildEditableFieldWithIcon({
  required String value,
  required Function(String) onChanged,
  required IconData icon,
  required TextStyle style,
  int maxLines = 1,
}) {
  return Container(
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.grey, width: 0.5),
      ),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            initialValue: value,
            onChanged: onChanged,
            style: style,
            maxLines: maxLines,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildContactField({
  required String value,
  required VoidCallback onTap,
  required IconData icon,
  required TextStyle style,
}) {
  return Container(
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.grey, width: 0.5),
      ),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(value, style: style),
                  const Icon(
                    Icons.edit,
                    color: Colors.grey,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

 void _showPhoneChangeDialog() {
    _otpController.clear();
    _newValueController.clear();
    _isTimerRunning.value = false;
    _countDown.value = 60;
    _timer?.cancel();
    
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF31363F),
        title: const Text(
          'Change Phone Number',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Phone: ${_profileEditController.telephone}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newValueController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'New Phone Number',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFF8225)),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _otpController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'OTP Code',
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFF8225)),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() => SizedBox(
                  width: 100,
                  child: TextButton(
                    onPressed: _isTimerRunning.value 
                      ? null 
                      : () {
                          _startTimer();
                          // Show OTP sent alert
                          Get.snackbar(
                            'OTP Sent',
                            'OTP code has been sent to ${_profileEditController.telephone}',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                    style: TextButton.styleFrom(
                      backgroundColor: _isTimerRunning.value 
                        ? Colors.grey 
                        : const Color(0xFFFF8225),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: _isTimerRunning.value
                      ? Text(
                          '${_countDown.value}s',
                          style: const TextStyle(color: Colors.white),
                        )
                      : const Text(
                          'Send OTP',
                          style: TextStyle(color: Colors.white),
                        ),
                  ),
                )),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _timer?.cancel();
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                if (_otpController.text.isNotEmpty && _newValueController.text.isNotEmpty) {
                  // Verify OTP first (you'll need to implement this)
                  // Then update phone number
                  await _authService.updatePhoneNumber(_newValueController.text);
                  await _profileEditController.loadUserData(); // Reload user data
                  Get.back();
                  Get.snackbar(
                    'Success',
                    'Phone number updated successfully',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                }
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to update phone number',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text(
              'Change',
              style: TextStyle(color: Color(0xFFFF8225)),
            ),
          ),
        ],
      ),
    );
  }

  void _showPasswordChangeDialog() {
    _oldPasswordController.clear();
    _newPasswordController.clear();
    
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF31363F),
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _oldPasswordController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Current Password',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFF8225)),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'New Password',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFF8225)),
                ),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement password change logic here
              Get.back();
            },
            child: const Text(
              'Change Password',
              style: TextStyle(color: Color(0xFFFF8225)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: const TabBar(
        labelColor: Color(0xFFFF8225),
        unselectedLabelColor: Colors.grey,
        indicatorColor: Color(0xFFFF8225),
        labelStyle: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        tabs: [
          Tab(text: 'Barang Disewakan'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      children: [
        _buildBarangDisewakanGrid(),
      ],
    );
  }

  Widget _buildBarangDisewakanGrid() {
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
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: controller.userProducts.length,
          itemBuilder: (context, index) {
            return _buildProductCard(controller.userProducts[index]);
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
      child: Stack(
        children: [
          InkWell(
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
                            return const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            );
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
          // Delete button
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                onPressed: () => _showDeleteConfirmationDialog(product),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(Product product) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF31363F),
        title: const Text(
          'Delete Item',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        content: Text(
          'Apakah kamu yakin ingin menghapus "${product.name}"?',
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _profileEditController.deleteProduct(product.id);
                Get.back();
                Get.snackbar(
                  'Success',
                  'Item berhasil dihapus',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              } catch (e) {
                Get.back();
                Get.snackbar(
                  'Error',
                  'Gagal menghapus item',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectProfilePicture() async {
    // Implement image picker logic
  }

  void _saveProfileChanges() async {
    try {
      await _profileEditController.saveProfileChanges();

      await _authController.loadUserData();
      Get.snackbar(
        'Success',
        'Profil berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui profil',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

    void _showLogoutConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF31363F),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar?',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _authController.logout();
              Get.back();
              Get.offAllNamed('/home'); // Navigate to login page
            },
            child: const Text(
              'Logout',
              style: TextStyle(
              color: Colors.red,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void initializeProfileForUser(String userId) {
    _profileEditController.targetUserId = userId;
    _profileEditController.checkFollowStatus();
  }
}