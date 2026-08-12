import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/theme/apa_colors.dart';

/// Full-bleed construction photo with dark overlay from Figma.
class HomeBackground extends StatelessWidget {
  const HomeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Opacity(
            opacity: 0.85,
            child: Image.asset(
              ApaAssets.homeBackground,
              fit: BoxFit.cover,
              alignment: const Alignment(-0.4, 0),
            ),
          ),
        ),
        const ColoredBox(color: ApaColors.overlay70),
      ],
    );
  }
}
