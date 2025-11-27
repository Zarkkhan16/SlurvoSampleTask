import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_strings.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/presentation/bloc/distance_master_bloc.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/presentation/bloc/distance_master_event.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/presentation/bloc/distance_master_state.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/presentation/pages/level_up_screen.dart';
import 'package:onegolf/feature/distance_control_drills/presentation/pages/distance_control_drills_screen.dart';
import 'package:onegolf/feature/practice_games/presentation/widgets/add_player_chip.dart';
import 'package:onegolf/feature/practice_games/presentation/widgets/player_chip.dart';
import 'package:onegolf/feature/widget/bottom_nav_bar.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/gradient_border_container.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import 'package:onegolf/feature/widget/session_view_button.dart';

import '../../../../practice_games/presentation/widgets/add_player_dialog.dart';

class DistanceMasterSetupScreen extends StatefulWidget {
  const DistanceMasterSetupScreen({super.key});

  @override
  _DistanceMasterSetupScreenState createState() =>
      _DistanceMasterSetupScreenState();
}

class _DistanceMasterSetupScreenState extends State<DistanceMasterSetupScreen> {
  int shortestDistance = 60;
  int longestDistance = 80;
  int selectedDifficulty = 7;
  int selectedIncrement = 5;
  int? customIncrement;
  List<String> selectedPlayers = [];
  final int maxPlayers = 4;
  bool _navigatedToLevelUp = false;

  @override
  void initState() {
    super.initState();
    selectedPlayers = [AppStrings.userProfileData.name];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(),
      bottomNavigationBar: BottomNavBar(),
      body: BlocConsumer<DistanceMasterBloc, DistanceMasterState>(
        listener: (context, state) {
          if (state is GameSetupState && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is GameInProgressState && !_navigatedToLevelUp) {
            _navigatedToLevelUp = true;
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (_) => BlocProvider.value(
            //       value: context.read<DistanceMasterBloc>(),
            //       child: LevelUpScreen(),
            //     ),
            //   ),
            Navigator.push(
              context,
              MaterialPageRoute(
                settings: RouteSettings(name: "LevelUpScreen"),
                builder: (_) => BlocProvider.value(
                  value: context.read<DistanceMasterBloc>(),
                  child: LevelUpScreen(),
                ),
              ),
            ).then((_) {
              // reset flag when returning
              _navigatedToLevelUp = false;
            });
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
            child: SingleChildScrollView(
              child: GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeaderRow(
                      headingName: "Distance Master",
                    ),
                    Center(
                      child: Text(
                        'Hit 3 Consecutive shots inside the target\nwindow to level up. Missing a shot resets the\nstreak.',
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
                                  onTap: () => _showDistancePicker(true),
                                  child: Container(
                                    width: 70,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Color(0xff716B6B66),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        shortestDistance.toString(),
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
                                  onTap: () => _showDistancePicker(false),
                                  child: Container(
                                    width: 70,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Color(0xff716B6B66),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        longestDistance.toString(),
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
                        _buildDifficultyButton(7, 'Easy', '7 yds'),
                        SizedBox(width: 12),
                        _buildDifficultyButton(5, 'Medium', '5 yds'),
                        SizedBox(width: 12),
                        _buildDifficultyButton(3, 'Hard', '3 yds'),
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
                        _buildIncrementButton(5, '5yds', roundLeft: true),
                        _buildIncrementButton(10, '10yds'),
                        _buildIncrementButton(0, 'Custom', roundRight: true),
                      ],
                    ),
                    if (selectedIncrement == 0) ...[
                      SizedBox(height: 10),
                      GradientBorderContainer(
                        borderRadius: 12,
                        backgroundColor: AppColors.cardBackground,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        child: SizedBox(
                          height: 36,
                          child: TextField(
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.number,
                            style: AppTextStyle.roboto(
                                color: AppColors.primaryText),
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
                              setState(() {
                                customIncrement = int.tryParse(value);
                              });
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
                        ...selectedPlayers.asMap().entries.map((entry) {
                          int index = entry.key;
                          String player = entry.value;
                          return PlayerChip(
                            name: player,
                            onTap: () =>
                                _showPlayerOptions(context, index, player),
                            onLongPress: () =>
                                _showEditPlayerDialog(context, index, player),
                          );
                        }),
                        for (int i = selectedPlayers.length;
                            i < maxPlayers;
                            i++)
                          AddPlayerChip(
                            label: "+Player ${i + 1}",
                            onTap: () => _showAddPlayerDialog(context),
                          ),
                      ],
                    ),
                    SizedBox(height: 20),
                    SessionViewButton(
                      buttonText: "START GAME",
                      onSessionClick: _startGame,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDifficultyButton(
      int difficultyValue, String label, String subtitle) {
    bool isSelected = selectedDifficulty == difficultyValue;
    Color backgroundColor = isSelected ? Colors.white : const Color(0xFF2A2A2A);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedDifficulty = difficultyValue;
          });
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
      {bool roundLeft = false, bool roundRight = false}) {
    bool isSelected = selectedIncrement == incrementValue;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedIncrement = incrementValue;
          });
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

  void _addPlayer(String player) {
    setState(() {
      if (!selectedPlayers.contains(player) &&
          selectedPlayers.length < maxPlayers) {
        selectedPlayers.add(player);
      }
    });
  }

  void _removePlayer(String player) {
    setState(() {
      if (selectedPlayers.indexOf(player) != 0) {
        selectedPlayers.remove(player);
      }
    });
  }

  void _editPlayer(int index, String newName) {
    if (index == 0) {
      return;
    }
    setState(() {
      selectedPlayers[index] = newName;
    });
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
                    childCount: 121, // 0 to 600 in steps of 5
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

  void _startGame() {
    print('Difficulty: $selectedDifficulty');
    print('Increment: $selectedIncrement');
    print('Players: $selectedPlayers');
    print('Custom: $customIncrement');

    if (selectedIncrement == 0) {
      if (customIncrement == null || customIncrement! <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid increment value'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    context.read<DistanceMasterBloc>().add(
          InitializeGameEvent(
            shortestDistance: shortestDistance,
            longestDistance: longestDistance,
            difficulty: selectedDifficulty,
            increment: selectedIncrement,
            customIncrement: selectedIncrement == 0 ? customIncrement : null,
            players: selectedPlayers,
          ),
        );
    Future.delayed(Duration(milliseconds: 100), () {
      final state = context.read<DistanceMasterBloc>().state;
      if (state is GameSetupState && state.errorMessage == null) {
        context.read<DistanceMasterBloc>().add(StartGameEvent());
      }
    });
  }

  void _showAddPlayerDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AddPlayerDialog(
        onPlayerAdded: (name) {
          _addPlayer(name);
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
          _editPlayer(playerIndex, newName);
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
                _removePlayer(playerName);
              },
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
