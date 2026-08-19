import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../data/models/stripe/stripe_models.dart';
import '../../../../data/repositories/stripe_repository.dart';
import '../../data/stripe_checkout.dart';
import '../../domain/donation_amount.dart';

class DonationCheckoutResult {
  const DonationCheckoutResult._({
    required this.success,
    required this.canceled,
    this.message,
  });

  const DonationCheckoutResult.success()
      : this._(success: true, canceled: false);

  const DonationCheckoutResult.canceled()
      : this._(success: false, canceled: true);

  const DonationCheckoutResult.failure(String message)
      : this._(success: false, canceled: false, message: message);

  final bool success;
  final bool canceled;
  final String? message;
}

class DonationController extends GetxController {
  DonationController({
    required this.repository,
    StripeCheckout? checkout,
  }) : checkout = checkout ?? StripeCheckout();

  final StripeRepository repository;
  final StripeCheckout checkout;

  final RxBool isLoading = false.obs;
  final RxBool isProcessing = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool monthly = false.obs;
  final Rxn<StripePriceOption> selectedPrice = Rxn<StripePriceOption>();
  final RxString customAmountText = ''.obs;
  final Rxn<StripeCatalog> catalog = Rxn<StripeCatalog>();
  final TextEditingController customAmountController = TextEditingController();

  StripePublicConfig? get config => catalog.value?.config;

  List<StripePriceOption> get chips =>
      catalog.value?.chips(monthly: monthly.value) ?? const [];

  bool get customEnabled =>
      !monthly.value && (config?.customEnabled ?? false);

  int get displayAmountDollars {
    final custom = int.tryParse(customAmountText.value.trim());
    if (custom != null && custom > 0) return custom;
    return selectedPrice.value?.amountDollars ?? 0;
  }

  bool get usingCustomAmount {
    final custom = int.tryParse(customAmountText.value.trim());
    return custom != null && custom > 0;
  }

  DonationSelection get selection {
    final dollars = displayAmountDollars;
    if (monthly.value) {
      final price = usingCustomAmount
          ? catalog.value?.priceForDollars(dollars: dollars, monthly: true)
          : selectedPrice.value;
      return DonationSelection(
        monthly: true,
        amountDollars: dollars,
        price: price,
        custom: usingCustomAmount,
      );
    }

    return DonationSelection(
      monthly: false,
      amountDollars: dollars,
      price: selectedPrice.value,
      custom: usingCustomAmount,
    );
  }

  @override
  void onInit() {
    super.onInit();
    customAmountController.addListener(() {
      customAmountText.value = customAmountController.text;
      if (customAmountController.text.trim().isNotEmpty) {
        selectedPrice.value = null;
      }
    });
    loadCatalog();
  }

  @override
  void onClose() {
    customAmountController.dispose();
    super.onClose();
  }

