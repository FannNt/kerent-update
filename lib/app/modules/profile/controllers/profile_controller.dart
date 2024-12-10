import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/product.dart';
import '../../../services/auth_service.dart';
import '../../../controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxString username = ''.obs;
  final RxString classOrPosition = ''.obs;
  final RxString description = ''.obs;
  final RxString telephone = ''.obs;
  final RxString profileImage = ''.obs;
  final RxInt followersCount = 0.obs;
  final RxInt followingCount = 0.obs;
  final RxList followers = [].obs;
  final RxList following = [].obs;
  final RxList rentedItems = [].obs;
  final RxBool isFollowing = false.obs;
  String? targetUserId;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxList<Product> userProducts = <Product>[].obs;

  bool get isCurrentUser {
    return targetUserId == _authService.userUid;
  }

  @override
  void onInit() {
    super.onInit();
    
    // Get arguments from navigation
    final args = Get.arguments as Map<String, dynamic>?;
    print('Arguments received in onInit: $args');
    
    if (args != null && args['userId'] != null) {
      targetUserId = args['userId'];
      print('Setting targetUserId to seller: $targetUserId');
    } else {
      targetUserId = _authService.userUid;
      print('No userId in arguments, using current user: $targetUserId');
    }
    
    // Clear previous data
    username.value = '';
    classOrPosition.value = '';
    description.value = '';
    telephone.value = '';
    profileImage.value = '';
    userProducts.clear();
    
    // Initialize with delay to ensure arguments are processed
    Future.delayed(Duration.zero, () {
      initializeData();
    });
  }

  Future<void> initializeData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        loadUserData(),
        loadFollowers(),
        loadFollowing(),
        loadUserProducts(),
      ]);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void initializeProfileForUser(String userId) async {
    isLoading.value = true;
    targetUserId = userId;
    await initializeData();
  }

  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      if (targetUserId != null) {
        print('Loading data for user: $targetUserId'); // Debug print
        final userDoc = await _firestore.collection('users').doc(targetUserId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          username.value = userData['username'] ?? '';
          classOrPosition.value = userData['classOrPosition'] ?? '';
          description.value = userData['description'] ?? '';
          telephone.value = userData['telephone'] ?? '';
          profileImage.value = userData['profileImage'] ?? '';
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadFollowers() async {
    try {
      String? uid = targetUserId ?? _authService.userUid;
      if (uid != null) {
        QuerySnapshot followersSnapshot = await _firestore
            .collection('users')
            .doc(uid)
            .collection('followers')
            .get();
        
        followers.value = followersSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        followersCount.value = followers.length;
      }
    } catch (e) {
      print('Error loading followers: $e');
    }
  }

  Future<void> loadFollowing() async {
    try {
      String? uid = targetUserId ?? _authService.userUid;
      if (uid != null) {
        QuerySnapshot followingSnapshot = await _firestore
            .collection('users')
            .doc(uid)
            .collection('following')
            .get();
        
        following.value = followingSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        followingCount.value = following.length;
      }
    } catch (e) {
      print('Error loading following: $e');
    }
  }

  Future<void> loadRentedItems() async {
    try {
      String? uid = targetUserId ?? _authService.userUid;
      if (uid != null) {
        QuerySnapshot itemsSnapshot = await _firestore
            .collection('products')
            .where('userId', isEqualTo: uid)
            .get();
        
        rentedItems.value = itemsSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      print('Error loading rented items: $e');
    }
  }

  Future<void> saveProfileChanges() async {
    try {
      String? uid = _authService.userUid;
      if (uid != null) {
        // Update Firestore
        await _firestore.collection('users').doc(uid).update({
          'username': username.value,
          'classOrPosition': classOrPosition.value,
          'description': description.value,
        });

        // Update Firebase Auth display name
        await _authService.currentUser?.updateDisplayName(username.value);
        
        // Update AuthController's display name
        Get.find<AuthController>().displayName.value = username.value;
        
        // Reload the user to ensure all changes are reflected
        await _authService.currentUser?.reload();
      }
    } catch (e) {
      print('Error saving profile changes: $e');
      throw e;
    }
  }

  Future<void> deleteBarangDisewakan(String itemName) async {
    try {
      String? uid = _authService.userUid;
      if (uid != null) {
        // Find and delete the item
        QuerySnapshot itemQuery = await _firestore
            .collection('users')
            .doc(uid)
            .collection('rentedItems')
            .where('name', isEqualTo: itemName)
            .get();

        if (itemQuery.docs.isNotEmpty) {
          await itemQuery.docs.first.reference.delete();
          // Reload items after deletion
          await loadRentedItems();
        }
      }
    } catch (e) {
      print('Error deleting item: $e');
      throw e;
    }
  }

  Future<void> checkFollowStatus() async {
    if (_authService.userUid == targetUserId) {
      isFollowing.value = false;
      return;
    }
    
    try {
      String? currentUid = _authService.userUid;
      if (currentUid != null && targetUserId != null) {
        DocumentSnapshot followDoc = await _firestore
            .collection('users')
            .doc(currentUid)
            .collection('following')
            .doc(targetUserId)
            .get();
        
        isFollowing.value = followDoc.exists;
      }
    } catch (e) {
      print('Error checking follow status: $e');
    }
  }

  Future<void> toggleFollow() async {
    try {
      String? currentUid = _authService.userUid;
      if (currentUid != null && targetUserId != null) {
        if (isFollowing.value) {
          // Unfollow
          await _firestore
              .collection('users')
              .doc(currentUid)
              .collection('following')
              .doc(targetUserId)
              .delete();
              
          await _firestore
              .collection('users')
              .doc(targetUserId)
              .collection('followers')
              .doc(currentUid)
              .delete();
              
          isFollowing.value = false;
          followingCount.value--;
        } else {
          // Follow
          final followData = {
            'timestamp': FieldValue.serverTimestamp(),
            'userId': targetUserId,
            'username': username.value,
            'profileImage': profileImage.value,
          };
          
          await _firestore
              .collection('users')
              .doc(currentUid)
              .collection('following')
              .doc(targetUserId)
              .set(followData);
              
          await _firestore
              .collection('users')
              .doc(targetUserId)
              .collection('followers')
              .doc(currentUid)
              .set(followData);
              
          isFollowing.value = true;
          followingCount.value++;
        }
        
        await loadFollowers();
        await loadFollowing();
      }
    } catch (e) {
      print('Error toggling follow: $e');
      Get.snackbar(
        'Error',
        'Failed to ${isFollowing.value ? "unfollow" : "follow"} user',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> loadUserProducts() async {
    try {
      isLoading.value = true;
      String? uid = targetUserId ?? _authService.userUid;
      if (uid != null) {
        final QuerySnapshot productsSnapshot = await _firestore
            .collection('products')
            .where('sellerId', isEqualTo: uid)
            .get();
            
        final products = productsSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Product.fromFirestore(doc);
        }).toList();
        
        userProducts.assignAll(products);
        updateUI();
      }
    } catch (e) {
      print('Error loading user products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      String? uid = _authService.userUid;
      if (uid != null) {
        // Delete the product from Firestore
        await _firestore
            .collection('products')
            .doc(productId)
            .delete();
        
        // Remove the product from local list
        userProducts.removeWhere((product) => product.id == productId);
        
        // Reload products to ensure sync
        await loadUserProducts();
      }
    } catch (e) {
      print('Error deleting product: $e');
      throw e;
    }
  }

  void updateUI() {
    update();
  }

  Future<void> loadFollowersAndFollowing(String uid) async {
    try {
      // Load followers
      QuerySnapshot followersSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('followers')
          .get();
      
      followers.value = followersSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      followersCount.value = followers.length;

      // Load following
      QuerySnapshot followingSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('following')
          .get();
      
      following.value = followingSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      followingCount.value = following.length;

      // Check if current user is following this profile
      if (!isCurrentUser) {
        String? currentUid = _authService.userUid;
        if (currentUid != null) {
          DocumentSnapshot followDoc = await _firestore
              .collection('users')
              .doc(currentUid)
              .collection('following')
              .doc(uid)
              .get();
          
          isFollowing.value = followDoc.exists;
        }
      }
    } catch (e) {
      print('Error loading followers and following: $e');
    }
  }
}
