import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';

import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ProfileController>(
      ProfileController(),
      permanent: true,
    );
    Get.put<AuthController>(
      AuthController(),
      permanent: true,
    );
  }

}