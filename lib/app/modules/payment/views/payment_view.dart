import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
        title: Text('Payment Details', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductCard(),
              SizedBox(height: 16),
              _buildDurationDropdown(),
              SizedBox(height: 24),
              _buildUserInfo(),
              SizedBox(height: 24),
              _buildPriceBreakdown(),
              SizedBox(height: 24),
              _buildRentButton(),
            ],
          ),
        ),
      ),
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

  Widget _buildUserInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Renter Information',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Obx(() => Column(
            children: [
              _buildInfoRow('Name', controller.userName.value),
              SizedBox(height: 8),
              _buildInfoRow('Class', controller.userClass.value),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[400]),
        ),
        Text(
          value,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown() {
    return Obx(() {
      final basePrice = product.price;
      final totalAmount = controller.calculateAmount(product, controller.selectedDuration.value);

      final formattedBasePrice = NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(basePrice);
      final formattedTotalAmount = NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(totalAmount);

      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            _buildInfoRow('Base Price', formattedBasePrice),
            SizedBox(height: 8),
            _buildInfoRow('Duration', controller.selectedDuration.value),
            SizedBox(height: 8),
            Divider(color: Colors.grey[700]),
            SizedBox(height: 8),
            _buildInfoRow('Total Amount', formattedTotalAmount),
          ],
        ),
      );
    });
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
    final formattedPrice = NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(product.price);
    return Card(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Center(
              child: Container(
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
              formattedPrice,
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