import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/presentation/bloc/target_zone_bloc.dart';
import 'package:onegolf/feature/landing_dashboard/persentation/pages/landing_dashboard.dart';
import 'package:onegolf/feature/auth/presentation/pages/sign_in_screen.dart';
import 'package:permission_handler/permission_handler.dart';

import 'core/di/injection_container.dart' as di;
import 'feature/auth/domain/usecases/check_auth_status.dart';
import 'feature/auth/domain/usecases/login_user.dart';
import 'feature/auth/domain/usecases/signup_user.dart';
import 'feature/auth/presentation/bloc/auth_bloc.dart';
import 'feature/auth/presentation/pages/sign_up_screen.dart';
import 'feature/ble_management/presentation/bloc/ble_management_bloc.dart';
import 'feature/golf_device/domain/repositories/ble_repository.dart';
import 'feature/landing_dashboard/persentation/bloc/dashboard_bloc.dart';
import 'feature/profile/presentation/pages/profile_screen.dart';
import 'feature/splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await di.init();
  await requestPermissions();
  runApp(MyApp());
}

Future<void> requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.location,
  ].request();
  bool allGranted = statuses.values.every((status) => status.isGranted);
  if (!allGranted) {
    print("Some permissions are not granted. BLE may not work properly.");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider(
          create: (context) => di.sl<BleRepository>(),
        ),
        BlocProvider(
          create: (context) => di.sl<AuthBloc>(),
        ),
        BlocProvider(
          create: (context) => di.sl<DashboardBloc>(),
        ),
        BlocProvider(
          create: (context) => di.sl<BleManagementBloc>(),
        ),
        BlocProvider(
          create: (context) => di.sl<TargetZoneBloc>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'OneGolf',
        theme: ThemeData.dark(),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/SignInScreen': (context) => const SignInScreen(),
          '/SignUpScreen': (context) => const SignUpScreen(),
          '/landingDashboard': (context) => const LandingDashboard(),
          '/ProfileScreen': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}