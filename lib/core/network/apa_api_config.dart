/// WordPress REST environments used by this app.
enum AppEnvironment {
  development,
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
  /// static const environment = AppEnvironment.development;
  /// static const environment = AppEnvironment.production;
  /// ```
  static const AppEnvironment environment = AppEnvironment.production;

  static const String developmentBaseUrl =
      'https://encoder-staging.space/ansanm-pou-haiti/wp-json';

  static const String productionBaseUrl = 'https://ansanmpouhaiti.com/wp-json';

  /// Base URL for the selected [environment].
  static String get baseUrl => switch (environment) {
        AppEnvironment.development => developmentBaseUrl,
        AppEnvironment.production => productionBaseUrl,
      };

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
}
