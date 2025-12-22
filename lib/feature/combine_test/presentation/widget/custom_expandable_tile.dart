import 'package:flutter/material.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_text_style.dart';

class CustomExpandableTile extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;
  final String title;
  final Widget leading;
  final Widget answer;

  const CustomExpandableTile({
    super.key,
    required this.expanded,
    required this.onTap,
    required this.title,
    required this.leading,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    leading,
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyle.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                  ],
                ),
                if (expanded) ...[
                  const SizedBox(height: 10),
                  answer,
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
