// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:onegolf/feature/home_screens/presentation/widgets/header/header_row.dart';
// import '../../../../core/constants/app_colors.dart';
// import '../../../home_screens/presentation/widgets/bottom_nav_bar/bottom_nav_bar.dart';
// import '../../../home_screens/presentation/widgets/card/glassmorphism_card.dart';
// import '../../../home_screens/presentation/widgets/custom_app_bar/custom_app_bar.dart';
// import '../../data/model/shot_anaylsis_model.dart';
// import '../bloc/golf_device_bloc.dart';
// import '../bloc/golf_device_event.dart';
// import '../bloc/golf_device_state.dart';
//
// class ShotHistoryScreen extends StatelessWidget {
//   const ShotHistoryScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     context.read<GolfDeviceBloc>().add(LoadShotHistoryEvent());
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       bottomNavigationBar: const BottomNavBar(),
//       appBar: CustomAppBar(),
//       body: BlocBuilder<GolfDeviceBloc, GolfDeviceState>(
//         builder: (context, state) {
//           if (state is ShotHistoryLoadingState) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const CircularProgressIndicator(
//                     color: Colors.white,
//                     strokeWidth: 3,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Loading shots...',
//                     style: TextStyle(
//                       color: Colors.grey[400],
//                       fontSize: 16,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           if (state is ShotHistoryErrorState) {
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(32.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(24),
//                       decoration: BoxDecoration(
//                         color: Colors.red.withOpacity(0.1),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.error_outline_rounded,
//                         color: Colors.redAccent,
//                         size: 64,
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     Text(
//                       'Oops! Something went wrong',
//                       style: TextStyle(
//                         color: Colors.grey[300],
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       state.message,
//                       style: TextStyle(
//                         color: Colors.grey[500],
//                         fontSize: 14,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 32),
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         context
//                             .read<GolfDeviceBloc>()
//                             .add(LoadShotHistoryEvent());
//                       },
//                       icon: const Icon(Icons.refresh_rounded),
//                       label: const Text('Try Again'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.tealAccent,
//                         foregroundColor: Colors.black,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 32, vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         elevation: 0,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }
//
//           if (state is ShotHistoryLoadedState) {
//             if (state.shots.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(32),
//                       decoration: BoxDecoration(
//                         color: Colors.tealAccent.withOpacity(0.1),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.golf_course_rounded,
//                         color: Colors.tealAccent,
//                         size: 80,
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     Text(
//                       'No Shots Yet',
//                       style: TextStyle(
//                         color: Colors.grey[300],
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       'Start recording your shots\nto see them here',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.grey[500],
//                         fontSize: 16,
//                         height: 1.5,
//                       ),
//                     ),
//                     const SizedBox(height: 32),
//                     ElevatedButton.icon(
//                       onPressed: () => Navigator.pop(context),
//                       icon: const Icon(Icons.add_circle_outline_rounded),
//                       label: const Text('Start Recording'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.tealAccent,
//                         foregroundColor: Colors.black,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 32, vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         elevation: 0,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }
//
//             return Column(
//               children: [
//                 Divider(thickness: 1, color: AppColors.dividerColor),
//                 Expanded(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                     child: Column(
//                       children: [
//                         HeaderRow(
//                           headingName: "Session View",
//                         ),
//                         Expanded(
//                           child: GridView.builder(
//                             padding: EdgeInsets.all(16),
//                             gridDelegate:
//                             SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 2,
//                               crossAxisSpacing: 30,
//                               mainAxisSpacing: 20,
//                               childAspectRatio: 1.42,
//                             ),
//                             itemCount: 4,
//                             itemBuilder: (context, index) {
//                               final metrics = [
//                                 {
//                                   "metric": "Club Speed",
//                                   "value": '23.32',
//                                   "unit": "MPH"
//                                 },
//                                 {
//                                   "metric": "Ball Speed",
//                                   "value": '23.32',
//                                   "unit": "MPH"
//                                 },
//                                 {
//                                   "metric": "Carry Distance",
//                                   "value": '23.23',
//                                   "unit": "YDS"
//                                 },
//                                 {
//                                   "metric": "Smash Factor",
//                                   "value": '1.4',
//                                   "unit": ""
//                                 },
//                                 // {
//                                 //   "metric": "Total Distance",
//                                 //   "value": state.golfData.totalDistance
//                                 //       .toStringAsFixed(1),
//                                 //   "unit": state.units ? "M" : "YDS"
//                                 // },
//                               ];
//                               return GlassmorphismCard(
//                                 value: metrics[index]["value"]!,
//                                 name: metrics[index]["metric"]!,
//                                 unit: metrics[index]["unit"]!,
//                               );
//                             },
//                           ),
//                         ),
//                         // ListView(
//                         //   padding: const EdgeInsets.all(16),
//                         //   children: [
//                         //     const SizedBox(height: 16),
//                         //     ShotHistoryTable(shots: state.shots),
//                         //   ],
//                         // ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           }
//
//           return const SizedBox();
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:onegolf/core/constants/app_strings.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/golf_device/presentation/widgets/shot_comparison_button.dart';
import 'package:onegolf/feature/home_screens/presentation/widgets/buttons/session_view_button.dart';
import 'package:onegolf/feature/home_screens/presentation/widgets/custom_bar/custom_bar.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../home_screens/presentation/widgets/bottom_nav_bar/bottom_nav_bar.dart';
import '../../../home_screens/presentation/widgets/card/glassmorphism_card.dart';
import '../../../home_screens/presentation/widgets/custom_app_bar/custom_app_bar.dart';
import '../../../home_screens/presentation/widgets/header/header_row.dart';
import '../bloc/bloc/shot_selection_bloc.dart';
import '../bloc/bloc/shot_selection_event.dart';
import '../bloc/bloc/shot_selection_state.dart';
import '../bloc/golf_device_bloc.dart';
import '../bloc/golf_device_event.dart';
import '../bloc/golf_device_state.dart';

class ShotHistoryScreen extends StatelessWidget {
  const ShotHistoryScreen({super.key});

  String _formatDate(String? date, String? time) {
    if (date == null || date.isEmpty) return '';

    try {
      final parsedDate = DateTime.parse(date);
      final formattedDate = DateFormat('MMM d').format(parsedDate);
      if (time != null && time.isNotEmpty) {
        final timeParts = time.split(':');
        if (timeParts.length >= 2) {
          final minutes = int.tryParse(timeParts[1]) ?? 0;
          return '$formattedDate • $minutes mins';
        }
      }
      return formattedDate;
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    context.read<GolfDeviceBloc>().add(LoadShotHistoryEvent());

    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const BottomNavBar(),
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: BlocBuilder<GolfDeviceBloc, GolfDeviceState>(
          builder: (context, state) {
            if (state is DisconnectingState) {
              return const Scaffold(
                backgroundColor: Colors.black54,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Disconnecting device...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is ShotHistoryLoadingState) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading shots...',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is ShotHistoryErrorState) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          color: Colors.redAccent,
                          size: 64,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Oops! Something went wrong',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          context
                              .read<GolfDeviceBloc>()
                              .add(LoadShotHistoryEvent());
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is ShotHistoryLoadedState) {
              if (state.shots.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.tealAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.golf_course_rounded,
                          color: Colors.grey,
                          size: 80,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No Shots Yet',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return BlocProvider(
                create: (context) =>
                    ShotSelectionBloc(state.shots)..add(LoadInitialShotEvent()),
                child: Column(
                  children: [
                    Divider(thickness: 1, color: AppColors.dividerColor),
                    BlocBuilder<ShotSelectionBloc, ShotSelectionState>(
                      builder: (context, selectionState) {
                        return Column(
                          children: [
                            HeaderRow(
                              headingName: "Session View",
                              goScanScreen: false,
                              onBackButton: (){
                                // print("again back");
                                Navigator.pop(context, 'connected');
                              },

                            ),
                            Text(
                              _formatDate(selectionState.selectedShot?.date,
                                  selectionState.selectedShot?.sessionTime),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    BlocBuilder<ShotSelectionBloc, ShotSelectionState>(
                      builder: (context, selectionState) {
                        final shot = selectionState.selectedShot;
                        return Expanded(
                          child: GridView.builder(
                            // padding: EdgeInsets.all(16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 30,
                              mainAxisSpacing: 20,
                              childAspectRatio: 1.60,
                            ),
                            itemCount: 4,
                            itemBuilder: (context, index) {
                              final metrics = [
                                {
                                  "metric": "Club Speed",
                                  "value": shot?.clubSpeed.toStringAsFixed(1),
                                  "unit": "MPH"
                                },
                                {
                                  "metric": "Ball Speed",
                                  "value": shot?.ballSpeed.toStringAsFixed(1),
                                  "unit": "MPH"
                                },
                                {
                                  "metric": "Carry Distance",
                                  "value":
                                      shot?.carryDistance.toStringAsFixed(1),
                                  "unit": "YDS"
                                },
                                {
                                  "metric": "Smash Factor",
                                  "value": shot?.smashFactor.toStringAsFixed(1),
                                  "unit": ""
                                },
                              ];
                              return GlassmorphismCard(
                                value: metrics[index]["value"]!,
                                name: metrics[index]["metric"]!,
                                unit: metrics[index]["unit"]!,
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomizeBar(),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ShotComparisonButton(
                              headingText: "Shot Comparison"),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ShotComparisonButton(
                            headingText: "Dispersion",
                            icon: Icons.my_location,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 5),
                      child: Row(
                        children: [
                          // const SizedBox(width: 5),
                          _buildHeaderCell('Shot', '#', flex: 1),
                          // const SizedBox(width: 15),
                          _buildHeaderCell('Club\nSpeed', 'mph', flex: 1),
                          _buildHeaderCell('Ball\nSpeed', 'deg', flex: 1),
                          _buildHeaderCell('Smash\nFactor', 'rmp', flex: 1),
                          _buildHeaderCell('Carry\nDistance', 'ft', flex: 1),
                          _buildHeaderCell('Total\nDistance', 'yds', flex: 1),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child:
                            BlocBuilder<ShotSelectionBloc, ShotSelectionState>(
                          builder: (context, selectionState) {
                            return ListView.builder(
                              padding:
                                  const EdgeInsets.only(top: 5, bottom: 20),
                              itemCount: state.shots.length,
                              itemBuilder: (context, index) {
                                final shot = state.shots[index];
                                final isSelected =
                                    index == selectionState.selectedIndex;

                                return InkWell(
                                  onTap: () {
                                    context
                                        .read<ShotSelectionBloc>()
                                        .add(SelectShotEvent(index));
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                    child: Row(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 25,
                                              height: 25,
                                              decoration: const BoxDecoration(
                                                color: Colors.teal,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  AppStrings.getClub(
                                                      shot.clubName),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              ' ${shot.shotNumber.toString()}',
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 8),
                                        // _buildDataCell(
                                        //     shot.shotNumber.toString(),
                                        //     isSelected,
                                        //     flex: 1),
                                        _buildDataCell(
                                            shot.clubSpeed.toStringAsFixed(1),
                                            isSelected,
                                            flex: 1),
                                        _buildDataCell(
                                            shot.ballSpeed.toStringAsFixed(1),
                                            isSelected,
                                            flex: 1),
                                        _buildDataCell(
                                            shot.smashFactor.toStringAsFixed(1),
                                            isSelected,
                                            flex: 1),
                                        _buildDataCell(
                                            shot.carryDistance
                                                .toStringAsFixed(1),
                                            isSelected,
                                            flex: 1),
                                        _buildDataCell(
                                            shot.totalDistance
                                                .toStringAsFixed(1),
                                            isSelected,
                                            flex: 1),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SessionViewButton(
                      onSessionClick: () {
                        context.read<GolfDeviceBloc>().add(
                          DisconnectDeviceEvent(navigateToLanding: true),
                        );
                      },
                      buttonText: 'End Session',
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, String subTitle, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Column(
        children: [
          Text(
            text,
            style: AppTextStyle.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subTitle,
            style: AppTextStyle.roboto(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: AppColors.unselectedIcon,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDataCell(String text, bool isSelected, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
