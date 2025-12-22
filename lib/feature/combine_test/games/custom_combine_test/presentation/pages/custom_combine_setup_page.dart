import 'package:flutter/material.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/combine_test/domain/entities/tile_data_entity.dart';
import 'package:onegolf/feature/combine_test/games/custom_combine_test/presentation/pages/custom_combine_start_page.dart';
import 'package:onegolf/feature/combine_test/games/full_combine_test/presentation/pages/full_combine_start_page.dart';
import 'package:onegolf/feature/combine_test/games/wedge_combine_test/presentation/pages/wedge_combine_start_page.dart';
import 'package:onegolf/feature/combine_test/presentation/widget/answer_box.dart';
import 'package:onegolf/feature/combine_test/presentation/widget/custom_expandable_tile.dart';
import 'package:onegolf/feature/widget/bottom_nav_bar.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/gradient_border_container.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import 'package:onegolf/feature/widget/session_view_button.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class CustomCombineSetupPage extends StatefulWidget {
  const CustomCombineSetupPage({super.key});

  @override
  State<CustomCombineSetupPage> createState() => _FullCombineSetupPageState();
}

class _FullCombineSetupPageState extends State<CustomCombineSetupPage> {
  int? expandedIndex;
  int shortestDistance = 60;
  int longestDistance = 80;
  int shotCount = 10;