  Future<void> loadCatalog({bool force = false}) async {
    if (isLoading.value) return;
    if (!force && catalog.value != null) return;

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final configResult = await repository.getConfig();
      final pricesResult = await repository.getPrices();

      StripePublicConfig? loadedConfig;
      List<StripePriceOption> loadedPrices = const [];
      String? failure;

      configResult.when(
        success: (value) => loadedConfig = value,
        failure: (error) => failure = error.message,
      );
      pricesResult.when(
        success: (value) => loadedPrices = value,
        failure: (error) => failure ??= error.message,
      );

      final config = loadedConfig;
      if (config == null) {
        catalog.value = null;
        errorMessage.value = failure ?? 'Unable to load payment settings.';
        return;
      }

      await checkout.configure(publishableKey: config.publishableKey);
      catalog.value = StripeCatalog(config: config, prices: loadedPrices);
      _selectDefaultChip();
    } catch (error) {
      catalog.value = null;
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void setMonthly(bool value) {
    if (monthly.value == value) return;
    monthly.value = value;
    customAmountController.clear();
    customAmountText.value = '';
    _selectDefaultChip();
  }

  void selectPrice(StripePriceOption price) {
    selectedPrice.value = price;
    if (customAmountController.text.isNotEmpty) {
      customAmountController.clear();
    }
    customAmountText.value = '';
  }

  void setCustomAmount(String value) {
    if (customAmountController.text != value) {
      customAmountController.text = value;
    }
    customAmountText.value = value;
    if (value.trim().isNotEmpty) {
      selectedPrice.value = null;
    } else {
      _selectDefaultChip();
    }
  }

  String? validateCurrentSelection() {
    final loaded = config;
    if (loaded == null) {
      return 'Payment settings are not loaded yet.';
    }
    return validateDonationSelection(
      selection: selection,
      config: loaded,
    );
  }

  String? validateDonor({required String name, required String email}) {
    if (name.trim().isEmpty) {
      return 'Enter your full name.';
    }
    if (!isValidEmail(email)) {
      return 'Enter a valid email address.';
    }
    return validateCurrentSelection();
  }

  Future<DonationCheckoutResult> completeDonation({
    required String name,
    required String email,
  }) async {
    final created = await createCheckoutSession(name: name, email: email);
    final session = created.session;
    if (session == null) {
      return DonationCheckoutResult.failure(
        created.message ?? 'Unable to start checkout.',
      );
    }
    return presentCheckout(session);
  }

  Future<({StripeCheckoutSession? session, String? message})>
      createCheckoutSession({
    required String name,
    required String email,
  }) async {
    final validation = validateDonor(name: name, email: email);
    if (validation != null) {
      return (session: null, message: validation);
    }
    if (isProcessing.value) {
      return (session: null, message: 'Payment is already in progress.');
    }

    final current = selection;
    final loaded = catalog.value!;
    isProcessing.value = true;
    try {
      final sessionResult = current.monthly
          ? await repository.createSubscription(
              priceId: current.price!.stripePriceId,
              email: email.trim(),
              name: name.trim(),
            )
          : await repository.createOneTimePayment(
              amountDollars: current.amountDollars,
              email: email.trim(),
              name: name.trim(),
              currency: loaded.config.currency,
            );

      StripeCheckoutSession? session;
      String? failure;
      sessionResult.when(
        success: (value) => session = value,
        failure: (error) => failure = error.message,
      );

      final createdSession = session;
      if (createdSession == null) {
        return (
          session: null,
          message: failure ?? 'Unable to start checkout.',
        );
      }

      if (createdSession.publishableKey.isNotEmpty &&
          createdSession.publishableKey != loaded.config.publishableKey) {
        await checkout.configure(publishableKey: createdSession.publishableKey);
      }

      return (session: createdSession, message: null);
    } catch (_) {
      return (
        session: null,
        message: 'Unable to start checkout. Please try again.',
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<DonationCheckoutResult> presentCheckout(
    StripeCheckoutSession session, {
    String? name,
    String? email,
  }) async {
    final loaded = catalog.value;
    if (loaded == null) {
      return const DonationCheckoutResult.failure(
        'Payment settings are not loaded yet.',
      );
    }

    isProcessing.value = true;
    try {
      final outcome = await checkout.presentPaymentSheet(
        clientSecret: session.clientSecret,
        testMode: loaded.config.isTestMode,
        email: email?.trim(),
        name: name?.trim(),
      );

      if (outcome == StripeCheckoutOutcome.canceled) {
        return const DonationCheckoutResult.canceled();
      }

      final token = session.statusAccessToken;
      if (token != null && token.isNotEmpty) {
        if (session.paymentReference != null) {
          await repository.getPaymentStatus(
            paymentReference: session.paymentReference!,
            accessToken: token,
          );
        } else if (session.subscriptionReference != null) {
          await repository.getSubscriptionStatus(
            subscriptionReference: session.subscriptionReference!,
            accessToken: token,
          );
        }
      }

      return const DonationCheckoutResult.success();
    } on StripeCheckoutException catch (error) {
      return DonationCheckoutResult.failure(error.message);
    } catch (_) {
      return const DonationCheckoutResult.failure(
        'Payment could not be completed. Please try again.',
      );
    } finally {
      isProcessing.value = false;
    }
  }

  void _selectDefaultChip() {
    final options = chips;
    if (options.isEmpty) {
      selectedPrice.value = null;
      return;
    }
    final preferred = options.where((price) => price.amountDollars == 100);
    selectedPrice.value =
        preferred.isNotEmpty ? preferred.first : options.first;
  }
}
