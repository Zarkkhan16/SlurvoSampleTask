import 'package:flutter/material.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/widget/gradient_border_container.dart';

class CustomDataValue extends StatelessWidget {
  final String title;
  final String subTitle;
  final String value;

  const CustomDataValue(
      {super.key,
      required this.title,
      required this.subTitle,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return GradientBorderContainer(
      borderRadius: 20,
      containerWidth: 170,
      child: Column(
        children: [
          Text(
            title,
            style: AppTextStyle.roboto(
                fontSize: 16, fontWeight: FontWeight.w500, height: 1.2),
          ),
          Text(
            subTitle,
            style: AppTextStyle.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
          Text(
            value,
            style: AppTextStyle.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 2.2,
            ),
          ),
        ],
      ),
    );
  }
}
