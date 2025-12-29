import 'package:flutter/material.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/feature/combine_test/domain/entities/tile_data_entity.dart';
import 'package:onegolf/feature/combine_test/games/wedge_combine_test/presentation/pages/wedge_combine_start_page.dart';
import 'package:onegolf/feature/combine_test/presentation/widget/answer_box.dart';
import 'package:onegolf/feature/combine_test/presentation/widget/custom_expandable_tile.dart';
import 'package:onegolf/feature/widget/bottom_nav_bar.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import 'package:onegolf/feature/widget/session_view_button.dart';

class WedgeCombineSetupPage extends StatefulWidget {
  const WedgeCombineSetupPage({super.key});

  @override
  State<WedgeCombineSetupPage> createState() => _WedgeCombineSetupPageState();
}

class _WedgeCombineSetupPageState extends State<WedgeCombineSetupPage> {
  int? expandedIndex;

  final List<TileDataEntity> items = [
    TileDataEntity(
      icon: Icon(Icons.lightbulb, color: Colors.amber),
      title: "What is the Wedge Combine Test?",
      answer: AnswerBox(
        bullets: [
          "The Wedge Combine Test is designed to sharpen your short-game accuracy by focusing on precision wedge distances. With targets ranging from 40 to 120 yards, this test challenges your ability to control carry distance in the scoring zone — where it matters most."
        ],
      ),
    ),
    TileDataEntity(
      icon: Icon(Icons.sports_golf, color: Colors.redAccent),
      title: "How It Works:",
      answer: AnswerBox(
        bullets: [
          "You’ll hit 54 shots to random distances, each falling between 40–120 yards.",
          "This simulates the real-world challenge of adjusting feel, trajectory, and swing length on demand.",
          "Every shot is measured and scored based on how closely it matches the target carry.",
          "This Combine is ideal for wedge calibration, distance gapping, and improving consistency inside 120 yards.",
        ],
      ),
    ),
    TileDataEntity(
      icon: Icon(Icons.bar_chart, color: Colors.blueAccent),
      title: "How Scoring Works:",
      answer: AnswerBox(
        bullets: [
          "Each shot is scored out of 100 based on how close your actual carry is to the assigned target distance.",
          "Perfect distance = 100 points",
          "Greater miss = lower score",
          "Your final score is the average of all 60 shots. The test rewards consistency, control, and the ability to adapt to short-distance targets.",
        ],
      ),
    ),
    TileDataEntity(
      icon: Icon(Icons.emoji_events, color: Colors.yellow),
      title: "Final Score:",
      answer: AnswerBox(
        bullets: [
          "Once the test is complete, you’ll receive:",
          "Your overall score",
          "A distance-by-distance breakdown",
          "Insights to identify your most and least consistent wedge ranges",
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
            HeaderRow(headingName: "Wedge Combine Test"),
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
                    builder: (context) => WedgeCombineStartPage(),
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
