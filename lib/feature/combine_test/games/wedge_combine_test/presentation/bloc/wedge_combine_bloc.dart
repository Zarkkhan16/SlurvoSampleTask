import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/feature/ble_management/domain/repositories/ble_management_repository.dart';
import 'package:onegolf/feature/combine_test/domain/entities/wedge_rules.dart';
import 'package:onegolf/feature/golf_device/domain/entities/golf_data_entities.dart';
import 'package:onegolf/feature/golf_device/domain/repositories/ble_repository.dart';
import '../../../../domain/entities/category_summary.dart';
import '../../../../domain/entities/distance_category.dart';
import '../../../../domain/entities/handicap_rule.dart';
import '../../../../domain/entities/wedge_shot.dart';
import 'wedge_combine_event.dart';
import 'wedge_combine_state.dart';

class WedgeCombineBloc extends Bloc<WedgeCombineEvent, WedgeCombineState> {
  final BleManagementRepository bleRepository;
  StreamSubscription? _bleSubscription;
  Timer? _syncTimer;
  final StreamController<List<int>> _bleDataController =
      StreamController<List<int>>.broadcast();
  GolfDataEntity _golfData = GolfDataEntity(
    battery: 0,
    recordNumber: 0,
    clubName: 0,
    clubSpeed: 0.0,
    ballSpeed: 0.0,
    carryDistance: 0.0,
    totalDistance: 0.0,
  );
  bool _units = false;
  GolfDataEntity? _firstPacketBaseline;
  GolfDataEntity? _lastValidGolfData;
  bool _isFirstPacketHandled = false;

  WedgeCombineBloc({required this.bleRepository})
      : super(
          WedgeCombineState(
            shots: [],
            currentIndex: 0,
            projectedScore: 0,
          ),
        ) {
    on<WedgeCombineStartedEvent>(_onStart);
    on<BleDataReceivedEvent>(_onBleDataReceivedEvent);
    on<MoveToNextShotEvent>(_onMoveToNextShot);
    on<FinishSessionEvent>(_onFinishSession);
    on<ResetWedgeCombineEvent>(_onResetSession);
  }

  bool _isSameGolfData(GolfDataEntity a, GolfDataEntity b) {
    return a.recordNumber == b.recordNumber &&
        a.clubName == b.clubName &&
        a.clubSpeed == b.clubSpeed &&
        a.ballSpeed == b.ballSpeed &&
        a.carryDistance == b.carryDistance &&
        a.totalDistance == b.totalDistance;
  }

  void _onStart(
    WedgeCombineStartedEvent event,
    Emitter<WedgeCombineState> emit,
  ) {
    final shots = generateAllShots();
    print("Generate Random Shots");
    int i = 0;
    for (final shot in shots) {
      print(
        'Shot ${i} | '
            'Cat ${shot.categoryId} | '
            'Target ${shot.targetCarry}',
      );
      i++;
    }
    _subscribeToBleData();

    emit(
      WedgeCombineState(
        shots: shots,
        currentIndex: 0,
        projectedScore: 0,
      ),
    );
  }

  Future<void> _subscribeToBleData() async {
    print('🎮 Wedge Combine Test: Starting BLE listener...');

    if (!bleRepository.isConnected) {
      print('❌ Not connected');
      return;
    }

    try {
      final deviceId = bleRepository.connectedDeviceId;
      if (deviceId != null) {
        print('🔍 Re-discovering services...');
        await bleRepository.discoverServices(deviceId);
        print('✅ Services discovered');

        // Small delay to ensure services ready
        await Future.delayed(Duration(milliseconds: 500));
      }
    } catch (e) {
      print('❌ Service discovery failed: $e');
      return;
    }

    await _bleSubscription?.cancel();
    _bleSubscription = bleRepository.subscribeToNotifications().listen(
      (data) {
        print('📡 BLE Data received in Distance Master: $data');
        add(BleDataReceivedEvent(data));
        _bleDataController.add(data);
      },
      onError: (error) {
        print('❌ BLE error: $error');
      },
      onDone: () {
        print('⚠️ Stream closed');
      },
    );
    _startSyncTimer();
    print('✅ Listener started');
  }

