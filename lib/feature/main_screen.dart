import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/feature/club_gapping/presentation/bloc/club_gapping_event.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/presentation/bloc/target_zone_bloc.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/presentation/bloc/target_zone_event.dart';
import 'package:onegolf/feature/golf_device/presentation/bloc/golf_device_bloc.dart';
import 'package:onegolf/feature/widget/bottom_nav_bar.dart';
import '../feature/landing_dashboard/persentation/pages/landing_dashboard.dart';
import '../feature/shot_library/presentation/pages/shot_library_home_page.dart';
import '../feature/practice_games/presentation/pages/practice_games_screen.dart';
import '../feature/golf_device/presentation/pages/golf_device_screen.dart';
import 'bottom_controller.dart';
import 'club_gapping/presentation/bloc/club_gapping_bloc.dart';
import 'golf_device/presentation/bloc/golf_device_event.dart';
import 'practice_games/presentation/bloc/practice_games_bloc.dart';
import 'practice_games/presentation/bloc/practice_games_event.dart';
import 'shot_library/presentation/bloc/shot_library_bloc.dart';
import 'shot_library/presentation/bloc/shot_library_event.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    4,
        (_) => GlobalKey<NavigatorState>(),
  );

  @override
  void initState() {
    super.initState();
    BottomNavController.currentIndex.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    BottomNavController.currentIndex.removeListener(_onTabChanged);
    super.dispose();
  }

  // void _onTabChanged() {
  //   final newIndex = BottomNavController.currentIndex.value;
  //   final currentIndex = _navigatorKeys.indexWhere(
  //         (key) => key.currentState?.canPop() == true,
  //   );
  //
  //   if (newIndex == currentIndex) {
  //     _navigatorKeys[newIndex].currentState?.popUntil((route) => route.isFirst);
  //   }
  //   setState(() {});
  // }

  void _onTabChanged() {
    final newIndex = BottomNavController.currentIndex.value;

    final navigator = _navigatorKeys[newIndex].currentState;

    if (newIndex == 0 || newIndex == 1 || newIndex == 3) {
      context.read<PracticeGamesBloc>().add(ResetSessionEvent());
      context.read<ClubGappingBloc>().add(StopListeningToBleDataClubEvent());
      context.read<TargetZoneBloc>().add(ResetGameEvent());
    }

    if(newIndex == 0 || newIndex == 2 || newIndex == 3)
      {
        context.read<GolfDeviceBloc>().add(DisconnectDeviceEvent(isNotBottom: false));
      }

    if (newIndex == 1) {
      final bloc = context.read<GolfDeviceBloc>();
      bloc.add(
        ConnectionStateChangedEvent(
          bloc.bleRepository.isConnected,
        ),
      );
    }

    if (newIndex == 3) { // Shot Library tab
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      context.read<ShotLibraryBloc>().add(LoadAllShots(uid));
    }

    if (navigator != null && navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final index = BottomNavController.currentIndex.value;

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: [
          _buildNavigator(0, const LandingDashboard()),
          _buildNavigator(1, const GolfDeviceView()),
          _buildNavigator(2, const PracticeGamesScreen()),
          _buildNavigator(3, const ShotLibraryHomePage()),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  Widget _buildNavigator(int index, Widget child) {
    return Offstage(
      offstage: BottomNavController.currentIndex.value != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (settings) =>
            MaterialPageRoute(builder: (_) => child),
      ),
    );
  }
}