  final List<TileDataEntity> items = [
    TileDataEntity(
      icon: Icon(Icons.lightbulb, color: Colors.amber),
      title: "What is the Custom Combine Test?",
      answer: AnswerBox(
        bullets: [
          "The Custom Combine Test gives you full control over how you challenge yourself. Set your own shortest and longest target distances, and choose how many shots you want to hit per target. It’s ideal for personal skill development, gapping work, or preparing for specific on-course distances."
        ],
      ),
    ),
    TileDataEntity(
      icon: Icon(Icons.sports_golf, color: Colors.redAccent),
      title: "How It Works:",
      answer: AnswerBox(
        bullets: [
          "Before starting, you’ll select:",
          "Minimum Target Distance (e.g. 40 yds)",
          "Maximum Target Distance (e.g. 120 yds)",
          "Shots Per test",
          "Once you begin, target distances will be randomly selected within your chosen range. You’ll hit your selected number of shots per target distance — just like in the Full Combine, but completely tailored to your needs.",
        ],
      ),
    ),
    TileDataEntity(
      icon: Icon(Icons.bar_chart, color: Colors.blueAccent),
      title: "How Scoring Works:",
      answer: AnswerBox(
        bullets: [
          "Each shot is scored out of 100 based on carry distance accuracy compared to the randomized target.",
          "The closer your carry, the higher your score",
          "Deviations reduce your score per shot",
          "At the end, all scores are averaged to create your Custom Combine Score. This flexible format lets you train with purpose while keeping practice fun and focused.",
        ],
      ),
    ),
    TileDataEntity(
      icon: Icon(Icons.emoji_events, color: Colors.yellow),
      title: "Final Score:",
      answer: AnswerBox(
        bullets: [
          "You’ll receive a final score, along with a breakdown of performance by distance. Whether you’re working on wedge gapping, dialing in your irons, or just competing with friends, the Custom Combine is your way to practice with precision, your way."
        ],
      ),
    ),
  ];

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: AppColors.scaffoldBackground,
  //     bottomNavigationBar: BottomNavBar(),
  //     appBar: CustomAppBar(),
  //     body: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
  //       child: Column(
  //         children: [
  //           HeaderRow(headingName: "Custom Combine Test"),
  //           SizedBox(height: 10),
  //           Text(
  //             "Build your own test by selecting custom\ntarget distances to level up your game.",
  //             style: AppTextStyle.roboto(),
  //             textAlign: TextAlign.center,
  //           ),
  //           Expanded(
  //             child: ListView.builder(
  //               padding: const EdgeInsets.only(top: 20, bottom: 30),
  //               itemCount: items.length,
  //               itemBuilder: (context, i) {
  //                 return CustomExpandableTile(
  //                   expanded: expandedIndex == i,
  //                   onTap: () {
  //                     setState(() {
  //                       expandedIndex = expandedIndex == i ? null : i;
  //                     });
  //                   },
  //                   title: items[i].title,
  //                   leading: items[i].icon,
  //                   answer: items[i].answer,
  //                 );
  //               },
  //             ),
  //           ),
  //           Text(
  //             'Target Distance:',
  //             style: AppTextStyle.roboto(
  //                 fontWeight: FontWeight.w500, fontSize: 16),
  //           ),
  //           SizedBox(height: 10),
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: Column(
  //                   children: [
  //                     GradientBorderContainer(
  //                       borderRadius: 20,
  //                       padding:
  //                           EdgeInsets.symmetric(horizontal: 50, vertical: 20),
  //                       child: GestureDetector(
  //                         onTap: () => _showDistancePicker(true),
  //                         child: Container(
  //                           width: 70,
  //                           height: 50,
  //                           decoration: BoxDecoration(
  //                             color: Color(0xff716B6B66),
  //                             borderRadius: BorderRadius.circular(12),
  //                           ),
  //                           child: Center(
  //                             child: Text(
  //                               shortestDistance.toString(),
  //                               style: AppTextStyle.oswald(
  //                                 fontSize: 30,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     SizedBox(height: 5),
  //                     Text(
  //                       'Shortest Target Distance',
  //                       style: AppTextStyle.roboto(
  //                         color: AppColors.secondaryText,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Padding(
  //                 padding: EdgeInsets.symmetric(horizontal: 5),
  //                 child: Text(
  //                   'TO',
  //                   style: AppTextStyle.roboto(),
  //                 ),
  //               ),
  //               Expanded(
  //                 child: Column(
  //                   children: [
  //                     GradientBorderContainer(
  //                       borderRadius: 20,
  //                       padding:
  //                           EdgeInsets.symmetric(horizontal: 50, vertical: 20),
  //                       child: GestureDetector(
  //                         onTap: () => _showDistancePicker(false),
  //                         child: Container(
  //                           width: 70,
  //                           height: 50,
  //                           decoration: BoxDecoration(
  //                             color: Color(0xff716B6B66),
  //                             borderRadius: BorderRadius.circular(12),
  //                           ),
  //                           child: Center(
  //                             child: Text(
  //                               longestDistance.toString(),
  //                               style: AppTextStyle.oswald(
  //                                 fontSize: 30,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     SizedBox(height: 5),
  //                     Text(
  //                       'Longest Target Distance',
  //                       style: AppTextStyle.roboto(
  //                         color: AppColors.secondaryText,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: 5),
  //           Text(
  //             "The Longest Target Distance must be\natleast 50 yards greater than the Shortest\nTarget Distance",
  //             style: AppTextStyle.roboto(),
  //             textAlign: TextAlign.center,
  //           ),
  //           Align(
  //             alignment: Alignment.center,
  //             child: Text(
  //               "Shot Count",
  //               style: AppTextStyle.roboto(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //           ),
  //           _buildShotCountSlider(context),
  //           SessionViewButton(
  //             onSessionClick: () {
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) => CustomCombineStartPage(),
  //                 ),
  //               );
  //             },
  //             buttonText: "Start",
  //           ),
  //           SizedBox(height: 20),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      bottomNavigationBar: BottomNavBar(),
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderRow(headingName: "Custom Combine Test"),
              const SizedBox(height: 10),
              Text(
                "Build your own test by selecting custom\ntarget distances to level up your game.",
                style: AppTextStyle.roboto(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ...List.generate(
                items.length,
                    (i) => CustomExpandableTile(
                  expanded: expandedIndex == i,
                  onTap: () {
                    setState(() {
                      expandedIndex = expandedIndex == i ? null : i;
                    });
                  },
                  title: items[i].title,
                  leading: items[i].icon,
                  answer: items[i].answer,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Target Distance:',
                style: AppTextStyle.roboto(
                    fontWeight: FontWeight.w500, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        GradientBorderContainer(
                          borderRadius: 20,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                          child: GestureDetector(
                            onTap: () => _showDistancePicker(true),
                            child: Container(
                              width: 70,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xff716B6B66),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  shortestDistance.toString(),
                                  style: AppTextStyle.oswald(fontSize: 30),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Shortest Target Distance',
                          style: AppTextStyle.roboto(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Text('TO'),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        GradientBorderContainer(
                          borderRadius: 20,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                          child: GestureDetector(
                            onTap: () => _showDistancePicker(false),
                            child: Container(
                              width: 70,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xff716B6B66),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  longestDistance.toString(),
                                  style: AppTextStyle.oswald(fontSize: 30),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Longest Target Distance',
                          style: AppTextStyle.roboto(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                "The Longest Target Distance must be\nat least 50 yards greater than the Shortest\nTarget Distance",
                style: AppTextStyle.roboto(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Shot Count",
                  style: AppTextStyle.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _buildShotCountSlider(context),
              const SizedBox(height: 20),
              SessionViewButton(
                onSessionClick: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomCombineStartPage(),
                    ),
                  );
                },
                buttonText: "Start",
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  void _showDistancePicker(bool isShortest) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (context) {
        return GradientBorderContainer(
          containerHeight: 280,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  isShortest
                      ? 'Select Shortest Distance'
                      : 'Select Longest Distance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 50,
                  perspective: 0.005,
                  diameterRatio: 1.2,
                  physics: FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      if (isShortest) {
                        shortestDistance = index * 5;
                      } else {
                        longestDistance = index * 5;
                      }
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 121,
                    builder: (context, index) {
                      final value = index * 5;
                      return Center(
                        child: Text(
                          '$value yds',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShotCountSlider(
      BuildContext context,
      ) {
    return SfSliderTheme(
      data: SfSliderThemeData(
        activeLabelStyle:
        AppTextStyle.roboto(fontWeight: FontWeight.w500, fontSize: 16),
        inactiveLabelStyle: AppTextStyle.roboto(),
      ),
      child: SfSlider(
        activeColor: AppColors.primaryText,
        inactiveColor: AppColors.dividerColor,
        min: 10,
        max: 100,
        value: shotCount,
        interval: 10,
        showLabels: true,
        showDividers: true,
        onChanged: (dynamic value) {
          setState(() {
            shotCount = value.toInt();
          });
          // context.read<TargetZoneBloc>().add(
          //   ShotCountChanged(value.toInt()),
          // );
        },
      ),
    );
  }

}
