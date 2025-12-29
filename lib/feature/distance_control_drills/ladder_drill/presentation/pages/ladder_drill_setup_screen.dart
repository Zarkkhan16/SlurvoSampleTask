import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_strings.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/distance_control_drills/ladder_drill/presentation/bloc/ladder_drill_bloc.dart';
import 'package:onegolf/feature/distance_control_drills/ladder_drill/presentation/bloc/ladder_drill_state.dart';
import 'package:onegolf/feature/distance_control_drills/ladder_drill/presentation/bloc/ladder_drill_event.dart';
import 'package:onegolf/feature/distance_control_drills/ladder_drill/presentation/pages/ladder_drill_game_screen.dart';
import 'package:onegolf/feature/practice_games/presentation/widgets/add_player_chip.dart';
import 'package:onegolf/feature/practice_games/presentation/widgets/add_player_dialog.dart';
import 'package:onegolf/feature/practice_games/presentation/widgets/player_chip.dart';
import 'package:onegolf/feature/widget/bottom_nav_bar.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/gradient_border_container.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import 'package:onegolf/feature/widget/session_view_button.dart';

class LadderDrillSetupScreen extends StatefulWidget {
  const LadderDrillSetupScreen({super.key});

  @override
  State<LadderDrillSetupScreen> createState() => _LadderDrillSetupScreenState();
}

