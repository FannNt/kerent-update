import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/auth_service.dart';

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

  @override
  void onInit() {
    super.onInit();
    initializeData();
  }

  Future<void> initializeData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        loadUserData(),
        loadFollowers(),
        loadFollowing(),
        loadRentedItems(),
      ]);
      if (targetUserId != null && targetUserId != _authService.userUid) {
        await checkFollowStatus();
      }
    } catch (e) {
      print('Error initializing data: $e');
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
      String? uid = targetUserId ?? _authService.userUid;
      if (uid != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
        
        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          username.value = userData['username'] ?? '';
          classOrPosition.value = userData['classOrPosition'] ?? '';
          description.value = userData['description'] ?? '';
          telephone.value = userData['phoneNumber']?.toString() ?? '';
          profileImage.value = userData['profileImageUrl'] ?? '';
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
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
        await _firestore.collection('users').doc(uid).update({
          'username': username.value,
          'classOrPosition': classOrPosition.value,
          'description': description.value,
          // Don't update phone and password here - they have separate flows
        });
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
}
