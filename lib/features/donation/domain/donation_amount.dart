import '../../../data/models/stripe/stripe_models.dart';

class DonationSelection {
  const DonationSelection({
    required this.monthly,
    required this.amountDollars,
    this.price,
    this.custom = false,
  });

  final bool monthly;
  final int amountDollars;
  final StripePriceOption? price;
  final bool custom;

  int get amountCents => amountDollars * 100;
}

String? validateDonationSelection({
  required DonationSelection selection,
  required StripePublicConfig config,
}) {
  if (selection.amountDollars <= 0) {
    return 'Choose an amount to continue.';
  }

  if (selection.monthly) {
    if (selection.price == null || selection.price!.stripePriceId.isEmpty) {
      return 'Choose a monthly amount from the list.';
    }
    return null;
  }

  if (!selection.custom) {
    return null;
  }

  if (!config.customEnabled) {
    return 'Custom amounts are not available. Choose a listed amount.';
  }

  if (selection.amountCents < config.customMinAmountCents) {
    final min = (config.customMinAmountCents / 100).round();
    return 'Minimum donation is \$$min.';
  }

  if (selection.amountCents > config.customMaxAmountCents) {
    final max = (config.customMaxAmountCents / 100).round();
    return 'Maximum donation is \$$max.';
  }

  return null;
}

bool isValidEmail(String value) {
  final email = value.trim();
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
}
