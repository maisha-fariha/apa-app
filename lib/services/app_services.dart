import 'package:gems_core/gems_core.dart';
import 'package:gems_data_layer/gems_data_layer.dart';
import 'package:get_it/get_it.dart';

import '../core/network/apa_api_config.dart';
import '../data/repositories/posts_repository.dart';
import '../di/pages/pages_di.dart';
import '../features/shell/presentation/controllers/pages_controller.dart';

/// App services using get_it, matching the flutter_gems initialization flow.
class AppServices {
  static final getIt = GetIt.instance;

  Future<void> initialize({
    EnvironmentMode environmentMode = EnvironmentMode.staging,
    AppConfig? appConfig,
  }) async {
    await setupCoreServices(
      environmentMode: environmentMode,
      config: appConfig,
    );

    final env = Environment.instance;
    final apiKey = (appConfig?.additionalConfig[ApaApiConfig.apiKeyHeader]
            as String?) ??
        ApaApiConfig.apiKey;

    final apiConfig = ApiConfig(
      baseUrl: env.apiBaseUrl,
      enableLogging: env.enableLogging,
      timeout: env.apiTimeout,
      defaultHeaders: {
        if (apiKey.isNotEmpty) ApaApiConfig.apiKeyHeader: apiKey,
      },
    );

    await setupDataLayerServices(apiConfig: apiConfig);
    await setupPagesDomainServices();
  }

  ApiService get apiService => getIt<ApiService>();
  PostsRepository get postsRepository => getIt<PostsRepository>();
  PagesController get pagesController => getIt<PagesController>();
}
