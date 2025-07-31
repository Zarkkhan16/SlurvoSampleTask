import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocProvider;
import 'package:Slurvo/core/di/injection_container.dart' as di;
import 'package:Slurvo/feature/ble/presentation/block/ble_bloc.dart';
import 'package:Slurvo/feature/ble/presentation/block/ble_event.dart';
import 'package:Slurvo/feature/home_screens/presentation/pages/shot_analysis_page.dart';

class NavigationHelper {
  static void initializeAndNavigateSplash(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (context) => di.sl<BleBloc>()..add(StartScanEvent()),
              child: const ShotAnalysisPage(),
            ),
          ),
        );
      });
    });
  }
}
