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

class ApaOfflineBanner extends StatelessWidget {
  const ApaOfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ApaColors.primaryRed,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            ],
          ),
        ),
      ),
    );
  }
}
