import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/feature/club_gapping/presentation/bloc/club_gapping_event.dart';
import 'package:onegolf/feature/combine_test/games/wedge_combine_test/presentation/bloc/wedge_combine_bloc.dart';
import 'package:onegolf/feature/combine_test/games/wedge_combine_test/presentation/bloc/wedge_combine_event.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/presentation/bloc/distance_master_bloc.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/presentation/bloc/distance_master_event.dart';
import 'package:onegolf/feature/distance_control_drills/ladder_drill/presentation/bloc/ladder_drill_bloc.dart';
import 'package:onegolf/feature/distance_control_drills/ladder_drill/presentation/bloc/ladder_drill_event.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/presentation/bloc/target_zone_bloc.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/presentation/bloc/target_zone_event.dart';
import 'package:onegolf/feature/golf_device/presentation/bloc/golf_device_bloc.dart';
import 'package:onegolf/feature/widget/bottom_nav_bar.dart';
import '../feature/landing_dashboard/persentation/pages/landing_dashboard.dart';
import '../feature/shot_library/presentation/pages/shot_library_home_page.dart';
import '../feature/practice_games/presentation/pages/practice_games_screen.dart';
import '../feature/golf_device/presentation/pages/golf_device_screen.dart';
import 'auth/presentation/bloc/auth_bloc.dart';
import 'auth/presentation/bloc/auth_state.dart';
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
    BottomNavController.reTapIndex.addListener(_onSameTabTapped);
  }

  @override
  void dispose() {
    BottomNavController.currentIndex.removeListener(_onTabChanged);
    BottomNavController.reTapIndex.removeListener(_onSameTabTapped);
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

    _resetTabSideEffects(newIndex);

    final navigator = _navigatorKeys[newIndex].currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    }

    setState(() {});
  }

  void _resetTabSideEffects(int index) {

      context.read<PracticeGamesBloc>().add(ResetSessionEvent());
      context.read<ClubGappingBloc>().add(StopListeningToBleDataClubEvent());
      context.read<TargetZoneBloc>().add(ResetGameEvent());
      context.read<DistanceMasterBloc>().add(EndGameEvent());
      context.read<LadderDrillBloc>().add(RestartLadderDrillGameEvent());
      context.read<WedgeCombineBloc>().add(ResetWedgeCombineEvent());

    if (index == 0 || index == 2 || index == 3) {
      context.read<GolfDeviceBloc>()
          .add(DisconnectDeviceEvent(isNotBottom: false));
    }

    if (index == 1) {
      final bloc = context.read<GolfDeviceBloc>();
      bloc.add(
        ConnectionStateChangedEvent(bloc.bleRepository.isConnected),
      );
    }

    if (index == 3) {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      context.read<ShotLibraryBloc>().add(LoadAllShots(uid));
    }
  }



  void _onSameTabTapped() {
    final index = BottomNavController.reTapIndex.value;
    if (index == null) return;

    final navigator = _navigatorKeys[index].currentState;

    if (navigator != null && navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    }

    // Optional: reset games / BLE when re-tapping
    _resetTabSideEffects(index);

    // Clear notifier
    BottomNavController.reTapIndex.value = null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          // Reset bottom nav
          // BottomNavController.currentIndex.value = 0;
          // BottomNavController.reTapIndex.value = null;

          // 🔥 ROOT navigation (this WORKS)
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/SignInScreen',
                (route) => false,
          );
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: BottomNavController.currentIndex.value,
          children: [
            _buildNavigator(0, const LandingDashboard()),
            _buildNavigator(1, const GolfDeviceView()),
            _buildNavigator(2, const PracticeGamesScreen()),
            _buildNavigator(3, const ShotLibraryHomePage()),
          ],
        ),
        bottomNavigationBar: const BottomNavBar(),
      ),
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
