import 'package:flutter/material.dart';
import 'package:onegolf/core/constants/app_text_style.dart';
import 'package:onegolf/feature/home_screens/presentation/widgets/custom_app_bar/custom_app_bar.dart';
import 'package:onegolf/feature/home_screens/presentation/widgets/header/header_row.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../home_screens/presentation/widgets/bottom_nav_bar/bottom_nav_bar.dart';

class SessionSummaryScreen extends StatelessWidget {
  final Map<String, dynamic> summaryData;

  const SessionSummaryScreen({
    super.key,
    required this.summaryData,
  });

  @override
  Widget build(BuildContext context) {
    final shotAverages =
        summaryData['shotAverages'] as List<Map<String, dynamic>>? ?? [];
    final sessionSummary =
        summaryData['sessionSummary'] as Map<String, dynamic>? ?? {};
    final shotSummary =
        summaryData['shotSummary'] as List<Map<String, dynamic>>? ?? [];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.pushReplacementNamed(context, '/landingDashboard');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: CustomAppBar(),
        bottomNavigationBar: BottomNavBar(),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: HeaderRow(
                headingName: "Session Summary",
                onBackButton: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/landingDashboard',
                    (route) => false,
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildShotAveragesCard(shotAverages),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildSessionSummaryCard(sessionSummary),
                          SizedBox(height: 12),
                          Expanded(
                            child: _buildShotSummaryCard(shotSummary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildShotAveragesCard(List<Map<String, dynamic>> shotAverages) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(31),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Shot Averages',
              style: AppTextStyle.roboto(
                color: AppColors.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Per Club',
              style: AppTextStyle.roboto(
                color: AppColors.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            Divider(color: AppColors.dividerColor, thickness: 0.4),
            Expanded(
              child: SingleChildScrollView(
                child: _buildShotAveragesTable(shotAverages),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShotAveragesTable(List<Map<String, dynamic>> shotAverages) {
    return Table(
      columnWidths: {
        0: FixedColumnWidth(30),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
      },
      border: TableBorder(
        horizontalInside: BorderSide(color: AppColors.dividerColor, width: 0.4),
      ),
      children: [
        // Header Row
        TableRow(
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: AppColors.dividerColor, width: 0.4)),
          ),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 3),
              child: Text(
                'Club\nname',
                style: _headerStyle(),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 3),
              child: Text('Club\n(mph)',
                  style: _headerStyle(), textAlign: TextAlign.center),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 3),
              child: Text('Carry\n(yds)',
                  style: _headerStyle(), textAlign: TextAlign.center),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 3),
              child: Text('Total\n(yds)',
                  style: _headerStyle(), textAlign: TextAlign.center),
            ),
          ],
        ),
        // Data Rows
        ...shotAverages.map((avg) => _buildAverageTableRow(avg)),
      ],
    );
  }

  TableRow _buildAverageTableRow(Map<String, dynamic> avg) {
    return TableRow(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 3),
          child: Text(
            avg['clubDisplayName'],
            style: _tableHeaderStyle(),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 3),
          child: Column(
            children: [
              Text(
                avg['avgClubSpeed'].toStringAsFixed(1),
                style: _tableHeaderStyle(),
              ),
              Text(
                '+${avg['clubSpeedStdDev'].toStringAsFixed(1)}',
                style: _tableHeaderStyle(fontSized: 8),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 3),
          child: Column(
            children: [
              Text(
                avg['avgCarryDistance'].toStringAsFixed(1),
                style: _tableHeaderStyle(),
              ),
              Text(
                '+${avg['carryStdDev'].toStringAsFixed(1)}',
                style: _tableHeaderStyle(fontSized: 8),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 3),
          child: Column(
            children: [
              Text(
                avg['avgTotalDistance'].toStringAsFixed(1),
                style: _tableHeaderStyle(),
              ),
              Text(
                '+${avg['totalStdDev'].toStringAsFixed(1)}',
                style: _tableHeaderStyle(fontSized: 8),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionSummaryCard(Map<String, dynamic> sessionSummary) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(31),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Session Summary',
                style: AppTextStyle.roboto(
                  color: AppColors.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10),
              _buildSummaryRow(
                'Total Balls',
                sessionSummary['totalBalls']?.toString() ?? '0',
              ),
              Divider(
                color: AppColors.dividerColor,
                thickness: 0.4,
              ),
              _buildSummaryRow(
                'Session Time',
                sessionSummary['sessionTime']?.toString() ?? '00:00',
              ),
              Divider(
                color: AppColors.dividerColor,
                thickness: 0.4,
              ),
              _buildSummaryRow(
                'Clubs Used',
                sessionSummary['clubsUsed']?.toString() ?? '0',
              ),
              Divider(
                color: AppColors.dividerColor,
                thickness: 0.4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: _tableHeaderStyle(),
        ),
        Text(
          value,
          style: _tableHeaderStyle(),
        ),
      ],
    );
  }

  Widget _buildShotSummaryCard(List<Map<String, dynamic>> shotSummary) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(31),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Shot Summary',
              style: AppTextStyle.roboto(
                color: AppColors.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: AppColors.dividerColor,
                  ),
                ),
                child: ListView.builder(
                  itemCount: shotSummary.length,
                  itemBuilder: (context, index) {
                    return _buildShotRow(shotSummary[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShotRow(Map<String, dynamic> shot) {
    return Container(
      margin: EdgeInsets.only(bottom: 3),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Color(0xff111111).withOpacity(0.28),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Shot ${shot['shotNumber']}',
            style: _tableHeaderStyle(),
          ),
          Text(
            '${shot['carryDistance'].toStringAsFixed(1)}y',
            style: _tableHeaderStyle(),
          ),
        ],
      ),
    );
  }

  TextStyle _headerStyle() {
    return AppTextStyle.roboto(
      fontWeight: FontWeight.w400,
      fontSize: 11,
      color: AppColors.primaryText,
      height: 1.2,
    );
  }

  TextStyle _tableHeaderStyle({double? fontSized}) {
    return AppTextStyle.oswald(
      color: AppColors.primaryText,
      fontSize: fontSized ?? 14,
      fontWeight: FontWeight.w400,
    );
  }
}
