import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';

import '../controllers/confirm_number_controller.dart';

class ConfirmNumberBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConfirmNumberController>(
      () => ConfirmNumberController(),
    );
        Get.lazyPut<AuthController>(
      () => AuthController(),
    );
  }
}
