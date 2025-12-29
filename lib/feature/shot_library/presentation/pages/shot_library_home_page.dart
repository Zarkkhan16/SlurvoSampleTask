import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_strings.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/shot_library/presentation/bloc/shot_library_bloc.dart';
import 'package:onegolf/feature/shot_library/presentation/bloc/shot_library_event.dart';
import 'package:onegolf/feature/shot_library/presentation/bloc/shot_library_state.dart';
import 'package:onegolf/feature/shot_library/presentation/pages/shot_library_filter_session_page.dart';
import 'package:onegolf/feature/shot_library/presentation/pages/shot_library_session_history_page.dart';
import 'package:onegolf/feature/shot_library/presentation/widgets/custom_data_value.dart';
import 'package:onegolf/feature/shot_library/presentation/widgets/row_tile_widget.dart';
import 'package:onegolf/feature/widget/bottom_nav_bar.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import 'package:onegolf/feature/widget/session_view_button.dart';

import '../../../golf_device/data/model/shot_anaylsis_model.dart';
import '../../../profile/presentation/pages/profile_screen.dart';

class ShotLibraryHomePage extends StatefulWidget {
  const ShotLibraryHomePage({super.key});

  @override
  State<ShotLibraryHomePage> createState() => _ShotLibraryHomePageState();
}

class _ShotLibraryHomePageState extends State<ShotLibraryHomePage> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CustomAppBar(
        onProfilePressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
            ),
          );
        },
      ),
      // bottomNavigationBar: BottomNavBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5),
        child: BlocBuilder<ShotLibraryBloc, ShotLibraryState>(
          builder: (context, state) {
            if(state.isLoading){
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              );
            }
            final groupedShots = state.shotsByDate;
            final sortedDates = groupedShots.keys.toList()
              ..sort((a, b) => b.compareTo(a));
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderRow(headingName: "Shot Library", backButtonHide: true,),
                SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomDataValue(
                        title: 'Total Shots',
                        subTitle: 'Logged',
                        value: state.totalShots.toString(),
                      ),
                      CustomDataValue(
                        title: 'Most Used',
                        subTitle: 'Club',
                        value: state.mostUsedClub == null ? "_":AppStrings.getClub(state.mostUsedClub ?? 0),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: state.shotsByDate.isEmpty
                      ? Center(child: Text("No shots found"))
                      : ListView.builder(
                          itemCount: sortedDates.length,
                          itemBuilder: (context, index) {
                            final date = sortedDates[index];
                            final shots = groupedShots[date]!;
                            final shotsBySession = groupBy(shots,
                                (ShotAnalysisModel s) => s.sessionNumber);
                            final sortedSessions = shotsBySession.keys.toList()
                              ..sort();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15.0, bottom: 8.0),
                                  child: Text(
                                  DateFormat('MMMM d, yyyy').format(DateTime.parse(date)),
                                    style: AppTextStyle.roboto(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Divider(
                                    color: AppColors.dividerColor, height: 1),
                                SizedBox(height: 10),
                                ...sortedSessions.map((sessionNumber) {
                                  final sessionShots =
                                      shotsBySession[sessionNumber]!;
                                  final shotCount = sessionShots.length;
                                  final uniqueGroups = sessionShots
                                      .map((e) => e.clubName)
                                      .toSet()
                                      .length;
                                  final isSessionFavorite = sessionShots
                                      .any((s) => s.isFavorite == true);

                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12.0),
                                    child: RowTileWidget(
                                      onTap: (){
                                        final sortedSessionShots = [...sessionShots]
                                          ..sort((a, b) => a.shotNumber.compareTo(b.shotNumber));

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ShotLibrarySessionHistoryPage(sessionShots: sortedSessionShots),
                                          ),
                                        );
                                      },
                                      onTapStar: (){

                                        context.read<ShotLibraryBloc>().add(
                                          ToggleSessionFavorite(
                                            userUid: user!.uid,
                                            date: date,
                                            sessionNumber: sessionNumber,
                                            isFavorite: !isSessionFavorite,
                                          ),
                                        );
                                      },
                                      name: "AONE",
                                      shotNumber: "$shotCount",
                                      groupNumber: "$uniqueGroups",
                                      isFavorite: isSessionFavorite,
                                      showDate: false,
                                    ),
                                  );
                                }),
                              ],
                            );
                          },
                        ),
                ),
                SizedBox(height: 10),
                SessionViewButton(
                  onSessionClick: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ShotLibraryFilterSessionPage(),
                      ),
                    );
                  },
                  buttonText: "Filter Sessions",
                ),
                SizedBox(height: 10),
              ],
            );
          },
        ),
      ),
    );
  }
}
