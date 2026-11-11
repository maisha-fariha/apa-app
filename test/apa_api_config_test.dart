import 'package:apa/core/network/apa_api_config.dart';
import 'package:apa/core/network/api_endpoints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('local baseUrl matches Postman Local environment', () {
    expect(
      ApaApiConfig.localBaseUrl,
      'http://localhost/ansanm-pou-haiti/wp-json',
    );
  });

  test('development baseUrl stays on staging host', () {
    expect(
      ApaApiConfig.developmentBaseUrl,
      contains('encoder-staging.space'),
    );
  });

  test('subscription cancel path matches collection', () {
    expect(
      ApiEndpoints.stripeSubscriptionCancel('sub_ref_123'),
      '/encoderit-stripe/v1/subscriptions/sub_ref_123/cancel',
    );
  });
}
