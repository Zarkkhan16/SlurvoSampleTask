import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/combine_test/games/wedge_combine_test/presentation/pages/wedge_combine_summary_page.dart';
import 'package:onegolf/feature/combine_test/presentation/widget/custom_score_bar.dart';
import 'package:onegolf/feature/widget/bottom_nav_bar.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/glassmorphism_card.dart';
import 'package:onegolf/feature/widget/gradient_border_container.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import 'package:onegolf/feature/widget/session_view_button.dart';

import '../bloc/wedge_combine_bloc.dart';
import '../bloc/wedge_combine_event.dart';
import '../bloc/wedge_combine_state.dart';

// class WedgeCombineStartPage extends StatefulWidget {
//   const WedgeCombineStartPage({super.key});
//
//   @override
//   State<WedgeCombineStartPage> createState() => _WedgeCombineStartPageState();
// }
//
// class _WedgeCombineStartPageState extends State<WedgeCombineStartPage> {
//
//   @override
//   void initState() {
//     super.initState();
//     context.read<WedgeCombineBloc>().add(WedgeCombineStartedEvent());
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBackground,
//       appBar: CustomAppBar(),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
//         child: Column(
//           children: [
//             HeaderRow(headingName: "Wedge Combine Test"),
//             Text(
//               "Test. Score. Improve",
//               style: AppTextStyle.roboto(),
//             ),
//             SizedBox(height: 10),
//             GradientBorderContainer(
//               borderRadius: 16,
//               padding: EdgeInsets.symmetric(vertical: 20),
//               containerWidth: double.infinity,
//               child: Column(
//                 children: [
//                   Text(
//                     'Target Carry',
//                     style: AppTextStyle.roboto(
//                       color: AppColors.secondaryText,
//                       fontSize: 16,
//                     ),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     "100.0",
//                     style: AppTextStyle.oswald(
//                       fontWeight: FontWeight.w700,
//                       fontSize: 40,
//                     ),
//                   ),
//                   Text(
//                     'yds',
//                     style: AppTextStyle.roboto(
//                       fontSize: 16,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20),
//             GradientBorderContainer(
//               borderRadius: 16,
//               padding: EdgeInsets.symmetric(vertical: 20),
//               containerWidth: double.infinity,
//               child: Column(
//                 children: [
//                   Text(
//                     'Actual Carry',
//                     style: AppTextStyle.roboto(
//                       color: AppColors.secondaryText,
//                       fontSize: 16,
//                     ),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     "0.0",
//                     style: AppTextStyle.oswald(
//                       fontWeight: FontWeight.w700,
//                       fontSize: 40,
//                     ),
//                   ),
//                   Text(
//                     'yds',
//                     style: AppTextStyle.roboto(
//                       fontSize: 16,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 GradientBorderContainer(
//                   padding: EdgeInsets.symmetric(vertical: 10),
//                   containerHeight: 123,
//                   containerWidth: 176,
//                   borderRadius: 16,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(
//                         "- 0.0",
//                         style: AppTextStyle.oswald(
//                           fontSize: 30,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       Text(
//                         "Distance From Target",
//                         style: AppTextStyle.roboto(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       Text(
//                         "YDS",
//                         style: AppTextStyle.roboto(
//                           fontSize: 16,
//                           color: AppColors.secondaryText,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 GradientBorderContainer(
//                   containerHeight: 123,
//                   containerWidth: 176,
//                   borderRadius: 16,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(
//                         "- 0.0",
//                         style: AppTextStyle.oswald(
//                           fontSize: 30,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       Text(
//                         "Shot Score",
//                         style: AppTextStyle.roboto(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       Text(
//                         "PTS",
//                         style: AppTextStyle.roboto(
//                           fontSize: 16,
//                           color: AppColors.secondaryText,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             Text(
//               "Projected Score",
//               style: AppTextStyle.roboto(
//                 color: AppColors.secondaryText,
//                 fontSize: 16,
//               ),
//             ),
//             SizedBox(height: 10),
//             CustomScoreBar(
//               value: 0.0,
//               textStyle: AppTextStyle.roboto(
//                 fontWeight: FontWeight.w700,
//                 fontSize: 18,
//                 color: AppColors.buttonText,
//               ),
//               min: 0.0,
//               max: 100.0,
//               height: 24,
//             ),
//             SizedBox(height: 20),
//             SessionViewButton(
//               onSessionClick: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => WedgeCombineSummaryPage(),
//                   ),
//                 );
//               },
//               buttonText: "Finish Session",
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class WedgeCombineStartPage extends StatefulWidget {
  const WedgeCombineStartPage({super.key});

  @override
  State<WedgeCombineStartPage> createState() => _WedgeCombineStartPageState();
}

