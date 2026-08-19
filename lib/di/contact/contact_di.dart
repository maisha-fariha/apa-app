import 'package:gems_core/gems_core.dart';
import 'package:gems_data_layer/gems_data_layer.dart';
import 'package:get_it/get_it.dart';

import '../../data/repositories/contact_repository.dart';
import '../../features/contact/presentation/controllers/contact_controller.dart';

Future<void> setupContactDomainServices() async {
  final getIt = GetIt.instance;

  DIHelper.registerRepository<ContactRepository>(
    factory: () => ContactRepository(apiService: getIt<ApiService>()),
  );

  DIHelper.registerController<ContactController>(
    factory: () => ContactController(
      repository: getIt<ContactRepository>(),
    ),
  );
}