  void _onBleDataReceivedEvent(
    BleDataReceivedEvent event,
    Emitter<WedgeCombineState> emit,
  ) {
    print('🎮 Wedge Games: Processing BLE data...');
    try {
      _parseGolfData(Uint8List.fromList(event.data));

      if (!_isFirstPacketHandled) {
        _isFirstPacketHandled = true;
        _firstPacketBaseline = _golfData;
        print("🧠 Wedge: Baseline stored (first packet)");
        return;
      }

      // 🔁 SECOND PACKET vs BASELINE
      if (_firstPacketBaseline != null) {
        if (_isSameGolfData(_firstPacketBaseline!, _golfData)) {
          print("🔁 Wedge: Same as baseline → ignored");
          return;
        }

        print("✅ Wedge: Different from baseline → accepted");
        _firstPacketBaseline = null; // baseline consumed
      }

      // 🔁 DUPLICATE FILTER (after baseline phase)
      if (_lastValidGolfData != null &&
          _isSameGolfData(_lastValidGolfData!, _golfData)) {
        print("🔁 Wedge: Duplicate packet ignored");
        return;
      }

      // ✅ VALID SHOT
      _lastValidGolfData = _golfData;

      final shots = [...state.shots];
      final shot = shots[state.currentIndex];

      double actualCarry = double.parse(
        _golfData.carryDistance.toStringAsFixed(1),
      );

      shot.actualCarry = actualCarry;
      shot.distanceFromTarget = shot.targetCarry - actualCarry;
      shot.score = calculateShotScore(shot.distanceFromTarget!);

      final playedShots = shots.take(state.currentIndex + 1);
      final totalScore =
          playedShots.map((s) => s.score ?? 0).reduce((a, b) => a + b);

      final projected = totalScore / playedShots.length;

      emit(
        WedgeCombineState(
          shots: shots,
          currentIndex: state.currentIndex,
          projectedScore: projected,
          isFinished: false,
          shotJustPlayed: true,
        ),
      );

      Future.delayed(
        const Duration(milliseconds: 3500),
        () {
          if (!isClosed) {
            add(MoveToNextShotEvent());
          }
        },
      );
    } catch (e) {
      print('❌ Failed to parse BLE data: $e');
    }
  }

  void _onMoveToNextShot(
      MoveToNextShotEvent event,
      Emitter<WedgeCombineState> emit,
      ) {
    final isLast = state.currentIndex + 1 >= state.shots.length;

    emit(
      WedgeCombineState(
        shots: state.shots,
        currentIndex:
        isLast ? state.currentIndex : state.currentIndex + 1,
        projectedScore: 0,
        isFinished: isLast,
        shotJustPlayed: false,
      ),
    );

    if (isLast) {
      // bleRepository.stop();
    }
  }


