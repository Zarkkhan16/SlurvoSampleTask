import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import '../../../widget/gradient_border_container.dart';

class GamingCard extends StatelessWidget {
  final String svgPath;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const GamingCard({
    super.key,
    required this.svgPath,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GradientBorderContainer(
        borderRadius: 20,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 35),
        child: Row(
          children: [
            if (title.contains('Drills'))
              SizedBox(
                width: 8,
              ),
            SvgPicture.asset(
              svgPath,
              height: 50,
              width: 45,
            ),
            SizedBox(width: title.contains('Drills') ? 30 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyle.roboto(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style:  AppTextStyle.roboto(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
