// import 'package:flutter/material.dart';
//
// import '../../../core/constants/app_colors.dart';
// import '../../home_screens/presentation/widgets/bottom_nav_bar/bottom_nav_bar.dart';
// import '../../home_screens/presentation/widgets/custom_app_bar/custom_app_bar.dart';
// import '../../home_screens/presentation/widgets/header/header_row.dart';
//
// class ChooseClubScreenPage extends StatefulWidget {
//   const ChooseClubScreenPage({super.key});
//
//   @override
//   State<ChooseClubScreenPage> createState() => _ChooseClubScreenPageState();
// }
//
// class _ChooseClubScreenPageState extends State<ChooseClubScreenPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primaryBackground,
//       bottomNavigationBar: const BottomNavBar(),
//       appBar: const CustomAppBar(),
//       body: Column(
//         children: [
//           const Divider(thickness: 1, color: AppColors.dividerColor),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(
//                     height: 60,
//                     child: HeaderRow(
//                       headingName: 'Choose a Club',
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../home_screens/presentation/widgets/bottom_nav_bar/bottom_nav_bar.dart';
import '../../home_screens/presentation/widgets/custom_app_bar/custom_app_bar.dart';
import '../../home_screens/presentation/widgets/header/header_row.dart';

// Club model
class Club {
  final String code;
  final String name;
  Club({required this.code, required this.name});
}

class ChooseClubScreenPage extends StatefulWidget {
  final Club? selectedClub; // <- previously selected club (from parent)

  const ChooseClubScreenPage({super.key, this.selectedClub});

  @override
  State<ChooseClubScreenPage> createState() => _ChooseClubScreenPageState();
}

class _ChooseClubScreenPageState extends State<ChooseClubScreenPage> {
  List<Club> clubs = [];
  Club? selectedClub;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    selectedClub = widget.selectedClub; // restore old selection
    _loadClubs();
  }

  Future<void> _loadClubs() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final fetchedClubs = [
      Club(code: "1", name: "Driver Wood"),
      Club(code: "2", name: "3 Wood"),
      Club(code: "3", name: "5 Wood"),
      Club(code: "4", name: "7 Wood"),
      Club(code: "5", name: "1 Hybrid"),
      Club(code: "6", name: "2 Hybrid"),
      Club(code: "7", name: "3 Hybrid"),
      Club(code: "8", name: "4 Hybrid"),
      Club(code: "9", name: "5 Hybrid"),
      Club(code: "10", name: "2 Iron"),
      Club(code: "11", name: "3 Iron"),
      Club(code: "12", name: "4 Iron"),
      Club(code: "13", name: "5 Iron"),
      Club(code: "14", name: "6 Iron"),
      Club(code: "15", name: "7 Iron"),
      Club(code: "16", name: "8 Iron"),
      Club(code: "17", name: "9 Iron"),
      Club(code: "18", name: "Pitching Wedge"),
      Club(code: "19", name: "50 Wedge"),
      Club(code: "20", name: "52 Wedge"),
      Club(code: "21", name: "54 Wedge"),
      Club(code: "22", name: "56 Wedge"),
      Club(code: "23", name: "58 Wedge"),
      Club(code: "24", name: "60 Wedge"),
    ];

    setState(() {
      clubs = fetchedClubs;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      bottomNavigationBar: const BottomNavBar(),
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          const Divider(thickness: 1, color: AppColors.dividerColor),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 60,
                    child: HeaderRow(
                      headingName: 'Choose a Club', onClubSelected: (Club p1) {  },
                    ),
                  ),
                  Expanded(child: _buildBody()),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) return const Center(child: CircularProgressIndicator(color: Colors.white,));
    if (error != null) {
      return Center(child: Text(error!, style: const TextStyle(color: Colors.white)));
    }

    // group clubs
    final woods = clubs.where((c) => c.name.contains("Wood")).toList();
    final hybrids = clubs.where((c) => c.name.contains("Hybrid")).toList();
    final irons = clubs.where((c) => c.name.contains("Iron")).toList();
    final wedges = clubs.where((c) => c.name.contains("Wedge")).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategory("WOODS", woods),
          const SizedBox(height: 20),
          _buildCategory("HYBRIDS", hybrids),
          const SizedBox(height: 20),
          _buildCategory("IRONS", irons),
          const SizedBox(height: 20),
          _buildCategory("WEDGES", wedges),
        ],
      ),
    );
  }

  Widget _buildCategory(String title, List<Club> categoryClubs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: categoryClubs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 3,
          ),
          itemBuilder: (context, index) {
            final club = categoryClubs[index];
            final isSelected = selectedClub?.code == club.code;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedClub = club;
                });
                Navigator.pop(context, club); // return selected club
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Text(
                  club.name,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
