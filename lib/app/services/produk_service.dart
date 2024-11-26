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

  Stream<List<Product>> searchProducts(String searchTerm) {
    return _productsRef
        .where('name', isGreaterThanOrEqualTo: searchTerm)
        .where('name', isLessThanOrEqualTo: searchTerm + '\uf8ff')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }
}
