// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get_it/get_it.dart';
// import 'package:onegolf/feature/practice_games/presentation/bloc/practice_games_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../feature/auth/data/repository/auth_repository_impl.dart';
// import '../../feature/auth/domain/repository/auth_repository.dart';
// import '../../feature/auth/domain/usecases/check_auth_status.dart';
// import '../../feature/auth/domain/usecases/login_user.dart';
// import '../../feature/auth/domain/usecases/logout_user.dart';
// import '../../feature/auth/domain/usecases/signup_user.dart';
// import '../../feature/auth/presentation/bloc/auth_bloc.dart';
// import '../../feature/ble_management/domain/usecases/check_connection_status_usecase.dart';
// import '../../feature/ble_management/presentation/bloc/ble_management_bloc.dart';
// import '../../feature/golf_device/data/datasources/shot_firestore_datasource.dart';
// import '../../feature/golf_device/data/model/shot_anaylsis_model.dart';
// import '../../feature/golf_device/data/repositories/ble_repository_impl.dart';
// import '../../feature/golf_device/data/services/ble_service.dart';
// import '../../feature/golf_device/domain/repositories/ble_repository.dart';
// import '../../feature/golf_device/domain/usecases/connect_device_usecase.dart';
// import '../../feature/golf_device/domain/usecases/delete_shot_usecase.dart';
// import '../../feature/golf_device/domain/usecases/disconnect_device_usecase.dart';
// import '../../feature/golf_device/domain/usecases/discover_services_usecase.dart';
// import '../../feature/golf_device/domain/usecases/fatch_shot_usecase.dart';
// import '../../feature/golf_device/domain/usecases/save_shot_usecase.dart';
// import '../../feature/golf_device/domain/usecases/scan_devices_usecase.dart';
// import '../../feature/golf_device/domain/usecases/send_command_usecase.dart';
// import '../../feature/golf_device/domain/usecases/send_sync_packet_usecase.dart';
// import '../../feature/golf_device/domain/usecases/subscribe_notifications_usecase.dart';
// import '../../feature/golf_device/presentation/bloc/golf_device_bloc.dart';
// import '../../feature/landing_dashboard/data/datasources/user_remote_data_source.dart';
// import '../../feature/landing_dashboard/data/repositories/dashboard_repository_impl.dart';
// import '../../feature/landing_dashboard/domain/repositories/dashboard_repository.dart';
// import '../../feature/landing_dashboard/domain/usecases/get_user_profile.dart';
// import '../../feature/landing_dashboard/persentation/bloc/dashboard_bloc.dart';
// import '../../feature/setting/persentation/bloc/setting_bloc.dart';
// import '../../feature/shots_history/presentation/bloc/shot_selection_bloc.dart';
//
// final sl = GetIt.instance;
//
// Future<void> init() async {
//   final prefs = await SharedPreferences.getInstance();
//   sl.registerSingleton<SharedPreferences>(prefs);
//
//   sl.registerFactory<BleManagementBloc>(() => BleManagementBloc(
//     scanDevicesUseCase: sl<ScanDevicesUseCase>(),
//     connectDeviceUseCase: sl<ConnectDeviceUseCase>(),
//     disconnectDeviceUseCase: sl<DisconnectDeviceUseCase>(),
//     discoverServicesUseCase: sl<DiscoverServicesUseCase>(),
//     checkConnectionStatusUseCase: sl<CheckConnectionStatusUseCase>(),
//   ));
//
//   // BLoC
//   sl.registerFactory(
//     () => GolfDeviceBloc(
//       scanDevicesUseCase: sl(),
//       connectDeviceUseCase: sl(),
//       discoverServicesUseCase: sl(),
//       subscribeNotificationsUseCase: sl(),
//       sendSyncPacketUseCase: sl(),
//       sendCommandUseCase: sl(),
//       disconnectDeviceUseCase: sl(),
//       bleRepository: sl(),
//       sharedPreferences: sl(),
//     ),
//   );
//
//   // Use Cases
//   sl.registerLazySingleton(() => ScanDevicesUseCase(sl()));
//   sl.registerLazySingleton(() => ConnectDeviceUseCase(sl()));
//   sl.registerLazySingleton(() => DiscoverServicesUseCase(sl()));
//   sl.registerLazySingleton(() => SubscribeNotificationsUseCase(sl()));
//   sl.registerLazySingleton(() => SendSyncPacketUseCase(sl()));
//   sl.registerLazySingleton(() => SendCommandUseCase(sl()));
//   sl.registerLazySingleton(() => DisconnectDeviceUseCase(sl()));
//
//   // Repository
//   sl.registerLazySingleton<BleRepository>(
//     () => BleRepositoryImpl(
//       sl<BleService>(),
//       sl<ShotFirestoreDatasource>(),
//     ),
//   );
//
//   // Services
//   sl.registerLazySingleton(() => BleService());
//   sl.registerLazySingleton<ShotFirestoreDatasource>(
//       () => ShotFirestoreDatasourceImpl());
//
//   // usecases
//   sl.registerLazySingleton(() => SaveShotUseCase(sl<BleRepository>()));
//   sl.registerLazySingleton(() => FetchShotsUseCase(sl<BleRepository>()));
//   sl.registerLazySingleton(() => DeleteShotUseCase(sl<BleRepository>()));
//
//   sl.registerFactory(() => SettingBloc(
//         sendCommandUseCase: sl<SendCommandUseCase>(),
//         sharedPreferences: sl<SharedPreferences>(),
//         bleService: sl<BleService>(),
//       ));
//
//   sl.registerFactory(
//     () => AuthBloc(
//       loginUser: sl<LoginUser>(),
//       signUpUser: sl<SignUpUser>(),
//       checkAuthStatus: sl<CheckAuthStatus>(),
//       logoutUser: sl<LogoutUser>(),
//     ),
//   );
//
//   sl.registerLazySingleton(() => LoginUser(sl()));
//   sl.registerLazySingleton(() => SignUpUser(sl()));
//   sl.registerLazySingleton(() => CheckAuthStatus(sl()));
//   sl.registerLazySingleton(() => LogoutUser(sl()));
//
//   // Repository
//   sl.registerLazySingleton<AuthRepository>(
//     () => AuthRepositoryImpl(
//       firebaseAuth: sl<FirebaseAuth>(),
//       firestore: sl<FirebaseFirestore>(),
//     ),
//   );
//
//   sl.registerFactory(
//     () => DashboardBloc(
//       getUserProfile: sl<GetUserProfile>(),
//       firebaseAuth: sl<FirebaseAuth>(),
//     ),
//   );
//
//   sl.registerLazySingleton(() => GetUserProfile(sl()));
//
//   // ✅ Dashboard Repository
//   sl.registerLazySingleton<DashboardRepository>(
//     () => DashboardRepositoryImpl(
//       remoteDataSource: sl<UserRemoteDataSource>(),
//     ),
//   );
//
//   // ✅ Dashboard Data Source
//   sl.registerLazySingleton<UserRemoteDataSource>(
//     () => UserRemoteDataSourceImpl(
//       firebaseAuth: sl<FirebaseAuth>(),
//       firestore: sl<FirebaseFirestore>(),
//     ),
//   );
//
//   sl.registerFactory(
//     () => ShotHistoryBloc(
//       bleRepository: sl<BleRepository>(),
//       user: sl<FirebaseAuth>().currentUser,
//       sendCommandUseCase: sl<SendCommandUseCase>(),
//       golfDeviceBloc: sl<GolfDeviceBloc>(),
//     ),
//   );
//
//   sl.registerLazySingleton(() => FirebaseAuth.instance);
//   sl.registerLazySingleton(() => FirebaseFirestore.instance);
//
//   sl.registerFactory<PracticeGamesBloc>(() => PracticeGamesBloc());
//
//   sl.registerLazySingleton(() => CheckConnectionStatusUseCase(sl()));
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:onegolf/feature/auth/domain/usecases/change_password.dart';
import 'package:onegolf/feature/club_gapping/presentation/bloc/club_gapping_bloc.dart';
import 'package:onegolf/feature/distance_control_drills/distance_master/presentation/bloc/distance_master_bloc.dart';
import 'package:onegolf/feature/distance_control_drills/ladder_drill/presentation/bloc/ladder_drill_bloc.dart';
import 'package:onegolf/feature/distance_control_drills/target_zone/presentation/bloc/target_zone_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../feature/auth/domain/usecases/update_profile.dart';
import '../../feature/ble_management/data/repositories/ble_management_repository_imple.dart';
import '../../feature/ble_management/data/services/ble_management_service.dart';
import '../../feature/ble_management/domain/repositories/ble_management_repository.dart';
import '../../feature/ble_management/domain/usecases/check_connection_status_usecase.dart';
import '../../feature/ble_management/domain/usecases/connect_device_usecase.dart'
    as ble_mgmt;
