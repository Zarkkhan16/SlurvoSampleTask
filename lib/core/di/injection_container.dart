//
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'package:get_it/get_it.dart';
// import 'package:onegolf/feature/ble/domain/usecases/discover_devices.dart';
// import 'package:onegolf/feature/ble/domain/usecases/write_characteristics.dart';
// import 'package:onegolf/feature/ble/presentation/block/ble_bloc.dart';
// import 'package:onegolf/feature/home_screens/data/%20datasources/shot_local_data_source.dart';
// import 'package:onegolf/feature/home_screens/data/repositories/shot_repository_impl.dart';
// import 'package:onegolf/feature/home_screens/domain/repositories/shot_repository.dart';
// import 'package:onegolf/feature/home_screens/domain/usecases/get_shot_data.dart';
//
// // BLE imports
// import 'package:onegolf/feature/ble/data/repositories/ble_repository_impl.dart';
// import 'package:onegolf/feature/ble/domain/repositories/ble_repository_old.dart';
// import 'package:onegolf/feature/ble/domain/usecases/scan_for_devices.dart';
// import 'package:onegolf/feature/ble/domain/usecases/connect_to_device.dart';
// import 'package:onegolf/feature/ble/domain/usecases/read_characteristic.dart';
//
//
// final sl = GetIt.instance;
//
// Future<void> init() async {
//   //
//   // sl.registerFactory(() => BleBloc(
//   //   scanForDevices: sl(),
//   //   connectToDevice: sl(),
//   //   discoverServices: sl(),
//   //   readCharacteristic: sl(),
//   //   writeCharacteristic: sl(),
//   //   shotRepository: sl()
//   //
//   // ));
// // Register reactive ble singleton
//   sl.registerLazySingleton(() => FlutterReactiveBle());
//
// // Register repository
//
// // Register bloc
//   sl.registerFactory(() => BleBloc(
//     ble: sl<FlutterReactiveBle>(),
//     shotRepository: sl<ShotRepository>(),
//   ));
//
//
//   // Use cases
//   sl.registerLazySingleton(() => GetShotData(sl()));
//
//   // Repository
//   sl.registerLazySingleton<BleRepository>(() => BleRepositoryImpl());
//
//   sl.registerLazySingleton<ShotRepository>(() => ShotRepositoryImpl(localDataSource: sl()));
//
//   // Data source
//   sl.registerLazySingleton<ShotLocalDataSource>(() => ShotLocalDataSourceImpl());
//
//
//   // Use cases
//   sl.registerLazySingleton(() => ScanForDevices(sl()));
//   sl.registerLazySingleton(() => ConnectToDevice(sl()));
//   sl.registerLazySingleton(() => DiscoverServices(sl()));
//   sl.registerLazySingleton(() => ReadCharacteristic(sl()));
//   sl.registerLazySingleton(() => WriteCharacteristic(sl()));
//
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../feature/auth/data/repository/auth_repository_impl.dart';
import '../../feature/auth/domain/repository/auth_repository.dart';
import '../../feature/auth/domain/usecases/check_auth_status.dart';
import '../../feature/auth/domain/usecases/login_user.dart';
import '../../feature/auth/domain/usecases/logout_user.dart';
import '../../feature/auth/domain/usecases/signup_user.dart';
import '../../feature/auth/presentation/bloc/auth_bloc.dart';
import '../../feature/golf_device/data/datasources/shot_firestore_datasource.dart';
import '../../feature/golf_device/data/model/shot_anaylsis_model.dart';
import '../../feature/golf_device/data/repositories/ble_repository_impl.dart';
import '../../feature/golf_device/data/services/ble_service.dart';
import '../../feature/golf_device/domain/repositories/ble_repository.dart';
import '../../feature/golf_device/domain/usecases/connect_device_usecase.dart';
import '../../feature/golf_device/domain/usecases/delete_shot_usecase.dart';
import '../../feature/golf_device/domain/usecases/disconnect_device_usecase.dart';
import '../../feature/golf_device/domain/usecases/discover_services_usecase.dart';
import '../../feature/golf_device/domain/usecases/fatch_shot_usecase.dart';
import '../../feature/golf_device/domain/usecases/save_shot_usecase.dart';
import '../../feature/golf_device/domain/usecases/scan_devices_usecase.dart';
import '../../feature/golf_device/domain/usecases/send_command_usecase.dart';
import '../../feature/golf_device/domain/usecases/send_sync_packet_usecase.dart';
import '../../feature/golf_device/domain/usecases/subscribe_notifications_usecase.dart';
import '../../feature/golf_device/presentation/bloc/golf_device_bloc.dart';
import '../../feature/landing_dashboard/data/datasources/user_remote_data_source.dart';
import '../../feature/landing_dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../feature/landing_dashboard/domain/repositories/dashboard_repository.dart';
import '../../feature/landing_dashboard/domain/usecases/get_user_profile.dart';
import '../../feature/landing_dashboard/persentation/bloc/dashboard_bloc.dart';
import '../../feature/setting/persentation/bloc/setting_bloc.dart';
import '../../feature/shots_history/presentation/bloc/shot_selection_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  // BLoC
  sl.registerFactory(
    () => GolfDeviceBloc(
      scanDevicesUseCase: sl(),
      connectDeviceUseCase: sl(),
      discoverServicesUseCase: sl(),
      subscribeNotificationsUseCase: sl(),
      sendSyncPacketUseCase: sl(),
      sendCommandUseCase: sl(),
      disconnectDeviceUseCase: sl(),
      bleRepository: sl(),
      sharedPreferences: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => ScanDevicesUseCase(sl()));
  sl.registerLazySingleton(() => ConnectDeviceUseCase(sl()));
  sl.registerLazySingleton(() => DiscoverServicesUseCase(sl()));
  sl.registerLazySingleton(() => SubscribeNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => SendSyncPacketUseCase(sl()));
  sl.registerLazySingleton(() => SendCommandUseCase(sl()));
  sl.registerLazySingleton(() => DisconnectDeviceUseCase(sl()));

  // Repository
  sl.registerLazySingleton<BleRepository>(
    () => BleRepositoryImpl(
      sl<BleService>(),
      sl<ShotFirestoreDatasource>(),
    ),
  );

  // Services
  sl.registerLazySingleton(() => BleService());
  sl.registerLazySingleton<ShotFirestoreDatasource>(
      () => ShotFirestoreDatasourceImpl());

  // usecases
  sl.registerLazySingleton(() => SaveShotUseCase(sl<BleRepository>()));
  sl.registerLazySingleton(() => FetchShotsUseCase(sl<BleRepository>()));
  sl.registerLazySingleton(() => DeleteShotUseCase(sl<BleRepository>()));

  sl.registerFactory(() => SettingBloc(
        sendCommandUseCase: sl<SendCommandUseCase>(),
        sharedPreferences: sl<SharedPreferences>(),
        bleService: sl<BleService>(),
      ));

  sl.registerFactory(
    () => AuthBloc(
      loginUser: sl<LoginUser>(),
      signUpUser: sl<SignUpUser>(),
      checkAuthStatus: sl<CheckAuthStatus>(),
      logoutUser: sl<LogoutUser>(),
    ),
  );

  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => SignUpUser(sl()));
  sl.registerLazySingleton(() => CheckAuthStatus(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  sl.registerFactory(
    () => DashboardBloc(
      getUserProfile: sl<GetUserProfile>(),
      firebaseAuth: sl<FirebaseAuth>(),
    ),
  );

  sl.registerLazySingleton(() => GetUserProfile(sl()));

  // ✅ Dashboard Repository
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: sl<UserRemoteDataSource>(),
    ),
  );

  // ✅ Dashboard Data Source
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(
      firebaseAuth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  sl.registerFactory(
    () => ShotHistoryBloc(
      bleRepository: sl<BleRepository>(),
      user: sl<FirebaseAuth>().currentUser,
      sendCommandUseCase: sl<SendCommandUseCase>(),
      golfDeviceBloc: sl<GolfDeviceBloc>(),
    ),
  );

  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
}
