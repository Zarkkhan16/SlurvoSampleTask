import 'package:flutter/material.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_text_style.dart';

class RowTileWidget extends StatelessWidget {
  final String name;
  final String shotNumber;
  final String groupNumber;
  final bool isFavorite;
  final bool showDate;
  final VoidCallback onTap;
  final VoidCallback onTapStar;

  const RowTileWidget({
    super.key,
    required this.name,
    required this.shotNumber,
    required this.groupNumber,
    required this.isFavorite,
    required this.onTap,
    required this.onTapStar,
    this.showDate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: AppColors.primaryText,
          child: Text(
            name[0],
            style: AppTextStyle.roboto(
              fontWeight: FontWeight.w500,
              color: AppColors.buttonText,
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyle.roboto(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "$shotNumber Shots, $groupNumber Group",
                  style: AppTextStyle.roboto(),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: onTapStar,
          child: Icon(
            Icons.star,
            color: isFavorite ? AppColors.starColor : Colors.white,
          ),
        ),
      ],
    );
  }
}