import '../../feature/ble_management/domain/usecases/disconnect_device_usecase.dart'
    as ble_mgmt;
import '../../feature/ble_management/domain/usecases/discover_services_usecase.dart'
    as ble_mgmt;
import '../../feature/ble_management/domain/usecases/scan_devices_usecase.dart'
    as ble_mgmt show ScanDevicesUseCase;
import '../../feature/ble_management/presentation/bloc/ble_management_bloc.dart';
import '../../feature/auth/data/repository/auth_repository_impl.dart';
import '../../feature/auth/domain/repository/auth_repository.dart';
import '../../feature/auth/domain/usecases/check_auth_status.dart';
import '../../feature/auth/domain/usecases/login_user.dart';
import '../../feature/auth/domain/usecases/logout_user.dart';
import '../../feature/auth/domain/usecases/signup_user.dart';
import '../../feature/auth/presentation/bloc/auth_bloc.dart';
import '../../feature/landing_dashboard/data/datasources/user_remote_data_source.dart';
import '../../feature/landing_dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../feature/landing_dashboard/domain/repositories/dashboard_repository.dart';
import '../../feature/landing_dashboard/domain/usecases/get_user_profile.dart';
import '../../feature/landing_dashboard/persentation/bloc/dashboard_bloc.dart';
import '../../feature/golf_device/data/datasources/shot_firestore_datasource.dart';
import '../../feature/golf_device/data/repositories/ble_repository_impl.dart';
import '../../feature/golf_device/data/services/ble_service.dart';
import '../../feature/golf_device/domain/repositories/ble_repository.dart';
import '../../feature/golf_device/domain/usecases/connect_device_usecase.dart';
import '../../feature/golf_device/domain/usecases/delete_shot_usecase.dart';
import '../../feature/golf_device/domain/usecases/disconnect_device_usecase.dart';
import '../../feature/golf_device/domain/usecases/discover_services_usecase.dart';
import '../../feature/golf_device/domain/usecases/save_shot_usecase.dart';
import '../../feature/golf_device/domain/usecases/scan_devices_usecase.dart';
import '../../feature/golf_device/domain/usecases/send_command_usecase.dart';
import '../../feature/golf_device/domain/usecases/send_sync_packet_usecase.dart';
import '../../feature/golf_device/domain/usecases/subscribe_notifications_usecase.dart';
import '../../feature/golf_device/presentation/bloc/golf_device_bloc.dart';
import '../../feature/practice_games/presentation/bloc/practice_games_bloc.dart';
import '../../feature/shot_library/presentation/bloc/shot_library_bloc.dart';
import '../../feature/shots_history/presentation/bloc/shot_selection_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ============================================================
  // STEP 1: EXTERNAL DEPENDENCIES (Must be first!)
  // ============================================================

  // Firebase instances
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // ============================================================
  // STEP 2: SERVICES (Before Repositories!)
  // ============================================================

  // BLE Management Service (Singleton - only one instance)
  sl.registerLazySingleton<BleManagementService>(() => BleManagementService());

  // Golf Device BLE Service (Separate from BLE Management)
  sl.registerLazySingleton<BleService>(() => BleService());

  // ============================================================
  // STEP 3: DATA SOURCES (Before Repositories!)
  // ============================================================

  // Dashboard Data Source
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );

  // Golf Device Data Source
  sl.registerLazySingleton<ShotFirestoreDatasource>(
    () => ShotFirestoreDatasourceImpl(
      firestore: sl(),
    ),
  );

  // ============================================================
  // STEP 4: REPOSITORIES (Before Use Cases!)
  // ============================================================

  // BLE Management Repository (IMPORTANT - Must be before use cases!)
  sl.registerLazySingleton<BleManagementRepository>(
    () => BleManagementRepositoryImpl(sl<BleManagementService>()),
  );

  // Auth Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );

  // Dashboard Repository
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Golf Device BLE Repository
  sl.registerLazySingleton<BleRepository>(
    () => BleRepositoryImpl(
      sl<BleService>(),
      sl<ShotFirestoreDatasource>(),
    ),
  );

  // ============================================================
  // STEP 5: USE CASES (Before BLoCs!)
  // ============================================================

  // BLE Management Use Cases
  sl.registerLazySingleton(
      () => ble_mgmt.ScanDevicesUseCase(sl<BleManagementRepository>()));
  sl.registerLazySingleton(
      () => ble_mgmt.ConnectDeviceUseCase(sl<BleManagementRepository>()));
  sl.registerLazySingleton(
      () => ble_mgmt.DisconnectDeviceUseCase(sl<BleManagementRepository>()));
  sl.registerLazySingleton(
      () => ble_mgmt.DiscoverServicesUseCase(sl<BleManagementRepository>()));
  sl.registerLazySingleton(
      () => CheckConnectionStatusUseCase(sl<BleManagementRepository>()));

  // Auth Use Cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => SignUpUser(sl()));
  sl.registerLazySingleton(() => CheckAuthStatus(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => ChangePassword(sl()));

  // Dashboard Use Cases
  sl.registerLazySingleton(() => GetUserProfile(sl()));

  // Golf Device Use Cases
  sl.registerLazySingleton(() => ScanDevicesUseCase(sl<BleRepository>()));
  sl.registerLazySingleton(() => ConnectDeviceUseCase(sl<BleRepository>()));
  sl.registerLazySingleton(() => DisconnectDeviceUseCase(sl<BleRepository>()));
  sl.registerLazySingleton(() => DiscoverServicesUseCase(sl<BleRepository>()));
  sl.registerLazySingleton(() => SubscribeNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => SendSyncPacketUseCase(sl()));
  sl.registerLazySingleton(() => SendCommandUseCase(sl()));
  sl.registerLazySingleton(() => SaveShotUseCase(sl()));
  sl.registerLazySingleton(() => DeleteShotUseCase(sl()));
  // sl.registerLazySingleton(() => FetchShotUseCase(sl()));

  // ============================================================
  // STEP 6: BLoCs (Last!)
  // ============================================================
  print('🔧 Registering BLoCs...');

  // BLE Management BLoC
  sl.registerFactory(
    () => BleManagementBloc(
      scanDevicesUseCase: sl(),
      connectDeviceUseCase: sl(),
      disconnectDeviceUseCase: sl(),
      discoverServicesUseCase: sl(),
      checkConnectionStatusUseCase: sl(),
    ),
  );

  // Auth BLoC
  sl.registerFactory(
    () => AuthBloc(
      loginUser: sl(),
      signUpUser: sl(),
      checkAuthStatus: sl(),
      logoutUser: sl(),
      updateProfile: sl(),
      changePassword: sl(),
      firebaseAuth: sl(),
    ),
  );

  // Dashboard BLoC
  sl.registerFactory(
    () => DashboardBloc(
      getUserProfile: sl(),
      firebaseAuth: sl(),
    ),
  );

  // Golf Device BLoC
  sl.registerFactory(
    () => GolfDeviceBloc(
      bleRepository: sl(),
      sharedPreferences: sl(),
      datasource: sl(),
    ),
  );

  // Shot History BLoc
  sl.registerFactory(
    () => ShotHistoryBloc(
      bleRepository: sl(),
      user: sl<FirebaseAuth>().currentUser,
      golfDeviceBloc: sl(),
      datasource: sl(),
    ),
  );
  // Practice Games BLoC
  sl.registerFactory(
    () => PracticeGamesBloc(
      bleRepository: sl(),
    ),
  );

  sl.registerFactory(
    () => ShotLibraryBloc(
      datasource: sl(),
    ),
  );

  sl.registerFactory(
    () => ClubGappingBloc(
      bleRepository: sl(),
    ),
  );

  sl.registerFactory(
    () => DistanceMasterBloc(
      bleRepository: sl(),
    ),
  );

  sl.registerFactory(
    () => TargetZoneBloc(
      bleRepository: sl(),
    ),
  );

  sl.registerFactory(
    () => LadderDrillBloc(
      bleRepository: sl(),
    ),
  );

  print('✅ BLoCs Registered');
  print('🎉 All Dependencies Registered Successfully!');
}
