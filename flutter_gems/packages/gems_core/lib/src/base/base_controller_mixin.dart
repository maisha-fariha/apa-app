import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:gems_data_layer/gems_data_layer.dart';
import '../result/result.dart';
import '../result/app_error.dart';

/// Mixin for common controller patterns
/// Provides helper methods for handling Result types with loading states
mixin BaseControllerMixin<T> on BaseListController<T> {
  /// Handle result with loading state
  Future<void> handleResult<R>(
    Future<Result<R>> Function() action, {
    required void Function(R) onSuccess,
    void Function(AppError)? onError,
    bool showSuccessMessage = false,
    String? successMessage,
  }) async {
    setLoading(true);
    try {
      final result = await action();
      result.when(
        success: (data) {
          onSuccess(data);
          if (showSuccessMessage) {
            _safeSnack(
              'Success',
              successMessage ?? 'Operation successful',
            );
          }
        },
        failure: (error) {
          setError(error.message);
          onError?.call(error);
          _safeSnack('Error', error.message);
        },
      );
    } finally {
      setLoading(false);
    }
  }

  /// Avoid GetX `Get.snackbar` — Get 4.6.6 uses `Overlay.of(overlayContext)`
  /// and crashes when the navigator Overlay is not ready.
  void _safeSnack(String title, String message) {
    final text = message.trim();
    if (text.isEmpty) return;

    void present() {
      final context = Get.context ?? Get.key.currentContext;
      if (context == null) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('$title: $text'),
          ),
        );
    }

    if (Get.context != null || Get.key.currentContext != null) {
      present();
      return;
    }
    SchedulerBinding.instance.addPostFrameCallback((_) => present());
  }

  /// Handle list result
  Future<void> handleListResult(
    Future<Result<List<T>>> Function() action,
  ) async {
    await handleResult(
      action,
      onSuccess: (items) => addItems(items),
    );
  }
}

