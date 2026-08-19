import 'package:gems_core/gems_core.dart';
import 'package:gems_data_layer/gems_data_layer.dart';
import 'package:get_it/get_it.dart';

import '../../data/repositories/posts_repository.dart';
import '../../features/shell/presentation/controllers/pages_controller.dart';

Future<void> setupPagesDomainServices() async {
  final getIt = GetIt.instance;

  DIHelper.registerRepository<PostsRepository>(
    factory: () => PostsRepository(
      apiService: getIt<ApiService>(),
      databaseService: getIt<DatabaseService>(),
      syncService: getIt<SyncService>(),
    ),
  );

  DIHelper.registerController<PagesController>(
    factory: () => PagesController(
      repository: getIt<PostsRepository>(),
    ),
  );
}
