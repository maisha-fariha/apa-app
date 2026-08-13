import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/apa_colors.dart';
import '../../../../core/theme/apa_fonts.dart';

/// Destinations available from the More bottom sheet.
enum ApaMoreDestination {
  news,
  vision,
  contact,
}

extension ApaMoreDestinationX on ApaMoreDestination {
  String get label {
    switch (this) {
      case ApaMoreDestination.news:
        return 'NEWS & UPDATES';
      case ApaMoreDestination.vision:
        return 'OUR VISION';
      case ApaMoreDestination.contact:
        return 'CONTACT US';
    }
  }
}

/// Black modal bottom sheet listing More destinations (Figma more menu).
class ApaMoreSheet extends StatefulWidget {
  const ApaMoreSheet({
    super.key,
    required this.onSelected,
  });

  final ValueChanged<ApaMoreDestination> onSelected;

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<ApaMoreDestination> onSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ApaMoreSheet(onSelected: onSelected),
    );
  }

  @override
  State<ApaMoreSheet> createState() => _ApaMoreSheetState();
}

class _ApaMoreSheetState extends State<ApaMoreSheet> {
  ApaMoreDestination? _pressed;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ApaColors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 28.h + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: ApaColors.white30,
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          SizedBox(height: 28.h),
          ...ApaMoreDestination.values.map((destination) {
            final isPressed = _pressed == destination;
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onSelected(destination);
                  },
                  onHighlightChanged: (v) {
                    setState(() => _pressed = v ? destination : null);
                  },
                  borderRadius: BorderRadius.circular(8.r),
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 18.h),
                      child: Text(
                        destination.label,
                        textAlign: TextAlign.center,
                        style: ApaFonts.inter(
                          color: isPressed
                              ? ApaColors.primaryRed
                              : ApaColors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
