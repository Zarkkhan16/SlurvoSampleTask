import 'package:flutter/material.dart';
import 'package:onegolf/core/constants/app_text_style.dart';

class AnswerBox extends StatelessWidget {
  final List<String> bullets;
  final String? paragraph;

  const AnswerBox({
    super.key,
    this.paragraph,
    required this.bullets,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[800], // Or a custom gray, e.g., Color(0xFF3A3A3C)
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (paragraph != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                paragraph!,
                style:
                    TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
              ),
            ),
          ...bullets.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "• ",
                      style: AppTextStyle.roboto(
                        height: 1.2,
                        fontSize: 16,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        b,
                        style: AppTextStyle.roboto(
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
