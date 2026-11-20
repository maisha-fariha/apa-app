import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../network/connectivity_controller.dart';
import '../theme/apa_colors.dart';

/// Network image that keeps a local [asset] (or solid fill) visible until the
/// remote frame is ready — avoids the blank flash on cold start / CMS load.
class ApaRemoteImage extends StatelessWidget {
  const ApaRemoteImage({
    super.key,
    required this.asset,
    this.url,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.useAssetFallback = true,
    this.width,
    this.height,
    this.fadeInDuration = Duration.zero,
  });

  final String asset;
  final String? url;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final bool useAssetFallback;
  final double? width;
  final double? height;
  final Duration fadeInDuration;

  @override
  Widget build(BuildContext context) {
    if (ConnectivityController.registered) {
      return Obx(() {
        final online = ConnectivityController.to.isOnline.value;
        final epoch = ConnectivityController.to.imageReloadEpoch.value;
        return _ApaRemoteImageBody(
          key: ValueKey<String>('apa-remote-${url ?? ''}-$online-$epoch'),
          asset: asset,
          url: url,
          fit: fit,
          alignment: alignment,
          useAssetFallback: useAssetFallback,
          width: width,
          height: height,
          fadeInDuration: fadeInDuration,
          online: online,
        );
      });
    }
    return _ApaRemoteImageBody(
      asset: asset,
      url: url,
      fit: fit,
      alignment: alignment,
      useAssetFallback: useAssetFallback,
      width: width,
      height: height,
      fadeInDuration: fadeInDuration,
      online: true,
    );
  }
}

class _ApaRemoteImageBody extends StatefulWidget {
  const _ApaRemoteImageBody({
    super.key,
    required this.asset,
    required this.online,
    this.url,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.useAssetFallback = true,
    this.width,
    this.height,
    this.fadeInDuration = Duration.zero,
  });

  final String asset;
  final String? url;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final bool useAssetFallback;
  final double? width;
  final double? height;
  final Duration fadeInDuration;
  final bool online;

  @override
  State<_ApaRemoteImageBody> createState() => _ApaRemoteImageBodyState();
}

class _ApaRemoteImageBodyState extends State<_ApaRemoteImageBody> {
  @override
  void initState() {
    super.initState();
    _evictNetworkIfNeeded();
  }

  void _evictNetworkIfNeeded() {
    final networkUrl = widget.url?.trim() ?? '';
    if (networkUrl.isEmpty || !widget.online) return;
    imageCache.evict(NetworkImage(networkUrl));
  }

  @override
  Widget build(BuildContext context) {
    final networkUrl = widget.url?.trim() ?? '';
    if (networkUrl.isEmpty || !widget.online) {
      // Offline: never mount Image.network (avoids a sticky failed provider).
      return _sized(_asset());
    }

    final provider = NetworkImage(networkUrl);

    if (!widget.useAssetFallback) {
      return _sized(
        Image(
          image: provider,
          fit: widget.fit,
          alignment: widget.alignment,
          gaplessPlayback: true,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) return child;
            return const ColoredBox(color: ApaColors.black);
          },
          errorBuilder: (context, error, stackTrace) =>
              const ColoredBox(color: ApaColors.black),
        ),
      );
    }

    return _sized(
      Image(
        image: provider,
        fit: widget.fit,
        alignment: widget.alignment,
        gaplessPlayback: true,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          if (frame == null) return _asset();
          if (widget.fadeInDuration == Duration.zero) return child;
          return AnimatedOpacity(
            opacity: 1,
            duration: widget.fadeInDuration,
            curve: Curves.easeOut,
            child: child,
          );
        },
        errorBuilder: (context, error, stackTrace) => _asset(),
      ),
    );
  }

  Widget _sized(Widget child) {
    if (widget.width == null && widget.height == null) return child;
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: child,
    );
  }

  Widget _asset() {
    return Image.asset(
      widget.asset,
      fit: widget.fit,
      alignment: widget.alignment,
      gaplessPlayback: true,
    );
  }
}
