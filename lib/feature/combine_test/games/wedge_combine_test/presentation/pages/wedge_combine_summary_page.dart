import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/bottom_controller.dart';
import 'package:onegolf/feature/combine_test/domain/entities/category_summary.dart';
import 'package:onegolf/feature/combine_test/games/wedge_combine_test/presentation/bloc/wedge_combine_bloc.dart';
import 'package:onegolf/feature/combine_test/games/wedge_combine_test/presentation/bloc/wedge_combine_state.dart';
import 'package:onegolf/feature/combine_test/presentation/pages/combine_test_page.dart';
import 'package:onegolf/feature/widget/bottom_nav_bar.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/gradient_border_container.dart';
import 'package:onegolf/feature/widget/header_row.dart';

import '../bloc/wedge_combine_event.dart';

class WedgeCombineSummaryPage extends StatelessWidget {
  const WedgeCombineSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WedgeCombineBloc, WedgeCombineState>(
      builder: (context, state) {
        if (state.shots.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final bloc = context.read<WedgeCombineBloc>();

        final finalScore = bloc.calculateFinalScore(state.shots).round();

        final categorySummary = bloc.buildCategorySummary(state.shots);
        for(final c in categorySummary){
          print("${c.rangeLabel} | ${c.averageScore} | ${c.handicap}");
        }

        return _SummaryScaffold(
          finalScore: finalScore,
          categorySummary: categorySummary,
        );
      },
    );
  }
}

class _SummaryScaffold extends StatelessWidget {
  final int finalScore;
  final List<CategorySummary> categorySummary;

  const _SummaryScaffold({
    required this.finalScore,
    required this.categorySummary,
  });

  @override
  Widget build(BuildContext context) {
    final tableHeaders = ['Range', 'Score', 'Handicap'];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: SingleChildScrollView(
          child: Column(
            children: [
              HeaderRow(headingName: "Combine Test Summary"),
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(finalScore.toString(),
                      style: AppTextStyle.oswald(
                        fontSize: 50,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ),
              const SizedBox(height: 15),
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
                    ...categorySummary.map(
                      (row) => TableRow(children: [
                        _cell(row.rangeLabel),
                        _cell(row.averageScore.round().toString()),
                        _cell(row.handicap),
                      ]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
                          context
                              .read<WedgeCombineBloc>()
                              .add(ResetWedgeCombineEvent());
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              settings: RouteSettings(name: 'CombineTestPage'),
                              builder: (context) => CombineTestPage(),
                            ),
                          );
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
                            color: AppColors.buttonText,
                          ),
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

  Widget _cell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
