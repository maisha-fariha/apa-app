import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders a Figma-exported SVG at a responsive leaf size.
class ApaSvgIcon extends StatelessWidget {
  const ApaSvgIcon({
    super.key,
    required this.assetPath,
    required this.size,
    this.color,
  });

  final String assetPath;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final s = size.w;
    return SizedBox(
      width: s,
      height: s,
      child: SvgPicture.asset(
        assetPath,
        width: s,
        height: s,
        fit: BoxFit.contain,
        colorFilter: color == null
            ? null
            : ColorFilter.mode(color!, BlendMode.srcIn),
      ),
    );
  }
}