class _WedgeCombineStartPageState extends State<WedgeCombineStartPage> {
  @override
  void initState() {
    super.initState();
    context.read<WedgeCombineBloc>().add(WedgeCombineStartedEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WedgeCombineBloc, WedgeCombineState>(
        listenWhen: (prev, curr) {
      if (!prev.shotJustPlayed && curr.shotJustPlayed) return true;

      // 🔥 Session finished → Summary
      if (!prev.isFinished && curr.isFinished) return true;

      return false;
    }, listener: (context, state) {
      if (state.shotJustPlayed) {
        final isLastShot = state.currentIndex + 1 >= state.shots.length;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              padding: EdgeInsets.zero,
              duration: const Duration(milliseconds: 2500),
              content: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Success Icon with animated feel
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Text Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Shot ${state.currentIndex + 1} Complete',
                            style: AppTextStyle.roboto(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isLastShot ? 'Game ended' : 'Moving to next target',
                            style: AppTextStyle.roboto(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        return;
      }
      if (state.isFinished) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => WedgeCombineSummaryPage(),
          ),
        );
        return;
      }
    }, builder: (context, state) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: CustomAppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: BlocBuilder<WedgeCombineBloc, WedgeCombineState>(
            builder: (context, state) {
              if (state.shots.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final shot = state.currentShot;

              return Column(
                children: [
                  HeaderRow(
                    headingName: "Wedge Combine Test",
                    onBackButton: () {
                      context
                          .read<WedgeCombineBloc>()
                          .add(FinishSessionEvent());
                    },
                  ),
                  Text(
                    "Test. Score. Improve",
                    style: AppTextStyle.roboto(),
                  ),
                  const SizedBox(height: 10),

                  /// TARGET CARRY
                  GradientBorderContainer(
                    borderRadius: 16,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    containerWidth: double.infinity,
                    child: Column(
                      children: [
                        Text(
                          'Target Carry',
                          style: AppTextStyle.roboto(
                            color: AppColors.secondaryText,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          shot.targetCarry.toStringAsFixed(1),
                          style: AppTextStyle.oswald(
                            fontWeight: FontWeight.w700,
                            fontSize: 40,
                          ),
                        ),
                        Text(
                          'yds',
                          style: AppTextStyle.roboto(fontSize: 16),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ACTUAL CARRY
                  GradientBorderContainer(
                    borderRadius: 16,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    containerWidth: double.infinity,
                    child: Column(
                      children: [
                        Text(
                          'Actual Carry',
                          style: AppTextStyle.roboto(
                            color: AppColors.secondaryText,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (shot.actualCarry ?? 0).toStringAsFixed(1),
                          style: AppTextStyle.oswald(
                            fontWeight: FontWeight.w700,
                            fontSize: 40,
                          ),
                        ),
                        Text(
                          'yds',
                          style: AppTextStyle.roboto(fontSize: 16),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// DISTANCE + SCORE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GradientBorderContainer(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        containerHeight: 123,
                        containerWidth: 176,
                        borderRadius: 16,
                        child: Column(
                          children: [
                            Text(
                              shot.distanceFromTarget == null
                                  ? '0.0'
                                  : shot.distanceFromTarget!.toStringAsFixed(1),
                              style: AppTextStyle.oswald(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "Distance From Target",
                              style: AppTextStyle.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "YDS",
                              style: AppTextStyle.roboto(
                                fontSize: 16,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GradientBorderContainer(
                        containerHeight: 123,
                        containerWidth: 176,
                        borderRadius: 16,
                        child: Column(
                          children: [
                            Text(
                              shot.score?.toString() ?? '0',
                              style: AppTextStyle.oswald(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "Shot Score",
                              style: AppTextStyle.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "PTS",
                              style: AppTextStyle.roboto(
                                fontSize: 16,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// PROJECTED SCORE
                  Text(
                    "Projected Score",
                    style: AppTextStyle.roboto(
                      color: AppColors.secondaryText,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomScoreBar(
                    value: state.projectedScore,
                    min: 0,
                    max: 100,
                    height: 24,
                    textStyle: AppTextStyle.roboto(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColors.buttonText,
                    ),
                  ),
                  SizedBox(height: 20),
                  SessionViewButton(
                    onSessionClick: () {
                      context
                          .read<WedgeCombineBloc>()
                          .add(FinishSessionEvent());
                    },
                    buttonText: "Finish Session",
                  ),
                ],
              );
            },
          ),
        ),
      );
    });
  }
}
