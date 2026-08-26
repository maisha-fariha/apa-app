import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

/// App-wide connectivity state. Banner + repositories read [isOnline].
class ConnectivityController extends GetxController {
  ConnectivityController({required Connectivity connectivity})
      : _connectivity = connectivity;

  static const offlineMessage = 'No Internet Connection';

  final Connectivity _connectivity;
  final RxBool isOnline = true.obs;

  StreamSubscription<ConnectivityResult>? _subscription;

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
    unawaited(refreshStatus());
    _subscription = _connectivity.onConnectivityChanged.listen(_apply);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  Future<bool> refreshStatus() async {
    final result = await _connectivity.checkConnectivity();
    _apply(result);
    return isOnline.value;
  }

  void _apply(ConnectivityResult result) {
    isOnline.value = result != ConnectivityResult.none;
  }

  /// Returns `false` and invokes [onOffline] when there is no network.
  bool ensureOnline({void Function(String message)? onOffline}) {
    if (isOnline.value) return true;
    onOffline?.call(offlineMessage);
    return false;
  }
}
