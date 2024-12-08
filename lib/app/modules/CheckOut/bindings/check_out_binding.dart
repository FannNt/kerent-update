import 'package:get/get.dart';

import '../../chat/controllers/chat_controller.dart';
import '../controllers/check_out_controller.dart';

class CheckOutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckoutController>(() => CheckoutController());
    Get.lazyPut<ChatController>(() => ChatController());
  }
}
  