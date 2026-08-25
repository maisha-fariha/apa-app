import 'package:apa/data/models/stripe/stripe_models.dart';
import 'package:apa/features/donation/domain/donation_amount.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const configJson = {
    'mode': 'test',
    'publishable_key': 'pk_test_example',
    'currency': 'usd',
    'one_time': {
      'predefined_enabled': true,
      'custom_enabled': true,
      'custom_currency': 'usd',
      'custom_min_amount': 100,
      'custom_max_amount': 500000,
    },
  };

  const pricesJson = [
    {
      'id': '2',
      'product_id': '3',
      'stripe_price_id': 'price_one_time_20',
      'price_type': 'one_time',
      'unit_amount': '2000',
      'currency': 'usd',
    },
    {
      'id': '3',
      'product_id': '3',
      'stripe_price_id': 'price_month_20',
      'price_type': 'recurring',
      'unit_amount': '2000',
      'currency': 'usd',
      'recurring_interval': 'month',
    },
    {
      'id': '4',
      'product_id': '4',
      'stripe_price_id': 'price_one_time_50',
      'price_type': 'one_time',
      'unit_amount': '5000',
      'currency': 'usd',
    },
    {
      'id': '5',
      'product_id': '6',
      'stripe_price_id': 'price_month_50',
      'price_type': 'recurring',
      'unit_amount': '5000',
      'currency': 'usd',
      'recurring_interval': 'month',
    },
    {
      'id': '6',
      'product_id': '5',
      'stripe_price_id': 'price_one_time_100',
      'price_type': 'one_time',
      'unit_amount': '10000',
      'currency': 'usd',
    },
    {
      'id': '7',
      'product_id': '5',
      'stripe_price_id': 'price_month_100',
      'price_type': 'recurring',
      'unit_amount': '10000',
      'currency': 'usd',
      'recurring_interval': 'month',
    },
    {
      'id': '8',
      'product_id': '6',
      'stripe_price_id': 'price_one_time_500',
      'price_type': 'one_time',
      'unit_amount': '50000',
      'currency': 'usd',
    },
  ];

  test('parses Stripe config amounts in cents', () {
    final config = StripePublicConfig.fromJson(configJson);
    expect(config.publishableKey, 'pk_test_example');
    expect(config.customEnabled, isTrue);
    expect(config.customMinAmountCents, 100);
    expect(config.customMaxAmountCents, 500000);
    expect(config.isTestMode, isTrue);
  });

  test('builds unique chips for one-time and monthly prices', () {
    final catalog = StripeCatalog(
      config: StripePublicConfig.fromJson(configJson),
      prices: pricesJson.map(StripePriceOption.fromJson).toList(),
    );

    expect(
      catalog.chips(monthly: false).map((price) => price.amountDollars),
      [20, 50, 100],
    );
    expect(
      catalog.chips(monthly: true).map((price) => price.stripePriceId),
      ['price_month_20', 'price_month_50', 'price_month_100'],
    );
  });

  test('validates custom one-time amounts against min and max', () {
    final config = StripePublicConfig.fromJson(configJson);

    expect(
      validateDonationSelection(
        selection: const DonationSelection(
          monthly: false,
          amountDollars: 20,
          custom: true,
        ),
        config: config,
      ),
      isNull,
    );
    expect(
      validateDonationSelection(
        selection: const DonationSelection(
          monthly: false,
          amountDollars: 0,
          custom: true,
        ),
        config: config,
      ),
      'Choose an amount to continue.',
    );
    expect(
      validateDonationSelection(
        selection: const DonationSelection(
          monthly: true,
          amountDollars: 20,
        ),
        config: config,
      ),
      'Choose a monthly amount from the list.',
    );
  });

  test('parses checkout session client secret', () {
    final session = StripeCheckoutSession.fromJson({
      'payment_reference': 'pay_1',
      'client_secret': 'pi_secret',
      'publishable_key': 'pk_test_example',
      'status_access_token': 'token',
      'amount': 2000,
      'currency': 'usd',
    });

    expect(session.clientSecret, 'pi_secret');
    expect(session.amountCents, 2000);
  });

  test('treats succeeded payment status as paid', () {
    final status = StripePaymentStatus.fromJson({
      'payment_reference': 'pay_1',
      'status': 'succeeded',
      'amount': 2000,
      'currency': 'usd',
      'paid_at': '2026-08-19T00:00:00Z',
      'receipt_url': 'https://example.com/receipt',
    });
    expect(status.isPaid, isTrue);
    expect(status.receiptUrl, 'https://example.com/receipt');
  });
}
