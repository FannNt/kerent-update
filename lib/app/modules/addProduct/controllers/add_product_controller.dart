import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dart:io';

import '../../../controllers/auth_controller.dart';
import '../../../data/models/product.dart';
import '../../../services/produk_service.dart';

class AddProductController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final descriptionController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();
  final supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  final Rx<XFile?> imageFile = Rx<XFile?>(null);
  final RxBool isLoading = false.obs;
  
  final RxString selectedCategory = 'Laptop'.obs;
  final RxString selectedCondition = 'New'.obs;
  
  final List<String> categories = ['Laptop', 'Mouse', 'Keyboard', 'Phone'];

  Future<void> pickImage() async {
    try {
      // Show bottom sheet for image source selection
      await Get.bottomSheet(
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Get.back();
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    imageFile.value = image;
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Get.back();
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    imageFile.value = image;
                  }
                },
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
      Future<String> _uploadImageToSupabase(File imageFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageResponse = await supabase.storage
          .from('picture')
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      final String imageUrl = supabase.storage
          .from('picture')
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> submitProduct() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (imageFile.value == null) {
      Get.snackbar(
        'Error',
        'Please select an image for the product',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Upload image to Supabase
      final String imageUrl = await _uploadImageToSupabase(File(imageFile.value!.path));

      final product = Product(
        id: '',
        name: nameController.text,
        price: double.parse(priceController.text),
        images: imageUrl, // Use the uploaded image URL
        rating: 0.01,
        seller: authController.displayName ?? 'Unknown',
        sellerId: authController.uid ?? '',
        kelas: 'jii',
        stock: int.parse(stockController.text),
        kondisi: selectedCondition.value,
        etalase: selectedCategory.value,
        deskripsi: descriptionController.text,
        createdAt: DateTime.now(),
        isAvailable: true,
      );

      await Get.find<ProductService>().addProduct(product);

      // Reset all fields
      _resetFields();

      Get.back();
      Get.snackbar(
        'Success',
        'Product added successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print(e);
      Get.snackbar(
        'Error',
        'Failed to add product: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Add this new method to reset all fields
  void _resetFields() {
    nameController.clear();
    priceController.clear();
    stockController.clear();
    descriptionController.clear();
    selectedCategory.value = 'Laptop'; // Reset to default category
    selectedCondition.value = 'New';   // Reset to default condition
    imageFile.value = null;            // Reset selected image
  }

  void updateCategory(String? value) {
    if (value != null) {
      selectedCategory.value = value;
    }
  }

  void updateCondition(String? value) {
    if (value != null) {
      selectedCondition.value = value;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}