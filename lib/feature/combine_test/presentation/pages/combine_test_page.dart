import 'package:flutter/material.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/feature/combine_test/domain/entities/tile_data_entity.dart';
import 'package:onegolf/feature/combine_test/games/full_combine_test/presentation/pages/full_combine_setup_page.dart';
import 'package:onegolf/feature/combine_test/games/wedge_combine_test/presentation/pages/wedge_combine_setup_page.dart';
import 'package:onegolf/feature/combine_test/presentation/widget/answer_box.dart';
import 'package:onegolf/feature/combine_test/presentation/widget/custom_combine_test_buton.dart';
import 'package:onegolf/feature/combine_test/presentation/widget/custom_expandable_tile.dart';
import 'package:onegolf/feature/widget/bottom_nav_bar.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/header_row.dart';

import '../../games/custom_combine_test/presentation/pages/custom_combine_setup_page.dart';

class CombineTestPage extends StatefulWidget {
  const CombineTestPage({super.key});

  @override
  State<CombineTestPage> createState() => _CombineTestPageState();
}

class _CombineTestPageState extends State<CombineTestPage> {
  int? expandedIndex;

  final List<TileDataEntity> items = [
    TileDataEntity(
      icon: Icon(Icons.lightbulb, color: Colors.amber),
      title: "What is the Combine Test?",
      answer: AnswerBox(
        bullets: [
          "The Combine Test is a structured performance challenge designed to test your ability to control distance and accuracy across a range of target zones. With 10 different carry distance categories and 60 total shots, the test simulates real-life shot variability and reveals strengths and weaknesses in your game.",
        ],
      ),
    ),
    TileDataEntity(
      icon: Icon(Icons.sports_golf, color: Colors.redAccent),
      title: "How It Works:",
      answer: AnswerBox(
        bullets: [
          "Once you begin, you’ll be presented with a randomized target carry distance within predefined categories. You’ll hit 6 shots per category. After each shot, you’ll receive immediate feedback on how close your actual carry was to the assigned target. This replicates on-course unpredictability and trains focus under pressure."
        ],
      ),
    ),
    TileDataEntity(
      icon: Icon(Icons.bar_chart, color: Colors.blueAccent),
      title: "How Scoring Works:",
      answer: AnswerBox(
        bullets: [
          "Each shot is scored out of 100 points based on how close your carry distance is to the target carry. The closer you are, the higher your score.",
          "Perfect carry = 100 points",
          "Larger deviations = lower scores",
          "Your total score is the average of all 60 shots. Consistency and precision are rewarded — every shot counts.",
        ],
      ),
    ),
    TileDataEntity(
      icon: Icon(Icons.emoji_events, color: Colors.yellow),
      title: "Final Score:",
      answer: AnswerBox(
        bullets: [
          "At the end of the test, you’ll receive your overall score, a per-category breakdown, and performance insights. This helps you track progress over time, identify your best distances, and find gaps in your game. Share your score, retake the test, and track improvement as you train with purpose."
        ],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      bottomNavigationBar: BottomNavBar(),
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Column(
          children: [
            HeaderRow(
              headingName: "Combine Test",
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 20, bottom: 30),
                children: [
                  ...List.generate(
                    items.length,
                    (i) => CustomExpandableTile(
                      expanded: expandedIndex == i,
                      onTap: () => setState(() {
                        expandedIndex = expandedIndex == i ? null : i;
                      }),
                      title: items[i].title,
                      leading: items[i].icon,
                      answer: items[i].answer,
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Buttons at the end of scroll
                  CustomCombineTestButton(
                    text: "Wedge Combine",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WedgeCombineSetupPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  CustomCombineTestButton(
                    text: "Full Combine",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullCombineSetupPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  CustomCombineTestButton(
                    text: "Custom Combine",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomCombineSetupPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
