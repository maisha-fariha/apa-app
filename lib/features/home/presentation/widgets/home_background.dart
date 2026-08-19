import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/theme/apa_colors.dart';

/// Full-bleed construction photo with dark overlay from Figma.
class HomeBackground extends StatelessWidget {
  const HomeBackground({super.key, this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final networkUrl = imageUrl?.trim();
    final image = networkUrl != null && networkUrl.isNotEmpty
        ? Image.network(
            networkUrl,
            fit: BoxFit.cover,
            alignment: const Alignment(-0.4, 0),
            errorBuilder: (context, error, stackTrace) => Image.asset(
              ApaAssets.homeBackground,
              fit: BoxFit.cover,
              alignment: const Alignment(-0.4, 0),
            ),
          )
        : Image.asset(
            ApaAssets.homeBackground,
            fit: BoxFit.cover,
            alignment: const Alignment(-0.4, 0),
          );

    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Opacity(
            opacity: 0.85,
            child: image,
          ),
        ),
        const ColoredBox(color: ApaColors.overlay70),
      ],
    );
  }
}
