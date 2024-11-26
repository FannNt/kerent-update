import 'package:get/get.dart';

import '../../mainMenu/controllers/main_menu_controller.dart';
import '../controllers/check_out_controller.dart';

class CheckOutBinding extends Bindings {
  @override
  void dependencies() {
  Get.lazyPut<CheckoutController>(() => CheckoutController());
  }
}
  