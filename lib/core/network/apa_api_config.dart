/// Staging WordPress REST configuration from `api_collection`.
abstract final class ApaApiConfig {
  static const String baseUrl =
      'https://encoder-staging.space/ansanm-pou-haiti/wp-json';

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
