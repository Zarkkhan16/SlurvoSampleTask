import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/practice_games/presentation/bloc/practice_games_bloc.dart';
import 'package:onegolf/feature/practice_games/presentation/bloc/practice_games_state.dart';
import 'package:onegolf/feature/widget/gradient_border_container.dart';
import '../../../../core/constants/app_images.dart';
import '../../../widget/bottom_nav_bar.dart';
import '../../../widget/custom_app_bar.dart';
import '../../../widget/header_row.dart';
import '../../../widget/session_view_button.dart';
import '../bloc/practice_games_event.dart';
import '../widgets/add_player_chip.dart';
import '../widgets/add_player_dialog.dart';
import '../widgets/player_chip.dart';
import '../widgets/shot_option.dart';
import 'longest_drive_session_page.dart' hide SessionViewButton;

class LongestDriveMainPage extends StatefulWidget {
  const LongestDriveMainPage({super.key});

  @override
  State<LongestDriveMainPage> createState() => _LongestDriveMainPageState();
}

class _LongestDriveMainPageState extends State<LongestDriveMainPage> {
  final TextEditingController customController = TextEditingController();

  @override
  void dispose() {
    customController.dispose();
    super.dispose();
  }

  void _showAddPlayerDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AddPlayerDialog(
        onPlayerAdded: (name) {
          context.read<PracticeGamesBloc>().add(AddPlayerEvent(name));
        },
      ),
    );
  }

  void _showEditPlayerDialog(
      BuildContext context, int playerIndex, String currentName) {
    if (playerIndex == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot edit the primary player'),
          backgroundColor: Colors.white,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AddPlayerDialog(
        initialName: currentName,
        isEditing: true,
        onPlayerAdded: (newName) {
          context.read<PracticeGamesBloc>().add(
                EditPlayerEvent(
                  playerIndex: playerIndex,
                  newName: newName,
                ),
              );
        },
      ),
    );
  }

  void _showPlayerOptions(
      BuildContext context, int playerIndex, String playerName) {
    if (playerIndex == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('$playerName is the primary player and cannot be modified'),
          backgroundColor: Colors.white,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              playerName,
              style: AppTextStyle.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.edit, color: Colors.blue),
              title: Text(
                'Edit Name',
                style: AppTextStyle.roboto(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _showEditPlayerDialog(context, playerIndex, playerName);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text(
                'Remove Player',
                style: AppTextStyle.roboto(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                context.read<PracticeGamesBloc>().add(
                      RemovePlayerEvent(playerIndex),
                    );
              },
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: CustomAppBar(),
      bottomNavigationBar: BottomNavBar(),
      resizeToAvoidBottomInset: true,
      body: BlocBuilder<PracticeGamesBloc, PracticeGamesState>(
        builder: (context, state) {
          final isKeyboardVisible =
              MediaQuery.of(context).viewInsets.bottom > 0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderRow(
                    headingName: "Longest Drive",
                    onBackButton: () {
                      context
                          .read<PracticeGamesBloc>()
                          .add(ResetSessionEvent());
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 5),
                  Center(
                    child: Text(
                      "3 shots to hit your longest carry. Highest \nscore wins.",
                      style: AppTextStyle.roboto(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text(
                    'Players:',
                    style: AppTextStyle.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: [
                      ...state.players.asMap().entries.map((entry) {
                        final index = entry.key;
                        final playerName = entry.value;
                        return PlayerChip(
                          name: playerName,
                          onTap: () =>
                              _showPlayerOptions(context, index, playerName),
                          onLongPress: () =>
                              _showEditPlayerDialog(context, index, playerName),
                        );
                      }),
                      for (int i = state.players.length;
                          i < state.maxPlayers;
                          i++)
                        AddPlayerChip(
                          label: "+Player ${i + 1}",
                          onTap: () => _showAddPlayerDialog(context),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Number of Shots:',
                    style: AppTextStyle.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ShotOption(
                        text: ' 3 ',
                        isSelected:
                            state.selectedShots == 3 && !state.isCustomSelected,
                        onTap: () => context
                            .read<PracticeGamesBloc>()
                            .add(SelectShotsEvent(3)),
                      ),
                      const SizedBox(width: 8),
                      ShotOption(
                        text: ' 5 ',
                        isSelected:
                            state.selectedShots == 5 && !state.isCustomSelected,
                        onTap: () => context
                            .read<PracticeGamesBloc>()
                            .add(SelectShotsEvent(5)),
                      ),
                      const SizedBox(width: 8),
                      ShotOption(
                        text: ' 7 ',
                        isSelected:
                            state.selectedShots == 7 && !state.isCustomSelected,
                        onTap: () => context
                            .read<PracticeGamesBloc>()
                            .add(SelectShotsEvent(7)),
                      ),
                      const SizedBox(width: 8),
                      ShotOption(
                        text: 'Custom',
                        isSelected: state.isCustomSelected,
                        onTap: () {
                          context
                              .read<PracticeGamesBloc>()
                              .add(SelectCustomEvent());
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
                          style:
                              AppTextStyle.roboto(color: AppColors.primaryText),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 10),
                            border: InputBorder.none,
                            hintText: "Enter number (max 10)",
                            hintStyle: AppTextStyle.roboto(
                              color: AppColors.secondaryText,
                              fontSize: 14,
                            ),
                          ),
                          onChanged: (value) {
                            final num? entered = int.tryParse(value);
                            if (entered != null) {
                              if (entered > 10) {
                                customController.text = '10';
                                customController.selection =
                                    TextSelection.fromPosition(
                                  TextPosition(
                                      offset: customController.text.length),
                                );
                                context
                                    .read<PracticeGamesBloc>()
                                    .add(UpdateCustomShotsEvent('10'));
                              } else {
                                context
                                    .read<PracticeGamesBloc>()
                                    .add(UpdateCustomShotsEvent(value));
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  if (!isKeyboardVisible)
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Center(
                        child: Image.asset(AppImages.longestDriveImage),
                      ),
                    ),
                  const SizedBox(height: 40),
                  SessionViewButton(
                    onSessionClick: () {
                      context
                          .read<PracticeGamesBloc>()
                          .add(StartListeningToBleDataEvent());
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<PracticeGamesBloc>(),
                            child: LongestDriveSessionPage(
                                totalShots: state.selectedShots),
                          ),
                        ),
                      );
                    },
                    buttonText: "Start Game",
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
