import 'package:flutter/material.dart';

class BottomNavController {
  static final ValueNotifier<int> currentIndex = ValueNotifier<int>(0);
  static void goToTab(int index) {
    if (currentIndex.value == index) {
      // trigger stack reset logic manually if needed
    } else {
      currentIndex.value = index;
    }
  }

}
