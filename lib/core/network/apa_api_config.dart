/// WordPress REST environments used by this app.
enum AppEnvironment {
  /// Matches Postman "Local" (`http://localhost/.../wp-json`).
  ///
  /// Use on a simulator/desktop that can reach the host WordPress install.
  /// Android emulators usually need `--dart-define=APA_BASE_URL=http://10.0.2.2/...`.
  local,

  /// Remote staging host used for day-to-day app development.
  development,

  /// Live production WordPress.
  production,
}

/// Central WordPress REST configuration from `api_collection`.
///
/// Switch the active API by changing [environment] only. Networking code
/// should read [baseUrl] and must not hardcode host URLs.
abstract final class ApaApiConfig {
  /// Active API environment. Change this value to switch the whole app.
  ///
  /// ```dart
  /// static const environment = AppEnvironment.local;
  /// static const environment = AppEnvironment.development;
  /// static const environment = AppEnvironment.production;
  /// ```
  static const AppEnvironment environment = AppEnvironment.production;

  /// Postman Local environment base URL.
  static const String localBaseUrl =
      'http://localhost/ansanm-pou-haiti/wp-json';

  static const String developmentBaseUrl =
      'https://encoder-staging.space/ansanm-pou-haiti/wp-json';

  static const String productionBaseUrl = 'https://ansanmpouayiti.com/wp-json';

  /// Optional build-time override: `--dart-define=APA_BASE_URL=...`
  static const String baseUrlOverride = String.fromEnvironment('APA_BASE_URL');

  /// Base URL for the selected [environment], or [baseUrlOverride] when set.
  static String get baseUrl {
    final override = baseUrlOverride.trim();
    if (override.isNotEmpty) return override;
    return switch (environment) {
      AppEnvironment.local => localBaseUrl,
      AppEnvironment.development => developmentBaseUrl,
      AppEnvironment.production => productionBaseUrl,
    };
  }

  static bool get isProduction => environment == AppEnvironment.production;

  static bool get enableLogging => !isProduction;

  static const String apiKeyHeader = 'x-api-key';

  /// Header key required by `ANSANM_POU_HAITI_REST_API_KEY`.
  ///
  /// Pass at build time: `--dart-define=APA_API_KEY=...`
  static const String apiKey = String.fromEnvironment(
    'APA_API_KEY',
    defaultValue: 'V9#qL2!xR7@Kp4YZm8&Tw6^Nc1*Hs5%Yj3!Fd0#Aa7',
  );

  static const String postTypePage = 'page';
  static const String postTypePost = 'post';
  static const String postTypeProjects = 'projects';

  /// WordPress Global Settings page id from the API collection.
  static const int globalSettingsId = 5;
}
