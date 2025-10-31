import 'package:flutter/material.dart';
import 'package:onegolf/feature/widget/custom_app_bar.dart';
import 'package:onegolf/feature/widget/header_row.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widget/bottom_nav_bar.dart';

class MetricFilterScreen extends StatefulWidget {
  final Set<String> initialSelectedMetrics;

  const MetricFilterScreen({
    super.key,
    required this.initialSelectedMetrics,
  });

  @override
  State<MetricFilterScreen> createState() => _MetricFilterScreenState();
}

class _MetricFilterScreenState extends State<MetricFilterScreen> {
  late Set<String> selectedMetrics;

  final List<String> allMetrics = [
    'Ball Speed',
    'Club Speed',
    'Carry Distance',
    'Total Distance',
    'Smash Factor',
  ];

  @override
  void initState() {
    super.initState();
    selectedMetrics = Set.from(widget.initialSelectedMetrics);
  }

  void toggleMetric(String metric) {
    setState(() {
      if (selectedMetrics.contains(metric)) {
        if (selectedMetrics.length > 1) {
          selectedMetrics.remove(metric);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('At least one metric must be selected'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        selectedMetrics.add(metric);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(),
      bottomNavigationBar: const BottomNavBar(),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderRow(headingName: "Customise Shot Analysis",),
                  SizedBox(height: 25,),
                  Expanded(
                    child: ListView.separated(
                      itemCount: allMetrics.length,
                      separatorBuilder: (context, index) =>
                      const SizedBox(height: 15),
                      itemBuilder: (context, index) {
                        final metric = allMetrics[index];
                        final isSelected = selectedMetrics.contains(metric);

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              toggleMetric(metric);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(35),
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color.fromRGBO(128, 128, 128, 1.0),
                                    Color.fromRGBO(128, 128, 128, 0.05),
                                    Color.fromRGBO(128, 128, 128, 0.3),
                                  ],
                                ),
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(1),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color:AppColors.cardBackground,
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? AppColors.primaryText
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primaryText
                                              : AppColors.secondaryText,
                                          width: 2,
                                        ),
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: AppColors.primaryBackground,
                                      )
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      metric.toUpperCase(),
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.primaryText
                                            : AppColors.secondaryText,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.pop(context, selectedMetrics);
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.2),
                    ],
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1C),
                    borderRadius: BorderRadius.circular(31),
                  ),
                  child: Center(
                    child: Text(
                      'Apply (${selectedMetrics.length} selected)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
