import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ImageCarouselController extends GetxController {
  final List<String> imgList;
  final pageController = PageController();
  final current = 0.obs;

  ImageCarouselController({required this.imgList});

  @override
  void onInit() {
    super.onInit();
    ever(current, (_) => update()); // Update the UI whenever current changes
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    current.value = index;
  }
}