import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/model/shot_anaylsis_model.dart';
import '../bloc/golf_device_bloc.dart';
import '../bloc/golf_device_event.dart';
import '../bloc/golf_device_state.dart';

class ShotHistoryScreen extends StatelessWidget {
  const ShotHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<GolfDeviceBloc>().add(LoadShotHistoryEvent());

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E21),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/landingDashboard',
                  (route) => false,
            );
          },
        ),
        title: const Text(
          'Shot History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<GolfDeviceBloc, GolfDeviceState>(
            builder: (context, state) {
              if (state is ShotHistoryLoadedState && state.shots.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 26),
                  onPressed: () => _showDeleteAllDialog(context),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: BlocBuilder<GolfDeviceBloc, GolfDeviceState>(
        builder: (context, state) {
          if (state is ShotHistoryLoadingState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: Colors.tealAccent,
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
                        context.read<GolfDeviceBloc>().add(LoadShotHistoryEvent());
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
                        color: Colors.tealAccent,
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
                    const SizedBox(height: 12),
                    Text(
                      'Start recording your shots\nto see them here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      label: const Text('Start Recording'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<GolfDeviceBloc>().add(LoadShotHistoryEvent());
              },
              color: Colors.tealAccent,
              backgroundColor: const Color(0xFF1D1E33),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Stats Card
                  // _buildStatsCard(state.shots),
                  const SizedBox(height: 16),

                  // Shots Table
                  ShotHistoryTable(shots: state.shots),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildStatsCard(List<ShotAnalysisModel> shots) {
    final totalShots = shots.length;
    final avgClubSpeed = shots.isEmpty
        ? 0.0
        : shots.map((s) => s.clubSpeed).reduce((a, b) => a + b) / totalShots;
    final avgBallSpeed = shots.isEmpty
        ? 0.0
        : shots.map((s) => s.ballSpeed).reduce((a, b) => a + b) / totalShots;
    final maxDistance = shots.isEmpty
        ? 0.0
        : shots.map((s) => s.totalDistance).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.tealAccent.withOpacity(0.2),
            Colors.cyanAccent.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.tealAccent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded, color: Colors.tealAccent, size: 24),
              const SizedBox(width: 12),
              Text(
                'Session Statistics',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Shots',
                  totalShots.toString(),
                  Icons.sports_golf_rounded,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Avg Club Speed',
                  '${avgClubSpeed.toStringAsFixed(1)} mph',
                  Icons.speed_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Avg Ball Speed',
                  '${avgBallSpeed.toStringAsFixed(1)} mph',
                  Icons.sports_baseball_rounded,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Max Distance',
                  '${maxDistance.toStringAsFixed(1)} yds',
                  Icons.trending_up_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.tealAccent.withOpacity(0.7), size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.redAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete All Shots?',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'This will permanently delete all your shot records. This action cannot be undone.',
          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // context.read<GolfDeviceBloc>().add(DeleteAllShotsEvent());
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}

class ShotHistoryTable extends StatelessWidget {
  final List<ShotAnalysisModel> shots;

  const ShotHistoryTable({Key? key, required this.shots}) : super(key: key);

  Color _getShotColor(int clubId) {
    const colors = {
      0: Color(0xFF00BCD4), // Driver - Cyan
      1: Color(0xFF2196F3), // 3W - Blue
      2: Color(0xFF3F51B5), // 5W - Indigo
      3: Color(0xFF9C27B0), // Hybrids - Purple
      4: Color(0xFF9C27B0),
      5: Color(0xFF9C27B0),
      6: Color(0xFF4CAF50), // Irons - Green
      7: Color(0xFF4CAF50),
      8: Color(0xFF4CAF50),
      9: Color(0xFF8BC34A),
      10: Color(0xFF8BC34A),
      11: Color(0xFFCDDC39),
      12: Color(0xFFCDDC39),
      13: Color(0xFFFF9800), // Wedges - Orange
      14: Color(0xFFFF9800),
      15: Color(0xFFFF5722),
      16: Color(0xFFFF5722),
    };
    return colors[clubId] ?? const Color(0xFF00BCD4);
  }

  String _getClubName(int clubId) {
    const clubs = {
      0: 'DR',
      1: '3W',
      2: '5W',
      3: '3H',
      4: '4H',
      5: '5H',
      6: '3I',
      7: '4I',
      8: '5I',
      9: '6I',
      10: '7I',
      11: '8I',
      12: '9I',
      13: 'PW',
      14: 'AW',
      15: 'SW',
      16: 'LW',
    };
    return clubs[clubId] ?? 'DR';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 68), // Space for club badge + shot number
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Club\nSpeed',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      height: 1.3,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Ball\nSpeed',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      height: 1.3,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Smash\nFactor',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      height: 1.3,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Carry\nDist.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      height: 1.3,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Total\nDist.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      height: 1.3,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Units row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.black.withOpacity(0.2),
            child: Row(
              children: [
                const SizedBox(width: 68),
                Expanded(flex: 2, child: _UnitText('mph')),
                Expanded(flex: 2, child: _UnitText('mph')),
                Expanded(flex: 2, child: _UnitText('')),
                Expanded(flex: 2, child: _UnitText('yds')),
                Expanded(flex: 2, child: _UnitText('yds')),
              ],
            ),
          ),

          // Shots List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: shots.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.white.withOpacity(0.05),
            ),
            itemBuilder: (context, index) {
              final shot = shots[index];
              return Dismissible(
                key: Key(shot.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.redAccent.withOpacity(0.9),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_rounded, color: Colors.white, size: 28),
                      SizedBox(height: 4),
                      Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                onDismissed: (direction) {
                  // context.read<GolfDeviceBloc>().add(DeleteShotEvent(shot.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Text('Shot #${shot.shotNumber} deleted'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  child: Row(
                    children: [
                      // Club Badge with Name
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getShotColor(shot.clubName),
                              _getShotColor(shot.clubName).withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _getShotColor(shot.clubName).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getClubName(shot.clubName),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '#${shot.shotNumber}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Data Columns
                      Expanded(
                        flex: 2,
                        child: _buildDataCell(shot.clubSpeed.toStringAsFixed(1)),
                      ),
                      Expanded(
                        flex: 2,
                        child: _buildDataCell(shot.ballSpeed.toStringAsFixed(1)),
                      ),
                      Expanded(
                        flex: 2,
                        child: _buildDataCell(shot.smashFactor.toStringAsFixed(2)),
                      ),
                      Expanded(
                        flex: 2,
                        child: _buildDataCell(shot.carryDistance.toStringAsFixed(0)),
                      ),
                      Expanded(
                        flex: 2,
                        child: _buildDataCell(
                          shot.totalDistance.toStringAsFixed(0),
                          highlight: true,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataCell(String value, {bool highlight = false}) {
    return Text(
      value,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
        color: highlight ? Colors.tealAccent : Colors.white,
      ),
    );
  }
}

class _UnitText extends StatelessWidget {
  final String text;
  const _UnitText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 10,
        color: Colors.white38,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}