import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../theme/apa_colors.dart';
import '../theme/apa_fonts.dart';

/// App snackbars via [ScaffoldMessenger] — never [Get.snackbar].
///
/// GetX 4.6.6 resolves overlays with `Overlay.of(Get.overlayContext!)`, which
/// throws `No Overlay widget found` when controllers fetch before / outside a
/// ready navigator Overlay (common because controllers are `Get.put` before
/// `runApp`).
abstract final class ApaSnackbar {
  static void error(String message, {String title = 'Error'}) {
    _show(title: title, message: message, isError: true);
  }

  static void info(String message, {String title = 'Info'}) {
    _show(title: title, message: message, isError: false);
  }

  static void _show({
    required String title,
    required String message,
    required bool isError,
  }) {
    final text = message.trim();
    if (text.isEmpty) return;

    void present() {
      final context = Get.context ?? Get.key.currentContext;
      if (context == null) return;

      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;

      final body = title.trim().isEmpty ? text : '$title: $text';
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: isError ? ApaColors.webRed : ApaColors.webInk,
            content: Text(
              body,
              style: ApaFonts.inter(
                color: ApaColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
    }

    if (Get.context != null || Get.key.currentContext != null) {
      present();
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null || Get.key.currentContext != null) {
        present();
        return;
      }
      SchedulerBinding.instance.addPostFrameCallback((_) => present());
    });
  }
}
