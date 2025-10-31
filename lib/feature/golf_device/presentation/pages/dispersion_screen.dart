import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onegolf/core/constants/app_strings.dart';
import 'package:onegolf/feature/golf_device/data/model/shot_anaylsis_model.dart';
import 'package:onegolf/feature/golf_device/presentation/pages/session_summary_screen.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../widget/bottom_nav_bar.dart';
import '../../../widget/glassmorphism_card.dart';
import '../../../widget/custom_app_bar.dart';
import '../../../widget/session_view_button.dart';
import '../bloc/golf_device_bloc.dart';
import '../bloc/golf_device_event.dart';
import '../bloc/golf_device_state.dart';

class DispersionScreen extends StatelessWidget {
  final ShotAnalysisModel? selectedShot;

  const DispersionScreen({
    super.key,
    required this.selectedShot,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GolfDeviceBloc, GolfDeviceState>(
        listener: (context, state) {
          if (state is NavigateToSessionSummaryState) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => SessionSummaryScreen(
                  summaryData: state.summaryData,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DisconnectingState) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Disconnecting device...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }
          return Scaffold(
              backgroundColor: Colors.black,
              appBar: CustomAppBar(),
              bottomNavigationBar: const BottomNavBar(),
              body: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
                child: Column(
                  children: [
                    HeaderRow(
                      headingName: AppStrings.dispersionText,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 30,
                          mainAxisSpacing: 15,
                          childAspectRatio: 1.7,
                        ),
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          final shot = selectedShot;
                          final metrics = [
                            {
                              "metric": "Club Speed",
                              "value":
                                  shot?.clubSpeed.toStringAsFixed(1) ?? '0.0',
                              "unit": "MPH"
                            },
                            {
                              "metric": "Ball Speed",
                              "value":
                                  shot?.ballSpeed.toStringAsFixed(1) ?? '0.0',
                              "unit": "MPH"
                            },
                            {
                              "metric": "Carry Distance",
                              "value": shot?.carryDistance.toStringAsFixed(1) ??
                                  '0.0',
                              "unit": "YDS"
                            },
                            {
                              "metric": "Smash Factor",
                              "value":
                                  shot?.smashFactor.toStringAsFixed(2) ?? '0.0',
                              "unit": ""
                            },
                          ];
                          return GlassmorphismCard(
                            value: metrics[index]["value"]!,
                            name: metrics[index]["metric"]!,
                            unit: metrics[index]["unit"]!,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 5),
                    Expanded(
                      flex: 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final carry = selectedShot?.carryDistance ?? 0.0;
                            // final carry = 299.0;
                            const maxDistance = 400.0;
                            final isOverLimit = carry > maxDistance;
                            final displayDistance =
                                carry.clamp(0.0, maxDistance);
                            final totalHeight = constraints.maxHeight;
                            final step = totalHeight / 9;
                            final stepsFromBottom = displayDistance / 50.0;
                            final bottomLineOffset = 19.0;
                            final bottomY =
                                totalHeight - step + bottomLineOffset;
                            final yPos = bottomY - (step * stepsFromBottom);

                            return Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.asset(
                                    AppImages.dispersionGround,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: FairwayLinesPainter(),
                                  ),
                                ),
                                // Ball position
                                isOverLimit
                                    ? Positioned(
                                        left: constraints.maxWidth / 2 - 6,
                                        top: yPos - 19,
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Positioned(
                                        left: constraints.maxWidth / 2 - 6,
                                        top: yPos - 6,
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SessionViewButton(
                      backgroundColor: AppColors.red,
                      textColor: AppColors.primaryText,
                      onSessionClick: () {
                        context.read<GolfDeviceBloc>().add(
                            DisconnectDeviceEvent());
                      },
                      buttonText: AppStrings.sessionEndText,
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              ));
        });
  }
}

class FairwayLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint solidLinePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final Paint dashedLinePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // === Constants for dashed lines ===
    const double dashWidth = 5;
    const double dashSpace = 5;

    // === Horizontal curved solid lines and labels ===
    final step = size.height / 9; // 9 equal sections
    final distances = [0, 50, 100, 150, 200, 250, 300, 350, 400];

    // Skip 0-yard line (start from 50)
    for (int i = 1; i <= 8; i++) {
      final y = size.height - (step * i);

      // Draw curved horizontal line
      final path = Path();
      path.moveTo(0, y);

      final curveDepth = step * 1.2;
      path.quadraticBezierTo(
        size.width / 2,
        y - curveDepth,
        size.width,
        y,
      );

      canvas.drawPath(path, solidLinePaint);

      // === Distance label (left side only) ===
      final distance = distances[i];
      textPainter.text = TextSpan(
        text: '$distance',
        style: TextStyle(
          color: Colors.white,
          fontSize: size.width * 0.04,
        ),
      );
      textPainter.layout();

      // Position label on left side
      final labelY = y - curveDepth * 0.5;
      textPainter.paint(
        canvas,
        Offset(size.width * 0.25, labelY - textPainter.height / 1.4),
      );
    }

    // === Bottom dashed line (aligned with 50-yard curve) ===
    double dashX = 2;
    final bottomY = size.height - (step * 1) + 19;
    while (dashX < size.width) {
      canvas.drawLine(
        Offset(dashX, bottomY - 2),
        Offset(dashX + dashWidth, bottomY - 2),
        dashedLinePaint,
      );
      dashX += dashWidth + dashSpace;
    }

    textPainter.text = TextSpan(
      text: '0',
      style: TextStyle(
        color: Colors.white,
        fontSize: size.width * 0.04,
      ),
    );
    textPainter.layout();

    // Position same as others (left side)
    final labelY = bottomY - (step * 1.2) * 0.2;
    textPainter.paint(
      canvas,
      Offset(size.width * 0.26, labelY - textPainter.height / 2),
    );

    // === Vertical dashed center line (starts from 50-yard baseline) ===
    final double centerX = size.width / 2;
    double startY = bottomY;
    while (startY > 0) {
      canvas.drawLine(
        Offset(centerX, startY),
        Offset(centerX, startY - dashWidth),
        dashedLinePaint,
      );
      startY -= dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
