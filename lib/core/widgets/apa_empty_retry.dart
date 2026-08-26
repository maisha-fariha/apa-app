import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../network/connectivity_controller.dart';
import '../theme/apa_colors.dart';
import '../theme/apa_fonts.dart';
import 'apa_shared_widgets.dart';

/// Empty-state with a message and retry action (used when a screen has no
/// cached content to show, especially while offline).
class ApaEmptyRetry extends StatelessWidget {
  const ApaEmptyRetry({
    super.key,
    required this.message,
    required this.onRetry,
    this.buttonLabel = 'TRY AGAIN',
  });

  /// Offline blank-screen copy.
  static const offlineMessage =
      'This content isn\'t available offline. Connect to the internet and try again.';

  /// Generic blank-screen copy when online fetch failed / nothing loaded.
  static const unavailableMessage =
      'Unable to load this content. Please try again.';

  final String message;
  final VoidCallback onRetry;
  final String buttonLabel;

  /// Picks offline vs generic copy from current connectivity.
  factory ApaEmptyRetry.forConnectivity({
    Key? key,
    required VoidCallback onRetry,
    String buttonLabel = 'TRY AGAIN',
  }) {
    final offline = !ConnectivityController.currentlyOnline;
    return ApaEmptyRetry(
      key: key,
      message: offline ? offlineMessage : unavailableMessage,
      onRetry: onRetry,
      buttonLabel: buttonLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message,
            style: ApaFonts.inter(
              color: ApaColors.gray700,
              fontSize: 15.sp,
              height: 22 / 15,
            ),
          ),
          SizedBox(height: 16.h),
          ApaBlackPillButton(
            label: buttonLabel,
            expanded: true,
            fontSize: 16,
            verticalPadding: 16,
            horizontalPadding: 24,
            onPressed: () => _handleRetry(context),
          ),
        ],
      ),
    );
  }

  void _handleRetry(BuildContext context) {
    if (!ConnectivityController.currentlyOnline) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text(ConnectivityController.offlineMessage, style: TextStyle(color: ApaColors.white),),
          backgroundColor: ApaColors.primaryRed,
        ),
      );
      return;
    }
    onRetry();
  }
}
