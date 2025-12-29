import 'package:flutter/material.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/bottom_controller.dart';
import 'package:onegolf/feature/combine_test/presentation/pages/combine_test_page.dart';
import 'package:onegolf/feature/widget/bottom_nav_bar.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/gradient_border_container.dart';
import 'package:onegolf/feature/widget/header_row.dart';

class WedgeCombineSummaryPage extends StatelessWidget {
  const WedgeCombineSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tableHeaders = ['Range', 'Score', 'Handicap'];
    final tableData = [
      ['40-49', '15', '59'],
      ['50-59', '17', '74'],
      ['60-69', '12', '87'],
      ['70-79', '9', '96'],
      ['80-89', '8', '117'],
      ['90-99', '8', '118'],
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CustomAppBar(),
      // bottomNavigationBar: BottomNavBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: SingleChildScrollView(
          child: Column(
            children: [
              HeaderRow(headingName: "Combine Test Summary"),
              const SizedBox(height: 10),
              // Score in a circle
              Center(
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text("80",
                      style: AppTextStyle.oswald(
                        fontSize: 50,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ),
              const SizedBox(height: 15),
              // Performance Insights box
              GradientBorderContainer(
                containerWidth: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text("Performance Insights",
                          style: AppTextStyle.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Average Distance From Target",
                      style: AppTextStyle.roboto(
                        color: AppColors.secondaryText,
                        height: 1.5,
                      ),
                    ),
                    Text(
                      "Strongest Distance",
                      style: AppTextStyle.roboto(
                        color: AppColors.secondaryText,
                        height: 1.5,
                      ),
                    ),
                    Text(
                      "Biggest Area For improvement",
                      style: AppTextStyle.roboto(
                        color: AppColors.secondaryText,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              // Table
              GradientBorderContainer(
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1.5),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1.2),
                  },
                  border: TableBorder(
                    horizontalInside: BorderSide(color: Colors.grey[800]!),
                  ),
                  children: [
                    // Header
                    TableRow(
                      decoration: BoxDecoration(
                        // color: const Color(0xFF232323),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      children: tableHeaders
                          .map((header) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 13.0),
                                child: Center(
                                  child: Text(
                                    header,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    // Data rows
                    ...tableData.map(
                      (row) => TableRow(
                        children: row
                            .map(
                              (cell) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Center(
                                  child: Text(
                                    cell,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              // Bottom buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(
                          "Share Score",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.buttonText,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // BottomNavController.goToTab(2); // Ensure tab is correct
                          // Navigator.of(context).popUntil((route) => route.isFirst); // Back to root
                          Navigator.of(context).popUntil((route) => route.isFirst); // go back to PracticeGamesScreen
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              settings: RouteSettings(name: 'CombineTestPage'),
                              builder: (context) => CombineTestPage(),
                            ),
                          );
                          // Navigator.of(context).pushAndRemoveUntil(
                          //   MaterialPageRoute(builder: (context) => CombineTestPage()),
                          //       (route) => route.settings.name == 'PracticeGamesScreen',
                          // );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          "Start Again",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            color: AppColors.buttonText,),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
