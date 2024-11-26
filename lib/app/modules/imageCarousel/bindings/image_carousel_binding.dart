import 'package:get/get.dart';

import '../controllers/image_carousel_controller.dart';

class ImageCarouselBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageCarouselController>(
      () => ImageCarouselController(imgList: []),
    );
  }
}
