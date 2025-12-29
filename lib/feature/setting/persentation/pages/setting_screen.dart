import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_strings.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/ble_management/domain/repositories/ble_management_repository.dart';
import 'package:onegolf/feature/setting/persentation/bloc/setting_bloc.dart';
import 'package:onegolf/feature/setting/persentation/bloc/setting_event.dart';
import 'package:onegolf/feature/setting/persentation/bloc/setting_state.dart';
import 'package:onegolf/feature/widget/gradient_border_container.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
        // bottomNavigationBar: const BottomNavBar(),
        appBar: const CustomAppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderRow(headingName: "Setting & Security"),
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
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  "Preferences",
                                  style: AppTextStyle.roboto(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              GradientBorderContainer(
                                borderRadius: 20,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Backlight",
                                      style: AppTextStyle.roboto(
                                        fontSize: 16,
                                      ),
                                    ),
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
                              GradientBorderContainer(
                                borderRadius: 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Screen Sleep Time:",
                                              style: AppTextStyle.roboto(
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "${state.sleepTime} min",
                                              style: AppTextStyle.roboto(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: state.isSending
                                                  ? null
                                                  : () => ctx
                                                      .read<SettingBloc>()
                                                      .add(
                                                          UpdateSleepTimeLocally(
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
                                                      if (state.sleepTime > 1) {
                                                        ctx.read<SettingBloc>().add(
                                                            UpdateSleepTimeLocally(
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
                                            : () => ctx.read<SettingBloc>().add(
                                                SendSleepTimeCommandEvent(
                                                    state.sleepTime)),
                                        child: const Text("OK",
                                            style:
                                                TextStyle(color: Colors.black)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              GradientBorderContainer(
                                borderRadius: 20,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Units",
                                      style: AppTextStyle.roboto(
                                        fontSize: 16,
                                      ),
                                    ),
                                    DropdownButton<String>(
                                      dropdownColor: Colors.grey[900],
                                      value: state.meters ? "Meters" : "Yards",
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
                              SizedBox(height: 20),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  "Security & Privacy",
                                  style: AppTextStyle.roboto(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  _openUrl(AppStrings.privacyAndPolicyUrl);
                                },
                                child: GradientBorderContainer(
                                  borderRadius: 20,
                                  containerHeight: 60,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Privacy Policy",
                                        style: AppTextStyle.roboto(),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  _openUrl(AppStrings.termsAndConditionUrl);
                                },
                                child: GradientBorderContainer(
                                  borderRadius: 20,
                                  containerHeight: 60,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Terms & Condition",
                                        style: AppTextStyle.roboto(),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('This feature is under development.'),
                                      behavior: SnackBarBehavior.floating,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: GradientBorderContainer(
                                  borderRadius: 20,
                                  containerHeight: 60,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Delete Account",
                                        style: AppTextStyle.roboto(
                                          color: AppColors.red,
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(
      uri,
      mode: LaunchMode.inAppWebView,
      webViewConfiguration: const WebViewConfiguration(
        enableJavaScript: true,
      ),
    )) {
      debugPrint('Could not launch $url');
    }
  }
}
