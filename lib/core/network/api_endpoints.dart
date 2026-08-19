/// Centralized API paths. Base URL is configured via [ApiConfig].
abstract final class ApiEndpoints {
  static const String getAllPosts = '/ansanm-pou-haiti/v1/get-all-posts';
  static const String getPostDetails = '/ansanm-pou-haiti/v1/get-post-details/';
  static const String getForm = '/ansanm-pou-haiti/v1/get-form/';
  static const String submitForm = '/ansanm-pou-haiti/v1/submit-form/';
  static const String wpMedia = '/wp/v2/media';

  static const String stripeConfig = '/encoderit-stripe/v1/config';
  static const String stripeProducts = '/encoderit-stripe/v1/products';
  static const String stripePayments = '/encoderit-stripe/v1/payments';
  static const String stripeSubscriptions = '/encoderit-stripe/v1/subscriptions';

  static String stripePaymentStatus(String paymentReference) =>
      '$stripePayments/$paymentReference';

  static String stripeSubscriptionStatus(String subscriptionReference) =>
      '$stripeSubscriptions/$subscriptionReference';

  /// Custom scheme used by PaymentSheet redirect methods (Cash App Pay, 3DS).
  static const String stripeReturnUrl = 'apa://safepay';
}
