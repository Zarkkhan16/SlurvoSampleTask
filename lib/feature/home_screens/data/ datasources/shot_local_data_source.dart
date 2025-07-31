import 'package:Slurvo/core/constants/app_strings.dart';

import '../models/shot_data_model.dart';

abstract class ShotLocalDataSource {
  Future<List<ShotDataModel>> getShotData();
  Future<void> deleteShotData(String shotId);
}

class ShotLocalDataSourceImpl implements ShotLocalDataSource {
  final List<ShotDataModel> _mockData = [
    ShotDataModel(id: '1', value: 0.00, metric: AppStrings.clubSpeedMetric, unit: AppStrings.mphUnit),
    ShotDataModel(id: '2', value: 0.00, metric: AppStrings.ballSpeedMetric, unit: AppStrings.mphUnit),
    ShotDataModel(id: '3', value: 0.00, metric: AppStrings.distanceMetric, unit: AppStrings.yardsUnit),
    ShotDataModel(id: '4', value: 0.00, metric: AppStrings.launchAngleMetric, unit: AppStrings.degreeUnit),
    ShotDataModel(id: '5', value: 0.00, metric: AppStrings.spinRateMetric, unit: AppStrings.rpmUnit),
  ];

  @override
  Future<List<ShotDataModel>> getShotData() async {
    await Future.delayed(Duration(milliseconds: 500));
    return _mockData;
  }

  @override
  Future<void> deleteShotData(String shotId) async {
    await Future.delayed(Duration(milliseconds: 300));
    _mockData.removeWhere((shot) => shot.id == shotId);
  }
}