// feature/landing_dashboard/presentation/bloc/dashboard_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';

abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final UserProfile userProfile;

  DashboardLoaded(this.userProfile);

  @override
  List<Object?> get props => [userProfile];
}

class DashboardError extends DashboardState {
  final String message;

  DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}