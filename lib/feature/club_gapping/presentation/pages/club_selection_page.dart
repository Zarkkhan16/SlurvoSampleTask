import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/club_gapping/presentation/pages/shot_recording_page.dart';
import 'package:onegolf/feature/widget/bottom_nav_bar.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/gradient_border_container.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import 'package:onegolf/feature/widget/session_view_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../practice_games/presentation/widgets/shot_option.dart';
import '../../domain/entities/club_entity.dart';
import '../bloc/club_gapping_bloc.dart';
import '../bloc/club_gapping_event.dart';
import '../bloc/club_gapping_state.dart';

class ClubSelectionScreen extends StatefulWidget {
  const ClubSelectionScreen({super.key});

  @override
  State<ClubSelectionScreen> createState() => _ClubSelectionScreenState();
}

class _ClubSelectionScreenState extends State<ClubSelectionScreen> {
  final TextEditingController customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ClubGappingBloc>().add(LoadAvailableClubsEvent());
  }

  @override
  void dispose() {
    customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClubGappingBloc, ClubGappingState>(
      builder: (context, state) {
        if (state is ClubGappingLoading) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        if (state is! ClubSelectionState) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: Text('Loading...')),
          );
        }

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: CustomAppBar(),
          bottomNavigationBar: BottomNavBar(),
          body: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HeaderRow(headingName: "Club Gapping"),
                  Text(
                    'Discover and dial in your carry distance for\neach club',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.roboto(),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildCategorySection(
                          'WOODS',
                          state.availableClubs
                              .where((c) => c.category == ClubCategory.woods)
                              .toList(),
                          context,
                        ),
                        SizedBox(height: 10),
                        _buildCategorySection(
                          'HYBRIDS',
                          state.availableClubs
                              .where((c) => c.category == ClubCategory.hybrids)
                              .toList(),
                          context,
                        ),
                        SizedBox(height: 10),
                        _buildCategorySection(
                          'IRONS',
                          state.availableClubs
                              .where((c) => c.category == ClubCategory.irons)
                              .toList(),
                          context,
                        ),
                        SizedBox(height: 10),
                        _buildCategorySection(
                          'WEDGES',
                          state.availableClubs
                              .where((c) => c.category == ClubCategory.wedges)
                              .toList(),
                          context,
                        ),
                        SizedBox(height: 5),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shots Per Club:',
                        style: AppTextStyle.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          ShotOption(
                            text: ' 3 ',
                            isSelected: state.shotsPerClub == 3 &&
                                !state.isCustomSelected,
                            onTap: () => context.read<ClubGappingBloc>().add(
                                  UpdateShotsPerClubEvent(3),
                                ),
                          ),
                          const SizedBox(width: 8),
                          ShotOption(
                            text: ' 5 ',
                            isSelected: state.shotsPerClub == 5 &&
                                !state.isCustomSelected,
                            onTap: () => context.read<ClubGappingBloc>().add(
                                  UpdateShotsPerClubEvent(5),
                                ),
                          ),
                          const SizedBox(width: 8),
                          ShotOption(
                            text: ' 7 ',
                            isSelected: state.shotsPerClub == 7 &&
                                !state.isCustomSelected,
                            onTap: () => context.read<ClubGappingBloc>().add(
                                  UpdateShotsPerClubEvent(7),
                                ),
                          ),
                          const SizedBox(width: 8),
                          ShotOption(
                            text: 'Custom',
                            isSelected: state.isCustomSelected,
                            onTap: () {
                              context
                                  .read<ClubGappingBloc>()
                                  .add(SelectCustomShotsEvent());
                              customController.clear();
                            },
                          ),
                        ],
                      ),
                      if (state.isCustomSelected) ...[
                        const SizedBox(height: 12),
                        GradientBorderContainer(
                          borderRadius: 12,
                          backgroundColor: AppColors.cardBackground,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          child: SizedBox(
                            height: 36,
                            child: TextField(
                              controller: customController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              style: AppTextStyle.roboto(
                                  color: AppColors.primaryText),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 10),
                                border: InputBorder.none,
                                hintText: "Enter number of shots per club",
                                hintStyle: AppTextStyle.roboto(
                                  color: AppColors.secondaryText,
                                  fontSize: 14,
                                ),
                              ),
                              onChanged: (value) {
                                final int? entered = int.tryParse(value);
                                if (entered != null) {
                                  // if (entered > 10) {
                                  //   customController.text = '10';
                                  //   customController.selection =
                                  //       TextSelection.fromPosition(
                                  //     TextPosition(
                                  //         offset: customController.text.length),
                                  //   );
                                  //   context
                                  //       .read<ClubGappingBloc>()
                                  //       .add(UpdateShotsPerClubEvent(10));
                                  // } else {
                                    context
                                        .read<ClubGappingBloc>()
                                        .add(UpdateShotsPerClubEvent(entered));
                                  // }
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    "We'll record carry distances and highlight\ngaps that are too narrow or too wide. Ideal\nspacing is 15-18 yards.",
                    textAlign: TextAlign.center,
                    style: AppTextStyle.roboto(),
                  ),
                  SizedBox(height: 10),
                  if (state.canStartSession)
                    SessionViewButton(
                      onSessionClick: () {
                        context.read<ClubGappingBloc>().add(
                              StartGappingSessionEvent(
                                selectedClubs: state.selectedClubs,
                                shotsPerClub: state.shotsPerClub,
                              ),
                            );
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (_) => BlocProvider.value(
                        //       value: context.read<ClubGappingBloc>(),
                        //       child: ShotRecordingScreen(),
                        //     ),
                        //   ),
                        // );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: const RouteSettings(name: "ShotRecordingScreen"),
                            builder: (_) => BlocProvider.value(
                              value: context.read<ClubGappingBloc>(),
                              child: ShotRecordingScreen(),
                            ),
                          ),
                        );                      },
                      buttonText: "Start Gapping Session",
                    ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategorySection(
    String category,
    List<ClubEntity> clubs,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(category,
            style: AppTextStyle.roboto(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            )),
        SizedBox(height: 5),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 4,
          ),
          itemCount: clubs.length,
          itemBuilder: (context, index) {
            final club = clubs[index];
            return _buildClubTile(club, context);
          },
        ),
      ],
    );
  }

  Widget _buildClubTile(ClubEntity club, BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<ClubGappingBloc>().add(
              ToggleClubSelectionEvent(club.id),
            );
      },
      child: GradientBorderContainer(
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: club.isSelected ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: club.isSelected ? Colors.white : Colors.grey,
                  width: 2,
                ),
              ),
              child: club.isSelected
                  ? Icon(
                      Icons.check,
                      color: Colors.black,
                      size: 14,
                    )
                  : null,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                club.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight:
                      club.isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
