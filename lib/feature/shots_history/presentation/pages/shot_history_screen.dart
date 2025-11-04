import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:onegolf/feature/golf_device/presentation/bloc/golf_device_bloc.dart';
import 'package:onegolf/feature/golf_device/presentation/bloc/golf_device_state.dart';
import 'package:onegolf/feature/shots_history/presentation/bloc/shot_selection_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../../../core/di/injection_container.dart';
import '../../../choose_club_screen/model/club_model.dart';
import '../../../golf_device/presentation/bloc/golf_device_event.dart';
import '../../../golf_device/presentation/pages/dispersion_screen.dart';
import '../../../golf_device/presentation/pages/session_summary_screen.dart';
import '../../../golf_device/presentation/widgets/shot_comparison_button.dart';
import '../../../widget/bottom_nav_bar.dart';
import '../../../widget/action_button.dart';
import '../../../widget/glassmorphism_card.dart';
import '../../../widget/custom_app_bar.dart';
import '../../../widget/custom_bar.dart';
import '../../../widget/header_row.dart';
import '../bloc/shot_selection_bloc.dart';
import '../bloc/shot_selection_event.dart';
import 'comparison_screen.dart';
import 'filter_screen.dart';

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

  Future<void> _openFilterScreen(
      BuildContext context, ShotHistoryLoadedState state) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterScreen(
          selectedClubs: state.selectedClubs,
        ),
      ),
    );

    if (result != null && context.mounted) {
      print(
          '🎯 Filter result received: ${(result as List<Club>).map((c) => '${c.name} (${c.code})').join(", ")}');
      context.read<ShotHistoryBloc>().add(UpdateFilterEvent(result));
    } else {
      print('❌ No filter result or context not mounted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GolfDeviceBloc, GolfDeviceState>(
        listener: (context, state) {
      if (state is NavigateToSessionSummaryState) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SessionSummaryScreen(
              summaryData: state.summaryData,
            ),
          ),
        );
      }
    }, builder: (context, state) {
      if (state is DisconnectingState) {
        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );
      }
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            Navigator.pop(context, 'connected');
          }
        },
        child: BlocProvider(
          create: (context) =>
              sl<ShotHistoryBloc>()..add(const LoadShotHistoryEvent()),
          child: Scaffold(
            backgroundColor: Colors.black,
            bottomNavigationBar: const BottomNavBar(),
            appBar: CustomAppBar(),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: BlocListener<ShotHistoryBloc, ShotHistoryState>(
                listener: (context, state) {
                 if (state is ShotHistoryClearedState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'All records cleared successfully',
                          style: AppTextStyle.roboto(
                              fontSize: 14, color: Colors.white),
                        ),
                        backgroundColor: Colors.black,
                      ),
                    );
                    context
                        .read<ShotHistoryBloc>()
                        .add(const LoadShotHistoryEvent());
                  }
                },
                child: BlocBuilder<ShotHistoryBloc, ShotHistoryState>(
                  builder: (context, state) {
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
                              const SizedBox(height: 12),
                              Text(
                                state.message,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton.icon(
                                onPressed: () {
                                  context
                                      .read<ShotHistoryBloc>()
                                      .add(const LoadShotHistoryEvent());
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

                    if (state is ClearingRecordState) {
                      return const Scaffold(
                        backgroundColor: Colors.black,
                        body: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 16),
                              Text(
                                'Clearing all records...',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    if (state is ShotHistoryLoadedState) {
                      if (state.shots.isEmpty) {
                        return Column(
                          children: [
                            HeaderRow(
                              headingName: "Session View",
                              goScanScreen: false,
                              onBackButton: () {
                                Navigator.pop(context, 'connected');
                              },
                            ),
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(32),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.tealAccent.withOpacity(0.1),
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
                              ),
                            ),
                          ],
                        );
                      }

                      return _buildShotHistoryContent(context, state);
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildShotHistoryContent(
      BuildContext context, ShotHistoryLoadedState state) {
    final filteredShots = state.filteredShots;
    return Column(
      children: [
        Column(
          children: [
            HeaderRow(
              headingName: "Session View",
              goScanScreen: false,
              onBackButton: () {
                Navigator.pop(context, 'connected');
              },
            ),
            Text(
              _formatDate(
                  state.selectedShot?.date, state.selectedShot?.sessionTime),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 30,
              mainAxisSpacing: 15,
              childAspectRatio: 1.7,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              final shot = state.selectedShot;
              final metrics = [
                {
                  "metric": "Club Speed",
                  "value": shot?.clubSpeed.toStringAsFixed(1) ?? '0.0',
                  "unit": "MPH"
                },
                {
                  "metric": "Ball Speed",
                  "value": shot?.ballSpeed.toStringAsFixed(1) ?? '0.0',
                  "unit": "MPH"
                },
                {
                  "metric": "Carry Distance",
                  "value": shot?.carryDistance.toStringAsFixed(1) ?? '0.0',
                  "unit": "YDS"
                },
                {
                  "metric": "Smash Factor",
                  "value": shot?.smashFactor.toStringAsFixed(1) ?? '0.0',
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
        ),
        const SizedBox(height: 10),
        CustomizeBar(
          headingText: state.selectedClubs.isEmpty
              ? 'Filter'
              : 'Filter (${state.selectedClubs.length})',
          onPressed: () {
            _openFilterScreen(context, state);
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ShotComparisonButton(
                headingText: "Shot Comparison",
                svgAssetPath: AppImages.analysisIcon,
                onTap: () {
                  final state = context.read<ShotHistoryBloc>().state;
                  if (state is ShotHistoryLoadedState) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ComparisonScreen(
                          shots: state.shots,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ShotComparisonButton(
                headingText: "Dispersion",
                svgAssetPath: AppImages.groupIcon,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<GolfDeviceBloc>(),
                        child: DispersionScreen(
                          selectedShot: state.selectedShot,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (filteredShots.isNotEmpty) _buildTableHeader(),
        Expanded(
          child: filteredShots.isEmpty
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.filter_alt_off,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No shots match the selected filters',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // ElevatedButton.icon(
                        //   onPressed: () {
                        //     context.read<ShotHistoryBloc>().add(
                        //       const UpdateFilterEvent([]),
                        //     );
                        //   },
                        //   icon: const Icon(Icons.clear_all),
                        //   label: const Text('Clear Filters'),
                        //   style: ElevatedButton.styleFrom(
                        //     backgroundColor: Colors.tealAccent,
                        //     foregroundColor: Colors.black,
                        //     padding: const EdgeInsets.symmetric(
                        //       horizontal: 24,
                        //       vertical: 12,
                        //     ),
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(25),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                )
              : Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 5, bottom: 20),
                    itemCount: filteredShots.length,
                    itemBuilder: (context, index) {
                      final shot = filteredShots[index];
                      final isSelected = index == state.selectedIndex;

                      return InkWell(
                        onTap: () {
                          context
                              .read<ShotHistoryBloc>()
                              .add(SelectShotEvent(index));
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.black : Colors.transparent,
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
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.cardBackground,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        AppStrings.getClub(shot.clubName),
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.black
                                              : Colors.white,
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
                              _buildDataCell(
                                  shot.clubSpeed.toStringAsFixed(1), isSelected,
                                  flex: 1),
                              _buildDataCell(
                                  shot.ballSpeed.toStringAsFixed(1), isSelected,
                                  flex: 1),
                              _buildDataCell(
                                  shot.smashFactor.toStringAsFixed(1),
                                  isSelected,
                                  flex: 1),
                              _buildDataCell(
                                  shot.carryDistance.toStringAsFixed(1),
                                  isSelected,
                                  flex: 1),
                              _buildDataCell(
                                  shot.totalDistance.toStringAsFixed(1),
                                  isSelected,
                                  flex: 1),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ActionButton(
                text: 'Clear Record',
                onPressed: () {
                  context.read<ShotHistoryBloc>().add(ClearRecordEvent());
                },
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ActionButton(
                text: 'Session End',
                buttonBackgroundColor: Colors.red,
                textColor: AppColors.primaryText,
                onPressed: () {
                  context.read<GolfDeviceBloc>().add(DisconnectDeviceEvent());
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Row(
        children: [
          _buildHeaderCell('Shot', '#', flex: 1),
          _buildHeaderCell('Club\nSpeed', 'mph', flex: 1),
          _buildHeaderCell('Ball\nSpeed', 'mph', flex: 1),
          _buildHeaderCell('Smash\nFactor', 'rmp', flex: 1),
          _buildHeaderCell('Carry\nDistance', 'yds', flex: 1),
          _buildHeaderCell('Total\nDistance', 'yds', flex: 1),
        ],
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
