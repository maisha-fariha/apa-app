import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'apa_api_config.dart';

/// App-wide connectivity state. Banner + repositories read [isOnline].
///
/// Uses `connectivity_plus` for fast interface hints, then confirms with an
/// HTTP probe to the API host. Interface-only checks are unreliable on iOS
/// Simulator / airplane-mode toggles and left the offline banner stuck.
class ConnectivityController extends GetxController
    with WidgetsBindingObserver {
  ConnectivityController({required Connectivity connectivity})
      : _connectivity = connectivity;

  static const offlineMessage = 'No Internet Connection';

  final Connectivity _connectivity;
  final RxBool isOnline = true.obs;

  /// Bumped after a confirmed offline → online transition so network images
  /// remount and retry (Flutter will not re-resolve a failed ImageProvider).
  final RxInt imageReloadEpoch = 0.obs;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _offlinePollTimer;
  int _probeGeneration = 0;

  /// Invoked when the device is confirmed online after being offline (or
  /// after a manual REFRESH that finds the network).
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
    _offlinePollTimer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(refreshAndRestoreIfNeeded());
    }
  }

  /// Re-check HTTP reachability and update [isOnline].
  Future<bool> refreshStatus() async {
    // Probe is the source of truth — interface-only checks leave the banner
    // stuck on iOS Simulator after offline → online.
    final reachable = await _probeInternet();
    _setOnline(reachable);
    return isOnline.value;
  }

  /// Manual REFRESH / app-resume: probe the network and reload CMS if online.
  Future<bool> refreshAndRestoreIfNeeded() async {
    final reachable = await _probeInternet();
    final wasOnline = isOnline.value;
    _setOnline(reachable, notifyRestore: false);
    if (reachable) {
      bumpImageReload();
      // Always reload data on manual refresh, even if we were already "online".
      _invokeRestored(force: true);
      if (!wasOnline) {
        // Extra bump after restore work starts.
        scheduleMicrotask(bumpImageReload);
      }
    }
    return reachable;
  }

  /// Force network images to remount / retry (e.g. after CMS URLs refresh).
  void bumpImageReload() {
    imageReloadEpoch.value++;
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final interfaceUp = results.any((r) => r != ConnectivityResult.none);
    if (!interfaceUp) {
      // Show offline immediately; confirm with probe (may still be online).
      _setOnline(false, notifyRestore: false);
    }
    unawaited(_confirmWithProbe());
  }

  Future<void> _confirmWithProbe() async {
    final generation = ++_probeGeneration;
    final reachable = await _probeInternet();
    if (generation != _probeGeneration) return;
    _setOnline(reachable);
  }

  void _setOnline(bool online, {bool notifyRestore = true}) {
    final wasOnline = isOnline.value;
    if (online == wasOnline) {
      if (online) isOnline.refresh();
      _syncOfflinePoll(online);
      return;
    }

    isOnline.value = online;
    _syncOfflinePoll(online);

    if (notifyRestore && online && !wasOnline) {
      _notifyRestored();
    }
  }

  /// While offline, keep probing — stream events are often missed on iOS.
  void _syncOfflinePoll(bool online) {
    if (online) {
      _offlinePollTimer?.cancel();
      _offlinePollTimer = null;
      return;
    }
    _offlinePollTimer ??= Timer.periodic(
      const Duration(seconds: 2),
      (_) => unawaited(_confirmWithProbe()),
    );
  }

  void _notifyRestored() {
    bumpImageReload();
    _invokeRestored();

    unawaited(() async {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (!isOnline.value) return;
      final ok = await _probeInternet();
      if (!ok) {
        _setOnline(false, notifyRestore: false);
        return;
      }
      bumpImageReload();
      _invokeRestored(force: true);
    }());
  }

  void _invokeRestored({bool force = false}) {
    if (!force && _handlingRestore) return;
    _handlingRestore = true;
    scheduleMicrotask(() {
      try {
        onRestored?.call();
      } finally {
        _handlingRestore = false;
      }
    });
  }

  /// True when the API host answers over the network.
  Future<bool> _probeInternet() async {
    HttpClient? client;
    try {
      final base = Uri.parse(ApaApiConfig.baseUrl);
      if (base.host.isEmpty) return false;
      final probeUri = Uri(
        scheme: base.scheme.isEmpty ? 'https' : base.scheme,
        host: base.host,
        port: base.hasPort ? base.port : null,
        path: '/',
      );

      client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 4)
        ..idleTimeout = const Duration(seconds: 4);
      final request = await client
          .getUrl(probeUri)
          .timeout(const Duration(seconds: 4));
      request.followRedirects = true;
      final response =
          await request.close().timeout(const Duration(seconds: 4));
      await response.drain<void>();
      return true;
    } catch (_) {
      return false;
    } finally {
      client?.close(force: true);
    }
  }

  /// Returns `false` and invokes [onOffline] when there is no network.
  bool ensureOnline({void Function(String message)? onOffline}) {
    if (isOnline.value) return true;
    onOffline?.call(offlineMessage);
    return false;
  }
}
