import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/models/product.dart';

class ProductService {
  final CollectionReference _productsRef = FirebaseFirestore.instance.collection('products');

  // Get all products
  Stream<List<Product>> getProducts() {
    return _productsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  // Get products by category
  Stream<List<Product>> getProductsByCategory(String category) {
    return _productsRef
        .where('etalase', isEqualTo: category)
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  Future<void> addProduct(Product product) {
    return _productsRef.add(product.toFirestore());
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) {
    return _productsRef.doc(id).update(data);
  }

  Future<void> deleteProduct(String id) {
    return _productsRef.doc(id).delete();
  }

  // Updated search method with better logging and error handling
  Stream<List<Product>> searchProducts(String searchTerm) {
    print('Searching for: $searchTerm'); // Debug log
    
    if (searchTerm.isEmpty) {
      return Stream.value([]);
    }

    searchTerm = searchTerm.toLowerCase();
    
    try {
      return _productsRef
          .where('name_lowercase', isGreaterThanOrEqualTo: searchTerm)
          .where('name_lowercase', isLessThanOrEqualTo: searchTerm + '\uf8ff')
          .snapshots()
          .map((snapshot) {
            print('Found ${snapshot.docs.length} results'); // Debug log
            return snapshot.docs.map((doc) {
              try {
                return Product.fromFirestore(doc);
              } catch (e) {
                print('Error parsing document ${doc.id}: $e');
                return null;
              }
            })
            .where((product) => product != null)
            .cast<Product>()
            .toList();
          });
    } catch (e) {
      print('Error in searchProducts: $e');
      return Stream.value([]);
    }
  }

  // Alternative search method using multiple fields
  Stream<List<Product>> advancedSearch(String searchTerm) {
    searchTerm = searchTerm.toLowerCase();
    
    return _productsRef
        .where('searchKeywords', arrayContains: searchTerm)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  Future<void> updateSearchFields() async {
    final QuerySnapshot snapshot = await _productsRef.get();
    
    for (final doc in snapshot.docs) {
      final product = Product.fromFirestore(doc);
      await doc.reference.update({
        'name_lowercase': product.name.toLowerCase(),
        'searchKeywords': Product.generateSearchKeywords(product.name),
      });
    }
  }
}
