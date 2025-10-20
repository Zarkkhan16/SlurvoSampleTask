// feature/landing_dashboard/presentation/bloc/dashboard_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_user_profile.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetUserProfile getUserProfile;

  DashboardBloc({required this.getUserProfile}) : super(DashboardInitial()) {

    on<LoadUserProfile>((event, emit) async {
      emit(DashboardLoading());

      try {
        final profile = await getUserProfile(event.uid);

        if (profile != null) {
          emit(DashboardLoaded(profile));
        } else {
          emit(DashboardError('Failed to load user profile'));
        }
      } catch (e) {
        emit(DashboardError('An error occurred: ${e.toString()}'));
      }
    });

    on<RefreshDashboard>((event, emit) async {
      // Refresh logic here if needed
      if (state is DashboardLoaded) {
        final currentState = state as DashboardLoaded;
        emit(DashboardLoading());

        try {
          final profile = await getUserProfile(currentState.userProfile.uid);

          if (profile != null) {
            emit(DashboardLoaded(profile));
          } else {
            emit(DashboardError('Failed to refresh'));
          }
        } catch (e) {
          emit(DashboardError('Refresh failed: ${e.toString()}'));
        }
      }
    });
  }
}