import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Slurvo/core/constants/app_colors.dart';
import 'package:Slurvo/core/constants/app_strings.dart';
import '../../../../choose_club_screen/presentation/choose_club_screen_page.dart';

class HeaderRow extends StatefulWidget {
  final bool showClubName;
  final String headingName;
  final Club? selectedClub; // 👈 current selected club
  final Function(Club) onClubSelected; // 👈 callback when new club selected
  const HeaderRow({
    super.key,
    this.showClubName = false,
    this.headingName = AppStrings.shotAnalysisTitle,
    this.selectedClub,
    required this.onClubSelected,
  });

  @override
  State<HeaderRow> createState() => _HeaderRowState();
}

class _HeaderRowState extends State<HeaderRow> {

  late Club? _club;

  @override
  void initState() {
    super.initState();
    _club = widget.selectedClub;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final iconSize = screenWidth * 0.07; // ~7% of screen width
    final fontSize = screenWidth * 0.07; // ~7% of screen width

    return Row(
      mainAxisAlignment:
      widget.showClubName ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: AppColors.primaryText,
            size: iconSize.clamp(20.0, 34.0),
          ),
        ),

        // Center heading if no club name
        Expanded(
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.headingName,
                style: GoogleFonts.roboto(
                  textStyle: TextStyle(
                    fontSize: fontSize.clamp(18.0, 32.0),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Show club name if true, else keep spacing balanced
        if (widget.showClubName)
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChooseClubScreenPage(
                    selectedClub: _club, // 👈 pass current selection
                  ),
                ),
              );

              if (result != null && result is Club) {
                setState(() {
                  _club = result;
                });
                widget.onClubSelected(result); // 👈 notify parent
              }
            },
            child: Text(
              _club?.name ?? "Choose",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          )
        else
          const SizedBox(width: 34), // 👈 ensures symmetry with back icon
      ],
    );
  }
}
