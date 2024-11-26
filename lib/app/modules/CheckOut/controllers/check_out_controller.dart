import 'package:get/get.dart';
import '../../../data/models/product.dart';

class CheckoutController extends GetxController {
  var currentIndex = 0.obs;
  late Rx<Product> product;
  RxBool isExpanded = false.obs;

  final List<String> imgList = [
    'https://via.placeholder.com/400x300/111111/FFFFFF/?text=Laptop+1',
    'https://via.placeholder.com/400x300/111111/FFFFFF/?text=Laptop+2',
    'https://via.placeholder.com/400x300/111111/FFFFFF/?text=Laptop+3',
  ];


  void toggleExpanded() {
    isExpanded.toggle();
  }

  String getDisplayedText(String content, int wordLimit) {
    List<String> words = content.split(' ');
    return isExpanded.value || words.length <= wordLimit
        ? content
        : words.take(wordLimit).join(' ') + '...';
  }

  void onCheckoutPressed() {
    // Implement checkout logic here
    Get.snackbar('Checkout', 'Processing your order...');
  }

  void onHomePressed() {
    // Implement home navigation logic here
    Get.offNamed('/main-menu');
  }

  void onChatPressed() {
    // Implement chat navigation logic here
    Get.toNamed('/chat');
  }

  void onAddPressed() {
    // Implement add item logic here
    Get.snackbar('Add Item', 'Adding new item...');
  }
}

