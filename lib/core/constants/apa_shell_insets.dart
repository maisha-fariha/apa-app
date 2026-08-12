import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'apa_dimens.dart';

/// Layout insets for pages inside [ApaShell] (bottom nav + overlapping FAB).
abstract final class ApaShellInsets {
  static const double kExtraBottomGap = 20;

  /// Matches [ApaBottomNav] visible height + safe area + breathing room.
  static double contentBottom(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final topPad = ApaDimens.navTopPadding;
    final iconSize = ApaDimens.navIconSize;
    final labelGap = ApaDimens.navLabelTopSpacing;
    final labelRowHeight = 16.h;
    final bottomPad = ApaDimens.navBottomPadding;
    final overlapLift = ApaDimens.navFabOverlap - topPad;
    final barBodyHeight =
        topPad + iconSize + labelGap + labelRowHeight + bottomPad;

    return barBodyHeight +
        bottomInset +
        overlapLift +
        kExtraBottomGap.h;
  }
}
