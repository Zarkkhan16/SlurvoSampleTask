import 'package:flutter/material.dart';

class BottomNavController {
  static final ValueNotifier<int> currentIndex = ValueNotifier<int>(0);
  static final ValueNotifier<int?> reTapIndex = ValueNotifier<int?>(null);
  static void goToTab(int index) {
    if (currentIndex.value == index) {
      // trigger stack reset logic manually if needed
      reTapIndex.value = index;
    } else {
      currentIndex.value = index;
    }
  }

}
