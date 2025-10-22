// feature/landing_dashboard/presentation/bloc/dashboard_event.dart

import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends DashboardEvent {}

class RefreshDashboard extends DashboardEvent {}
