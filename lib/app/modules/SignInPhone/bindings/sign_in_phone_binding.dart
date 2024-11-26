import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';

import '../controllers/sign_in_phone_controller.dart';

class SignInPhoneBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignInPhoneController>(
      () => SignInPhoneController(),
    );
    Get.lazyPut<AuthController>(()=> AuthController());
  }
}
