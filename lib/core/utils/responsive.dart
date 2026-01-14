import 'package:flutter/material.dart';

class Responsive {
  static double w(BuildContext c, double v) =>
      MediaQuery.of(c).size.width * (v / 375);

  static double h(BuildContext c, double v) =>
      MediaQuery.of(c).size.height * (v / 812);

  static double s(BuildContext c) {
    final width = MediaQuery.of(c).size.width;
    return (width / 375).clamp(0.9, 1.15);
  }
}
