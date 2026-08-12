import 'package:flutter/material.dart';

import '../../../../core/theme/apa_typography.dart';

/// Footer disclaimer under the donate button.
class HomeFooterNote extends StatelessWidget {
  const HomeFooterNote({
    super.key,
    this.text = 'ALL DONATIONS ARE 100% FOR HAITI',
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      textAlign: TextAlign.center,
      style: ApaTypography.footerNote,
    );
  }
}
