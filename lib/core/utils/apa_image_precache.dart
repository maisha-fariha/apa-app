import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/apa_assets.dart';

/// Decode first-screen assets into the image cache before [runApp].
///
/// Uses the platform view's device pixel ratio so the correct asset variant
/// is ready for the first home paint (no blank/decode hitch).
Future<void> warmApaStartupImages() async {
  final views = WidgetsBinding.instance.platformDispatcher.views;
  final dpr = views.isEmpty ? 1.0 : views.first.devicePixelRatio;
  final config = ImageConfiguration(devicePixelRatio: dpr);

  await Future.wait([
    _resolveIntoCache(const AssetImage(ApaAssets.homeBackground), config),
    _resolveIntoCache(const AssetImage(ApaAssets.apaLogo), config),
    _resolveIntoCache(const AssetImage(ApaAssets.projectsHero), config),
    _resolveIntoCache(const AssetImage(ApaAssets.newsHero), config),
    _resolveIntoCache(const AssetImage(ApaAssets.donationHero), config),
  ]);
}

/// Warm the decode cache for images needed on the first screen (with context).
Future<void> precacheApaStartupImages(BuildContext context) async {
  await Future.wait([
    precacheImage(const AssetImage(ApaAssets.homeBackground), context),
    precacheImage(const AssetImage(ApaAssets.apaLogo), context),
    precacheImage(const AssetImage(ApaAssets.projectsHero), context),
    precacheImage(const AssetImage(ApaAssets.newsHero), context),
    precacheImage(const AssetImage(ApaAssets.donationHero), context),
  ]);
}

Future<void> precacheApaNetworkImage(
  BuildContext context,
  String? url,
) async {
  final trimmed = url?.trim() ?? '';
  if (trimmed.isEmpty) return;
  try {
    await precacheImage(NetworkImage(trimmed), context);
  } catch (_) {
    // Ignore network/decode failures — UI falls back to assets.
  }
}

Future<void> _resolveIntoCache(
  ImageProvider provider,
  ImageConfiguration config,
) {
  final stream = provider.resolve(config);
  final completer = Completer<void>();
  late final ImageStreamListener listener;
  listener = ImageStreamListener(
    (ImageInfo image, bool synchronousCall) {
      stream.removeListener(listener);
      if (!completer.isCompleted) completer.complete();
    },
    onError: (Object exception, StackTrace? stackTrace) {
      stream.removeListener(listener);
      if (!completer.isCompleted) completer.complete();
    },
  );
  stream.addListener(listener);
  return completer.future;
}
