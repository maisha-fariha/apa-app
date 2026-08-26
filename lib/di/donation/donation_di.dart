import 'package:gems_core/gems_core.dart';
import 'package:gems_data_layer/gems_data_layer.dart';
import 'package:get_it/get_it.dart';

import '../../data/repositories/stripe_repository.dart';
import '../../features/donation/presentation/controllers/donation_controller.dart';

Future<void> setupDonationDomainServices() async {
  final getIt = GetIt.instance;

  DIHelper.registerRepository<StripeRepository>(
    factory: () => StripeRepository(
      apiService: getIt<ApiService>(),
      databaseService: getIt<DatabaseService>(),
    ),
  );

  DIHelper.registerController<DonationController>(
    factory: () => DonationController(
      repository: getIt<StripeRepository>(),
    ),
  );
}
