import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// App-wide connectivity state. Banner + repositories read [isOnline].
class ConnectivityController extends GetxController
    with WidgetsBindingObserver {
  ConnectivityController({required Connectivity connectivity})
      : _connectivity = connectivity;

  static const offlineMessage = 'No Internet Connection';

  final Connectivity _connectivity;
  final RxBool isOnline = true.obs;

  StreamSubscription<ConnectivityResult>? _subscription;

  /// Invoked as soon as the device transitions offline → online.
  VoidCallback? onRestored;

  bool _handlingRestore = false;

  static ConnectivityController get to => Get.find<ConnectivityController>();

  static bool get registered => Get.isRegistered<ConnectivityController>();

  /// Current online flag without requiring Get registration (repos / tests).
  static bool get currentlyOnline {
    if (!registered) return true;
    return to.isOnline.value;
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    unawaited(refreshStatus());
    _subscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(refreshStatus());
    }
  }

  Future<bool> refreshStatus() async {
    final result = await _connectivity.checkConnectivity();
    _apply(result, fromPoll: true);
    return isOnline.value;
  }

  void _onConnectivityChanged(ConnectivityResult result) {
    // Apply stream value immediately so the banner/UI flips right away.
    _apply(result);
    // Confirm with a fresh check — some platforms emit before the
    // interface is fully usable, or miss a quick reconnect edge.
    unawaited(refreshStatus());
  }

  void _apply(ConnectivityResult result, {bool fromPoll = false}) {
    final online = result != ConnectivityResult.none;
    final wasOnline = isOnline.value;
    if (online == wasOnline) {
      // Still force a notify when polling confirms online so Obx rebuilds
      // if a transient offline left UI stuck.
      if (online && fromPoll) {
        isOnline.refresh();
      }
      return;
    }

    isOnline.value = online;

    if (online && !wasOnline) {
      _notifyRestored();
    }
  }

  void _notifyRestored() {
    if (_handlingRestore) return;
    _handlingRestore = true;
    // Let GetX propagate isOnline before controllers start fetching.
    scheduleMicrotask(() {
      try {
        onRestored?.call();
      } finally {
        _handlingRestore = false;
      }
    });
  }

  /// Returns `false` and invokes [onOffline] when there is no network.
  bool ensureOnline({void Function(String message)? onOffline}) {
    if (isOnline.value) return true;
    onOffline?.call(offlineMessage);
    return false;
  }
}
