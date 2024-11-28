import 'package:get/get.dart';
import '../../../data/models/product.dart';
import '../../../data/recommendation.dart';
import '../../../services/produk_service.dart';
import 'dart:async';

class SearchResultController extends GetxController {
  final ProductService _productService = ProductService();
  
  final RxList<Product> filteredProducts = <Product>[].obs;
  final RxList<Product> allProducts = <Product>[].obs;
  final RxList<String> categories = <String>['All', 'Laptop', 'Mouse', 'Keyboard', 'Phone'].obs;
  final RxString selectedCategory = 'All'.obs;
  final RxString selectedSort = 'Newest'.obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isTyping = false.obs;
  final RxList<SearchRecommendation> recommendations = <SearchRecommendation>[].obs;
  
  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['searchQuery'] != null) {
      searchQuery.value = args['searchQuery'];
      performSearch();
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    isSearching.value = query.isNotEmpty;
    isTyping.value = true;
    
    _debounceTimer?.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      isTyping.value = false;
      performSearch();
    });
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    applyFiltersAndSort();
  }

  void updateSort(String sortOption) {
    selectedSort.value = sortOption;
    applyFiltersAndSort();
  }

  void performSearch() {
    if (searchQuery.value.isEmpty) {
      filteredProducts.clear();
      allProducts.clear();
      return;
    }

    isLoading.value = true;
    _productService.searchProducts(searchQuery.value).listen(
      (products) {
        allProducts.assignAll(products);
        applyFiltersAndSort();
        isLoading.value = false;
      },
      onError: (error) {
        print('Error searching products: $error');
        filteredProducts.clear();
        allProducts.clear();
        isLoading.value = false;
      },
    );
  }

  void applyFiltersAndSort() {
    List<Product> results = List<Product>.from(allProducts);
    
    if (selectedCategory.value != 'All') {
      results = results.where((p) => p.etalase == selectedCategory.value).toList();
    }
    
    switch (selectedSort.value) {
      case 'Price: Low to High':
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Rating':
        results.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Newest':
        results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    
    filteredProducts.assignAll(results);
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}