class _LadderDrillSetupScreenState extends State<LadderDrillSetupScreen> {
  late TextEditingController _playerNameController;
  late TextEditingController _customIncrementController;
  late bool _navigatedToLevelUp;
  @override
  void initState() {
    super.initState();
    _navigatedToLevelUp = true;
    _playerNameController = TextEditingController();
    _customIncrementController = TextEditingController();
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    _customIncrementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CustomAppBar(),
      // bottomNavigationBar: BottomNavBar(),
      body: BlocListener<LadderDrillBloc, LadderDrillState>(
        listener: (context, state) {
          if (state is GameSetupState && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
          if (state is GameInProgressState && _navigatedToLevelUp) {
            _navigatedToLevelUp = false;
            print("stup seceeeee");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<LadderDrillBloc>(),
                  child: LadderDrillGameScreen(),
                ),
              ),
            ).then((_) {
              _navigatedToLevelUp = false;
            });
          }
        },
        child: BlocBuilder<LadderDrillBloc, LadderDrillState>(
          builder: (context, state) {
            if (state is! GameSetupState) {
              return Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
              child: GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeaderRow(headingName: "Ladder Drill"),
                    Center(
                      child: Text(
                        'Hit the ball within the target zone to progress\nto the next level. Complete the ladder drill in\nas few shots as possible.',
                        style: AppTextStyle.roboto(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text(
                      'Target Distance:',
                      style: AppTextStyle.roboto(
                          fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              GradientBorderContainer(
                                borderRadius: 20,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 20),
                                child: GestureDetector(
                                  onTap: () => _showDistancePicker(
                                      true, state.shortestDistance),
                                  child: Container(
                                    width: 70,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Color(0xff716B6B66),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        state.shortestDistance.toString(),
                                        style: AppTextStyle.oswald(
                                          fontSize: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Shortest Target Distance',
                                style: AppTextStyle.roboto(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            'TO',
                            style: AppTextStyle.roboto(),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              GradientBorderContainer(
                                borderRadius: 20,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 20),
                                child: GestureDetector(
                                  onTap: () => _showDistancePicker(
                                      false, state.longestDistance),
                                  child: Container(
                                    width: 70,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Color(0xff716B6B66),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        state.longestDistance.toString(),
                                        style: AppTextStyle.oswald(
                                          fontSize: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
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
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        'You must carry the ball within the selected\nradius from the target',
                        style: AppTextStyle.roboto(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Difficulty:',
                      style: AppTextStyle.roboto(
                          fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        _buildDifficultyButton(
                            7, 'Easy', '7 yds', state.difficulty == 7),
                        SizedBox(width: 12),
                        _buildDifficultyButton(
                            5, 'Medium', '5 yds', state.difficulty == 5),
                        SizedBox(width: 12),
                        _buildDifficultyButton(
                            3, 'Hard', '3 yds', state.difficulty == 3),
                      ],
                    ),
                    SizedBox(height: 15),
                    Center(
                      child: Text(
                        'Increment For Every Level',
                        style: AppTextStyle.roboto(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        _buildIncrementButton(
                          5,
                          '5yds',
                          roundLeft: true,
                          isSelected: state.increment == 5,
                        ),
                        _buildIncrementButton(
                          10,
                          '10yds',
                          isSelected: state.increment == 10,
                        ),
                        _buildIncrementButton(
                          0,
                          'Custom',
                          roundRight: true,
                          isSelected: state.increment == 0,
                        ),
                      ],
                    ),
                    if (state.increment == 0) ...[
                      SizedBox(height: 10),
                      GradientBorderContainer(
                        borderRadius: 12,
                        backgroundColor: AppColors.cardBackground,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        child: SizedBox(
                          height: 36,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            style:
                            AppTextStyle.roboto(color: AppColors.primaryText),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 10),
                              border: InputBorder.none,
                              hintText: "Enter multiples of 5 (5, 10, 15...)",
                              hintStyle: AppTextStyle.roboto(
                                color: AppColors.secondaryText,
                                fontSize: 14,
                              ),
                            ),
                            onChanged: (value) {
                              context.read<LadderDrillBloc>().add(
                                UpdateCustomIncrementEvent(
                                    int.tryParse(value)),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 15),
                    Text(
                      'Players:',
                      style: AppTextStyle.roboto(
                          fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: [
                        ...state.players.asMap().entries.map((entry) {
                          int index = entry.key;
                          String playerName = entry.value;
                          return PlayerChip(
                            name: playerName,
                            onTap: () =>
                                _showPlayerOptions(context, index, playerName),
                            onLongPress: () {},
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
                    SizedBox(height: 20),
                    SessionViewButton(
                      onSessionClick: () {
                        if (state.increment == 0) {
                          if (state.customIncrement == null || state.customIncrement! <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please enter a valid increment value'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                        }

                        context.read<LadderDrillBloc>().add(StartGameEvent());
                      },
                      buttonText: "Start Game",
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDistancePicker(bool isShortest, int selectedValue) {
    final bloc = context.read<LadderDrillBloc>();
    const int start = 20;
    const int end = 350;
    const int step = 5;

    final int itemCount = ((end - start) ~/ step) + 1;

    final initialIndex =
        ((selectedValue - start) ~/ step).clamp(0, itemCount - 1);

    final controller = FixedExtentScrollController(initialItem: initialIndex);
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
                  controller: controller,
                  itemExtent: 50,
                  perspective: 0.005,
                  diameterRatio: 1.2,
                  physics: FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    final value = start + (index * step);

                    if (isShortest) {
                      bloc.add(UpdateShortestDistanceEvent(value));
                    } else {
                      bloc.add(UpdateLongestDistanceEvent(value));
                    }
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: itemCount,
                    builder: (context, index) {
                      final value = start + (index * step);
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

  Widget _buildDifficultyButton(
      int difficultyValue, String label, String subtitle, bool isSelected) {
    Color backgroundColor = isSelected ? Colors.white : const Color(0xFF2A2A2A);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          context
              .read<LadderDrillBloc>()
              .add(UpdateDifficultyEvent(difficultyValue));
        },
        child: GradientBorderContainer(
          borderRadius: 16,
          backgroundColor: backgroundColor,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTextStyle.roboto(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyle.oswald(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncrementButton(int incrementValue, String label,
      {bool roundLeft = false,
      bool roundRight = false,
      required bool isSelected}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          context
              .read<LadderDrillBloc>()
              .add(UpdateIncrementEvent(incrementValue));
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.only(
              topLeft: roundLeft ? const Radius.circular(12) : Radius.zero,
              bottomLeft: roundLeft ? const Radius.circular(12) : Radius.zero,
              topRight: roundRight ? const Radius.circular(12) : Radius.zero,
              bottomRight: roundRight ? const Radius.circular(12) : Radius.zero,
            ),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white38,
              width: 0.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyle.oswald(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddPlayerDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AddPlayerDialog(
        onPlayerAdded: (name) {
          context.read<LadderDrillBloc>().add(
                AddPlayerEvent(name),
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
          backgroundColor: Colors.red,
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
                context
                    .read<LadderDrillBloc>()
                    .add(RemovePlayerEvent(playerIndex));
              },
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showEditPlayerDialog(
      BuildContext context, int playerIndex, String currentName) {
    if (playerIndex == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot edit the primary player'),
          backgroundColor: Colors.red,
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
          if (playerIndex == 0) {
            return;
          }
          context.read<LadderDrillBloc>().add(
                EditPlayerEvent(playerIndex, newName),
              );
        },
      ),
    );
  }
}
