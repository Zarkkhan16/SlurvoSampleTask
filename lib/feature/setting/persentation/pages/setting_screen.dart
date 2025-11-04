import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/feature/ble_management/domain/repositories/ble_management_repository.dart';
import 'package:onegolf/feature/setting/persentation/bloc/setting_bloc.dart';
import 'package:onegolf/feature/setting/persentation/bloc/setting_event.dart';
import 'package:onegolf/feature/setting/persentation/bloc/setting_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection_container.dart';
import '../../../golf_device/data/services/ble_service.dart';
import '../../../golf_device/domain/entities/device_entity.dart';
import '../../../golf_device/domain/usecases/send_command_usecase.dart';
import '../../../widget/bottom_nav_bar.dart';
import '../../../widget/custom_app_bar.dart';
import '../../../widget/header_row.dart';

class SettingScreen extends StatelessWidget {
  final bool selectedUnit;

  const SettingScreen({
    super.key,
    required this.selectedUnit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingBloc>(
      create: (_) => SettingBloc(
        bleManagementRepository: sl<BleManagementRepository>(),
        sharedPreferences: sl<SharedPreferences>(),
      )..add(LoadSettingsEvent(initialUnit: selectedUnit)),
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground,
        bottomNavigationBar: const BottomNavBar(),
        appBar: const CustomAppBar(),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 60,
                    child: HeaderRow(headingName: "Setting & Security"),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: BlocConsumer<SettingBloc, SettingState>(
                      listener: (ctx, state) {
                        if (state is SettingError) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text(state.message)),
                          );
                        }
                      },
                      builder: (ctx, state) {
                        if (state is SettingLoaded) {
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildCard(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Backlight",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16)),
                                      Transform.scale(
                                        scale: 0.8,
                                        child: Switch(
                                          value: state.backlight,
                                          onChanged: state.isSending
                                              ? null
                                              : (v) => ctx
                                                  .read<SettingBloc>()
                                                  .add(ToggleBacklightEvent(v)),
                                          activeTrackColor: Colors.white,
                                          inactiveTrackColor: Colors.grey,
                                          thumbColor:
                                              MaterialStateProperty.resolveWith(
                                            (states) => Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // 💤 Sleep Time Card
                                _buildCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Text("Screen Sleep Time:",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16)),
                                              const SizedBox(width: 8),
                                              Text("${state.sleepTime} min",
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16)),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: state.isSending
                                                    ? null
                                                    : () => ctx
                                                        .read<SettingBloc>()
                                                        .add(UpdateSleepTimeLocally(
                                                            state.sleepTime +
                                                                1)),
                                                child: const Icon(Icons.add,
                                                    color: Colors.white,
                                                    size: 22),
                                              ),
                                              const SizedBox(width: 10),
                                              GestureDetector(
                                                onTap: state.isSending
                                                    ? null
                                                    : () {
                                                        if (state.sleepTime >
                                                            1) {
                                                          ctx
                                                              .read<
                                                                  SettingBloc>()
                                                              .add(UpdateSleepTimeLocally(
                                                                  state.sleepTime -
                                                                      1));
                                                        }
                                                      },
                                                child: const Icon(Icons.remove,
                                                    color: Colors.white,
                                                    size: 22),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: state.isSending
                                              ? null
                                              : () => ctx
                                                  .read<SettingBloc>()
                                                  .add(
                                                      SendSleepTimeCommandEvent(
                                                          state.sleepTime)),
                                          child: const Text("OK",
                                              style: TextStyle(
                                                  color: Colors.black)),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // 📏 Unit Selection Card
                                _buildCard(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Units",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16)),
                                      DropdownButton<String>(
                                        dropdownColor: Colors.grey[900],
                                        value:
                                            state.meters ? "Meters" : "Yards",
                                        underline: const SizedBox(),
                                        items: const [
                                          DropdownMenuItem(
                                              value: "Yards",
                                              child: Text("Yards",
                                                  style: TextStyle(
                                                      color: Colors.white))),
                                          DropdownMenuItem(
                                              value: "Meters",
                                              child: Text("Meters",
                                                  style: TextStyle(
                                                      color: Colors.white))),
                                        ],
                                        onChanged: state.isSending
                                            ? null
                                            : (value) {
                                                if (value != null) {
                                                  ctx.read<SettingBloc>().add(
                                                      ChangeUnitEvent(
                                                          value == "Meters"));
                                                }
                                              },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (state is SettingLoading) {
                          return const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                  ),
                ],
              ),

              /// 🔄 Fullscreen overlay when sending
              BlocBuilder<SettingBloc, SettingState>(
                builder: (ctx, state) {
                  if (state is SettingLoaded && state.isSending) {
                    return Container(
                      color: Colors.black.withOpacity(0.4),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: Colors.grey[900], borderRadius: BorderRadius.circular(30)),
      child: child,
    );
  }
}
