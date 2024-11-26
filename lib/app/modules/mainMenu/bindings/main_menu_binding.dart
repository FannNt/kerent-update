import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../controllers/main_menu_controller.dart';

class MainMenuBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MainMenuController>(MainMenuController(), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}
