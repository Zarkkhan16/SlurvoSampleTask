
import 'package:get_it/get_it.dart';
import 'package:Slurvo/feature/ble/domain/usecases/discover_devices.dart';
import 'package:Slurvo/feature/ble/domain/usecases/write_characteristics.dart';
import 'package:Slurvo/feature/ble/presentation/block/ble_bloc.dart';
import 'package:Slurvo/feature/home_screens/data/%20datasources/shot_local_data_source.dart';
import 'package:Slurvo/feature/home_screens/data/repositories/shot_repository_impl.dart';
import 'package:Slurvo/feature/home_screens/domain/repositories/shot_repository.dart';
import 'package:Slurvo/feature/home_screens/domain/usecases/get_shot_data.dart';

// BLE imports
import 'package:Slurvo/feature/ble/data/repositories/ble_repository_impl.dart';
import 'package:Slurvo/feature/ble/domain/repositories/ble_repository.dart';
import 'package:Slurvo/feature/ble/domain/usecases/scan_for_devices.dart';
import 'package:Slurvo/feature/ble/domain/usecases/connect_to_device.dart';
import 'package:Slurvo/feature/ble/domain/usecases/read_characteristic.dart';


final sl = GetIt.instance;

Future<void> init() async {

  sl.registerFactory(() => BleBloc(
    scanForDevices: sl(),
    connectToDevice: sl(),
    discoverServices: sl(),
    readCharacteristic: sl(),
    writeCharacteristic: sl(),
    shotRepository: sl()

  ));


  // Use cases
  sl.registerLazySingleton(() => GetShotData(sl()));

  // Repository
  sl.registerLazySingleton<BleRepository>(() => BleRepositoryImpl());

  sl.registerLazySingleton<ShotRepository>(() => ShotRepositoryImpl(localDataSource: sl()));

  // Data source
  sl.registerLazySingleton<ShotLocalDataSource>(() => ShotLocalDataSourceImpl());


  // Use cases
  sl.registerLazySingleton(() => ScanForDevices(sl()));
  sl.registerLazySingleton(() => ConnectToDevice(sl()));
  sl.registerLazySingleton(() => DiscoverServices(sl()));
  sl.registerLazySingleton(() => ReadCharacteristic(sl()));
  sl.registerLazySingleton(() => WriteCharacteristic(sl()));

}