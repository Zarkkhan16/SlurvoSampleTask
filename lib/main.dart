import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sample_task/feature/ble/presentation/block/ble_bloc.dart';
import 'package:sample_task/feature/ble/presentation/block/ble_event.dart';
import 'package:sample_task/feature/home_screens/presentation/pages/shot_analysis_page.dart';
import 'package:sample_task/feature/splash/splash_screen.dart';
import 'core/di/injection_container.dart' as di;
import 'core/constants/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      theme: ThemeData(
        textTheme: GoogleFonts.oswaldTextTheme(Theme.of(context).textTheme),
      ),
      home:SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
