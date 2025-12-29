import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onegolf/core/constants/app_colors.dart';
import 'package:onegolf/core/constants/app_strings.dart';
import '../choose_club_screen/model/club_model.dart';
import '../choose_club_screen/presentation/choose_club_screen_page.dart';

class HeaderRow extends StatefulWidget {
  final bool showClubName;
  final String headingName;
  final Club? selectedClub;
  final Function(Club)? onClubSelected;
  final bool goScanScreen;
  final bool backButtonHide;
  final Function()? onBackButton;

  const HeaderRow({
    super.key,
    this.showClubName = false,
    this.headingName = AppStrings.shotAnalysisTitle,
    this.selectedClub, // 👈 optional
    this.onClubSelected, // 👈 optional
    this.goScanScreen = false,
    this.backButtonHide = false,
    this.onBackButton,
  });

  @override
  State<HeaderRow> createState() => _HeaderRowState();
}

class _HeaderRowState extends State<HeaderRow> {
  late int _club;

  @override
  void initState() {
    super.initState();
    _club = widget.selectedClub != null ? int.parse(widget.selectedClub!.code) : 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentClubCode = widget.selectedClub != null
        ? int.parse(widget.selectedClub!.code)
        : 0;
    final screenWidth = MediaQuery.of(context).size.width;

    final iconSize = screenWidth * 0.07;
    final fontSize = screenWidth * 0.07;

    return Row(
      mainAxisAlignment:
      widget.showClubName ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
      children: [
        widget.backButtonHide ? SizedBox.shrink() : GestureDetector(
          onTap: widget.onBackButton ?? () {
            if (widget.goScanScreen) {
            } else {
              Navigator.pop(context);
            }
          },
          child: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: AppColors.primaryText,
            size: iconSize.clamp(20.0, 34.0),
          ),
        ),

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

        if (widget.showClubName && widget.selectedClub != null)
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChooseClubScreenPage(
                    selectedClub: widget.selectedClub!,
                  ),
                ),
              );

              if (result != null && result is Club) {
                widget.onClubSelected?.call(result);
              }
            },
            child: Text(
              "(${AppStrings.getLoft(currentClubCode)}) ${AppStrings.getClub(currentClubCode)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          )
        else
          const SizedBox(width: 34),
      ],
    );
  }

}