  void _parseGolfData(Uint8List data) {
    if (data[0] != 0x47 || data[1] != 0x46) return;

    bool isMeters = (data[11] & 0x80) != 0;
    int carryHigh = data[11] & 0x7F;
    int carryLow = data[12];
    double carryDistance = ((carryHigh << 8) | carryLow) / 10.0;
    double totalDistance = ((data[13] << 8) | data[14]) / 10.0;

    if (isMeters) {
      carryDistance *= 1.09361;
      totalDistance *= 1.09361;
    }

    _golfData = GolfDataEntity(
      battery: data[3],
      recordNumber: (data[4] << 8) | data[5],
      clubName: data[6],
      clubSpeed: ((data[7] << 8) | data[8]) / 10.0,
      ballSpeed: ((data[9] << 8) | data[10]) / 10.0,
      carryDistance: carryDistance,
      totalDistance: totalDistance,
    );

    _units = isMeters ? false : true;

    print("📊 Parsed Golf Data:");
    print("   Record: ${_golfData.recordNumber}");
    print("   Club: ${_golfData.clubName}");
    print("   Carry: ${_golfData.carryDistance.toStringAsFixed(1)} YD");
    print("   Total: ${_golfData.totalDistance.toStringAsFixed(1)} YD");
    print("   Unit Mode: YARDS");
  }

  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(Duration(seconds: 1), (_) async {
      if (bleRepository.isConnected) {
        int checksum = (0x01 + 0x00) & 0xFF;
        await bleRepository.writeData([0x47, 0x46, 0x01, 0x00, 0x00, checksum]);
      }
    });
  }

  List<CategorySummary> buildCategorySummary(List<WedgeShot> shots) {
    final List<CategorySummary> result = [];

    for (final category in wedgeCategories) {
      final categoryShots = shots
          .where((s) => s.categoryId == category.id)
          .toList();

      // ⚠️ safety (should always be 6, but still)
      if (categoryShots.isEmpty) {
        result.add(
          CategorySummary(
            rangeLabel:
            '${category.min.toInt()}-${category.max.toInt()}',
            averageScore: 0,
            handicap: 'N/A',
          ),
        );
        continue;
      }

      final avgScore = categoryAverageScore(categoryShots);
      final handicap = getHandicap(avgScore);

      result.add(
        CategorySummary(
          rangeLabel:
          '${category.min.toInt()}-${category.max.toInt()}',
          averageScore: avgScore,
          handicap: handicap,
        ),
      );
    }

    return result;
  }


  String getHandicap(double score) {
    for (final rule in handicapRules) {
      if (score >= rule.minScore && score <= rule.maxScore) {
        return rule.handicap;
      }
    }
    return 'N/A';
  }

  // double categoryAverageScore(List<WedgeShot> shots) {
  //   print("averageScore");
  //   print(shots);
  //   final total = shots.map((s) => s.score ?? 0).reduce((a, b) => a + b);
  //
  //   return total / shots.length;
  // }

  // double calculateFinalScore(List<WedgeShot> shots) {
  //   final total = shots.map((s) => s.score ?? 0).reduce((a, b) => a + b);
  //
  //   return total / shots.length;
  // }
  double categoryAverageScore(List<WedgeShot> shots) {
    final playedShots = shots.where((s) => s.score != null).toList();

    if (playedShots.isEmpty) return 0;

    final total = playedShots
        .map((s) => s.score!)
        .reduce((a, b) => a + b);

    return total / playedShots.length;
  }

  double calculateFinalScore(List<WedgeShot> shots) {
    final playedShots = shots.where((s) => s.score != null).toList();

    if (playedShots.isEmpty) return 0;

    final total = playedShots
        .map((s) => s.score!)
        .reduce((a, b) => a + b);

    return total / playedShots.length;
  }

  void _onFinishSession(
      FinishSessionEvent event,
      Emitter<WedgeCombineState> emit,
      ) {
    print('🏁 Finish session requested');

    // 🛑 BLE + Timer stop
    _bleSubscription?.cancel();
    _bleSubscription = null;

    _syncTimer?.cancel();
    _syncTimer = null;

    _firstPacketBaseline = null;
    _lastValidGolfData = null;
    _isFirstPacketHandled = false;

    emit(
      WedgeCombineState(
        shots: state.shots,
        currentIndex: state.currentIndex,
        projectedScore: state.projectedScore,
        isFinished: true,
        shotJustPlayed: false,
      ),
    );
  }

  void _onResetSession(
      ResetWedgeCombineEvent event,
      Emitter<WedgeCombineState> emit,
      ) {
    print('Reset Wedge Combine Test');

    _bleSubscription?.cancel();
    _bleSubscription = null;

    _syncTimer?.cancel();
    _syncTimer = null;

    _firstPacketBaseline = null;
    _lastValidGolfData = null;
    _isFirstPacketHandled = false;

    emit(
      WedgeCombineState(
        shots: [],
        currentIndex: 0,
        projectedScore: 0,
        isFinished: false,
        shotJustPlayed: false,
      ),
    );
  }

  @override
  Future<void> close() {
    _bleSubscription?.cancel();
    return super.close();
  }
}
