import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'apa_dimens.dart';

/// Layout insets for pages inside [ApaShell] (bottom nav + overlapping FAB).
abstract final class ApaShellInsets {
  static const double kExtraBottomGap = 20;

  /// Matches bottom nav visible height + safe area + breathing room.
  static double contentBottom(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return ApaDimens.navBarBodyHeight +
        bottomInset +
        ApaDimens.navFabOverlap +
        kExtraBottomGap.h;
  }
}
