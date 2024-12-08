import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/product.dart';
import '../../../data/recommendation.dart';
import '../../../services/produk_service.dart';
import 'package:kerent/app/modules/profile/views/profile_edit.dart';
import 'package:kerent/app/modules/profile/controllers/profile_controller.dart';
import 'package:kerent/app/services/auth_service.dart';
import 'package:kerent/app/modules/profile/views/profile_view.dart';
class MainMenuController extends GetxController {

  final ProductService _productService = ProductService();
  final RxList<String> categories = <String>['All', 'Laptop', 'Mouse', 'Keyboard', 'Phone'].obs;
  final RxList<Product> filteredProducts = <Product>[].obs;
  final RxList<Product> allProducts = <Product>[].obs;
  final Rx<String> selectedCategory = 'All'.obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxList<SearchRecommendation> recommendations = <SearchRecommendation>[].obs;
  final RxList<SearchRecommendation> filteredRecommendations = <SearchRecommendation>[].obs;

  


  //Controller Banner Item
  final PageController pageController = PageController(initialPage: 0);
  final RxInt currentPage = 0.obs;

  final RxList<BannerItem> banners = <BannerItem>[
    BannerItem(
      title: 'Try renting\nsomething new',
      subtitle: 'Rent or leash your items',
      image: "assets/images/keyboard banner.png",
      color: const Color(0xFFD4C4FC),
    ),
    BannerItem(
      title: 'Try renting\nsomething new',
      subtitle: 'Rent or leash your items',
      image: "assets/images/Laptop Silver.png",
      color: const Color(0xFFFBC87B),
    ),
    BannerItem(
      title: 'Try renting\nsomething new',
      subtitle: 'Rent or leash your items',
      image: "assets/images/Laptop kecil banner.png",
      color: const Color(0xFF597445)
    ),
    BannerItem(
      title: 'Try renting\nsomething new',
      subtitle: 'Rent or leash your items',
      image: "assets/images/Iphone 16 PM banner.png",
      color: const Color.fromARGB(255, 123, 204, 251)
    ),
  ].obs;
  

  // Add profile image
  final RxString profileImage = ''.obs;
  
  // Search-related properties
  final RxBool isSearching = false.obs;
  
  // Add this new property for For You products
  final RxList<Product> forYouProducts = <Product>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _startAutoScroll();
    _initializeProducts();
    ever(searchQuery, (_) => _performSearch());
  }

  void _initializeProducts() {
    isLoading.value = true;
    _productService.getProducts().listen(
      (products) {
        allProducts.assignAll(products);
        _filterProducts();
        _updateForYouProducts();
        isLoading.value = false;
      },
      onError: (error) {
        print('Error fetching products: $error');
        isLoading.value = false;
      },
    );
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    _filterProducts();
  }

  void _filterProducts() {
    if (selectedCategory.value == 'All') {
      filteredProducts.assignAll(allProducts);
    } else {
      filteredProducts.assignAll(
        allProducts.where((p) => p.etalase == selectedCategory.value).toList(),
      );
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    isSearching.value = query.isNotEmpty;
    _performSearch();
  }

  void _performSearch() {
    if (searchQuery.value.isEmpty) {
      _filterProducts();
      return;
    }

    final query = searchQuery.value.toLowerCase();
    filteredProducts.assignAll(
      allProducts.where((product) =>
        product.name.toLowerCase().contains(query) ||
        product.deskripsi.toLowerCase().contains(query)
      ).toList(),
    );
  }

  // Profile image update method
  void updateProfileImage(String newImageUrl) {
    profileImage.value = newImageUrl;
  }

  Future<void> refreshProducts() async {
    isLoading.value = true;
    await Future.delayed(Duration(seconds: 1)); // Debounce
    _initializeProducts();
  }

  // Existing banner-related methods remain the same
  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (currentPage.value < banners.length - 1) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
      _startAutoScroll();
    });
  }

  // Add this new method
  void _updateForYouProducts() {
    try {

      // Filter out products with null createdAt
      final validProducts = allProducts.where((p) => p.createdAt != null).toList();
      
      // Sort products by date
      validProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Take the newest 6 products
      final newest = validProducts.take(6).toList();
      forYouProducts.assignAll(newest);
    } catch (e) {
      forYouProducts.clear();
      print(e);
    }
  }

  void navigateToProfile() {
    final ProfileController profileController = Get.put(ProfileController());
    final AuthService authService = Get.find<AuthService>();
    final String currentUserId = authService.userUid ?? '';
    
    // Initialize profile with current user's ID
    profileController.initializeProfileForUser(currentUserId);
    
    // If it's the current user's profile, show edit view
    // Otherwise, show public profile view
    if (profileController.targetUserId == currentUserId) {
      Get.to(
        () => const ProfileEditView(),
        transition: Transition.rightToLeft,
      );
    } else {
      Get.to(
        () => const PublicProfilePage(), // Create this view for public viewing
        transition: Transition.rightToLeft,
      );
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

