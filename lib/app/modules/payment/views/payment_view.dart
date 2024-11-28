  import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/product.dart';
import '../controllers/payment_controller.dart';

class PaymentView extends StatelessWidget {
  final Product product;
  final controller = Get.put(PaymentController());

  PaymentView({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Form( // Add Form widget
          key: controller.formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildProductCard(),
                SizedBox(height: 16),
                _buildForm(),
                SizedBox(height: 16),
                _buildRentButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildDurationDropdown(),
        _buildNameField(),
        _buildClassField(),
      ],
    );
  }

  Widget _buildDurationDropdown() {
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: controller.selectedDuration.value,
          hint: Text('Durasi Sewa', style: TextStyle(color: Colors.white70)),
          items: controller.durations.map((String duration) {
            return DropdownMenuItem<String>(
              value: duration,
              child: Text(
                duration,
                style: TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              controller.selectedDuration.value = value;
            }
          },
          icon: Icon(Icons.arrow_drop_down, color: Colors.white70),
          dropdownColor: Colors.grey[700],
        ),
      ),
    ));
  }

  Widget _buildNameField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller.nameController,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Nama',
          labelStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your name';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildClassField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller.classController,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Kelas',
          labelStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your class';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildRentButton() {
    return Obx(() => Container(
      width: double.infinity,
      child: ElevatedButton(
        child: controller.isLoading.value
            ? CircularProgressIndicator(color: Colors.white)
            : Text('Rent Now'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: controller.isLoading.value
            ? null
            : () => controller.createRental(product),
      ),
    ));
  }
  Widget _buildProductCard() {
    return Card(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF31363F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Image.network(product.images),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF8F8F8),
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "${product.price}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF8F8F8),
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
  }
}