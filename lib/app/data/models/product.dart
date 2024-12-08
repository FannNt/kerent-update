
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String images;
  final double rating;
  final String seller;
  final String sellerId;
  final String kelas;
  final int stock;
  final String kondisi;
  final String etalase;
  final String deskripsi;
  final DateTime createdAt;
  final bool isAvailable;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.images,
    required this.rating,
    required this.seller,
    required this.sellerId,
    required this.kelas,
    required this.stock,
    required this.kondisi,
    required this.etalase,
    required this.deskripsi,
    required this.createdAt,
    this.isAvailable = true,
  });

  // Convert Firestore document to Product object
  factory Product.fromFirestore(dynamic source) {
    Map<String, dynamic> data;
    String docId;

    if (source is DocumentSnapshot) {
      data = source.data() as Map<String, dynamic>;
      docId = source.id;
    } else if (source is Map<String, dynamic>) {
      data = source;
      docId = data['id'] ?? '';
    } else {
      throw ArgumentError('Invalid source type for Product.fromFirestore');
    }

    return Product(
      id: docId,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      images: data['images'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      seller: data['seller'] ?? '',
      sellerId: data['sellerId'] ?? '',
      kelas: data['kelas'] ?? '',
      stock: data['stock'] ?? 0,
      kondisi: data['kondisi'] ?? '',
      etalase: data['etalase'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isAvailable: data['isAvailable'] ?? true,
    );
  }

  // Add this method to generate search keywords
  static List<String> generateSearchKeywords(String text) {
    final List<String> keywords = [];
    final String lowercaseText = text.toLowerCase();
    
    // Add full text
    keywords.add(lowercaseText);
    
    // Add each word
    keywords.addAll(lowercaseText.split(' '));
    
    // Add partial words (for partial matching)
    String word = '';
    for (final char in lowercaseText.characters) {
      word += char;
      keywords.add(word);
    }
    
    return keywords.toSet().toList(); // Remove duplicates
  }

  // Convert Product object to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'name_lowercase': name.toLowerCase(), // Add this field for case-insensitive search
      'searchKeywords': generateSearchKeywords(name), // Add search keywords
      'price': price,
      'images': images,
      'rating': rating,
      'seller': seller,
      'sellerId': sellerId,
      'kelas': kelas,
      'stock': stock,
      'kondisi': kondisi,
      'etalase': etalase,
      'deskripsi': deskripsi,
      'createdAt': Timestamp.fromDate(createdAt),
      'isAvailable': isAvailable,
    };
  }
}


//Banner
class BannerItem {
  final String title;
  final String subtitle;
  final String image;
  final Color color;

  BannerItem({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.color,
  });
}