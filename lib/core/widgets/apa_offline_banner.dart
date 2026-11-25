import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../network/connectivity_controller.dart';
import '../theme/apa_colors.dart';
import '../theme/apa_fonts.dart';

/// Persistent top banner shown while the device has no network.
class ApaOfflineBannerHost extends StatelessWidget {
  const ApaOfflineBannerHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!ConnectivityController.registered) {
      return child;
    }

    return Obx(() {
      final online = ConnectivityController.to.isOnline.value;
      if (online) {
        // Clear any sticky "No Internet Connection" snackbars.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final messenger = ScaffoldMessenger.maybeOf(context);
          messenger?.hideCurrentSnackBar();
          // Also clear GetX snackbars if any.
          if (Get.isSnackbarOpen) {
            Get.closeAllSnackbars();
          }
        });
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!online) const ApaOfflineBanner(),
          Expanded(child: child),
        ],
      );
    });
  }
}

class ApaOfflineBanner extends StatefulWidget {
  const ApaOfflineBanner({super.key});

  @override
  State<ApaOfflineBanner> createState() => _ApaOfflineBannerState();
}

class _ApaOfflineBannerState extends State<ApaOfflineBanner> {
  bool _refreshing = false;

  Future<void> _onRefresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      final online =
          await ConnectivityController.to.refreshAndRestoreIfNeeded();
      if (!mounted) return;
      if (!online) {
        final messenger = ScaffoldMessenger.maybeOf(context);
        messenger?.hideCurrentSnackBar();
        messenger?.showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: ApaColors.black,
            content: Text(
              ConnectivityController.offlineMessage,
              style: ApaFonts.inter(
                color: ApaColors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ApaColors.primaryRed,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: ApaColors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ConnectivityController.offlineMessage,
                  style: ApaFonts.inter(
                    color: ApaColors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),
              TextButton(
                onPressed: _refreshing ? null : _onRefresh,
                style: TextButton.styleFrom(
                  foregroundColor: ApaColors.white,
                  disabledForegroundColor: ApaColors.white60,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: _refreshing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ApaColors.white,
                        ),
                      )
                    : Text(
                        'REFRESH',
                        style: ApaFonts.inter(
                          color: ApaColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
