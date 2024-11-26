import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:kerent/app/modules/imageCarousel/views/image_carousel_view.dart';
import 'package:kerent/app/modules/payment/views/payment_view.dart';
import '../../../../navbar.dart';
import '../../../data/models/product.dart';

class CheckOutView extends StatefulWidget {
  
  final Product product;
  
  const CheckOutView({Key? key, required this.product}) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckOutView> {
  bool _isExpanded = false; // State untuk menentukan apakah teks diperluas atau tidak

  final List<String> imgList = [
    'https://via.placeholder.com/400x300/111111/FFFFFF/?text=Laptop+1',
    'https://via.placeholder.com/400x300/111111/FFFFFF/?text=Laptop+2',
    'https://via.placeholder.com/400x300/111111/FFFFFF/?text=Laptop+3',
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageCarousel(imgList: imgList),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: TextStyle(
                        color: Color(0xFFF8F8F8),
                        fontSize: 16,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        height: 0,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.yellow, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '${widget.product.rating}',
                          style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${widget.product.price}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.class_, color: Colors.grey[400], size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Kelas: ${widget.product.kelas}',
                          style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.grey[400], size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Seller: ${widget.product.seller}',
                          style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.production_quantity_limits, color: Colors.grey[400], size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Stock: ${widget.product.stock}',
                          style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),
                    _buildInfoSection('Kondisi: ', '${widget.product.kondisi}'),
                    _buildInfoSection('Etalase', '${widget.product.etalase}'),
                    _buildInfoSection('Deskripsi Produk', '${widget.product.deskripsi}'),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                          builder: (context) => PaymentView(product: widget.product,),
                        ),
                      );
                      },
                      child: Text('Check Out'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      currentIndex: -1,
    );
  }

  // Method untuk membangun bagian informasi dengan fitur "Lihat Selengkapnya"
  Widget _buildInfoSection(String title, String content) {
    final int wordLimit = 50; // Batas jumlah kata
    List<String> words = content.split(' '); // Memisahkan konten menjadi list kata

    String displayedText = _isExpanded || words.length <= wordLimit
        ? content
        : words.take(wordLimit).join(' ') + '...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text.rich(
          TextSpan(
            text: displayedText,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w600            
              ),
            children: [
              if (words.length > wordLimit)
                TextSpan(
                  text: _isExpanded ? ' Lihat lebih sedikit' : ' \nLihat selengkapnya',
                  style: TextStyle(
                    color: Colors.blue
                    ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      setState(() {
                        _isExpanded = !_isExpanded; // Toggle state saat ditekan
                      });
                    },
                ),
            ],
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
