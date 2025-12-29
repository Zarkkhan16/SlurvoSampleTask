import 'package:flutter/material.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/feature/combine_test/domain/entities/tile_data_entity.dart';
import 'package:onegolf/feature/combine_test/games/full_combine_test/presentation/pages/full_combine_start_page.dart';
import 'package:onegolf/feature/combine_test/games/wedge_combine_test/presentation/pages/wedge_combine_start_page.dart';
import 'package:onegolf/feature/combine_test/presentation/widget/answer_box.dart';
import 'package:onegolf/feature/combine_test/presentation/widget/custom_expandable_tile.dart';
import 'package:onegolf/feature/widget/bottom_nav_bar.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import 'package:onegolf/feature/widget/session_view_button.dart';

class FullCombineSetupPage extends StatefulWidget {
  const FullCombineSetupPage({super.key});

  @override
  State<FullCombineSetupPage> createState() => _FullCombineSetupPageState();
}

class _FullCombineSetupPageState extends State<FullCombineSetupPage> {
  int? expandedIndex;

  final List<TileDataEntity> items = [
    TileDataEntity(
      icon: Icon(Icons.lightbulb, color: Colors.amber),
      title: "What is the Combine Test?",
      answer: AnswerBox(
        bullets: [
          "The Combine Test is a structured performance challenge designed to test your ability to control distance and accuracy across a range of target zones. With 10 different carry distance categories and 60 total shots, the test simulates real-life shot variability and reveals strengths and weaknesses in your game."
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
          "Greater deviations = lower score",
          "Your total score is the average of all 60 shots. Consistency and precision are rewarded — every shot counts",
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
      // bottomNavigationBar: BottomNavBar(),
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Column(
          children: [
            HeaderRow(headingName: "Full Combine Test"),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 20, bottom: 30),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  return CustomExpandableTile(
                    expanded: expandedIndex == i,
                    onTap: () {
                      setState(() {
                        expandedIndex = expandedIndex == i ? null : i;
                      });
                    },
                    title: items[i].title,
                    leading: items[i].icon,
                    answer: items[i].answer,
                  );
                },
              ),
            ),
            SessionViewButton(
              onSessionClick: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullCombineStartPage(),
                  ),
                );
              },
              buttonText: "Start",
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
