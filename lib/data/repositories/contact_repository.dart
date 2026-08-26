import 'dart:convert';

import 'package:gems_core/gems_core.dart';
import 'package:gems_data_layer/gems_data_layer.dart';

import '../../core/network/api_endpoints.dart';
import '../../core/network/connectivity_controller.dart';
import '../models/contact/contact_form_model.dart';

class ContactRepository {
  ContactRepository({
    required this.apiService,
    required this.databaseService,
  });

  final ApiService apiService;
  final DatabaseService databaseService;

  static const _formCacheKey = 'contact-get-form';

  bool get _isOnline => ConnectivityController.currentlyOnline;

  Future<Result<List<ContactFormField>>> getForm({bool useCache = true}) async {
    try {
      final online = _isOnline;
      final preferCache = useCache || !online;

      if (preferCache) {
        final cached = _readCache();
        if (cached != null && cached.isNotEmpty) {
          if (online && useCache) {
            _refreshInBackground();
          }
          return Result.success(cached);
        }
      }

      if (!online) {
        return Result.failure(
          const NetworkError(message: ConnectivityController.offlineMessage),
        );
      }

      final fetched = await _fetchForm();
      if (fetched.isSuccess) {
        final fields = fetched.value ?? const <ContactFormField>[];
        if (fields.isNotEmpty) {
          await _writeCache(fields);
        }
        return Result.success(fields);
      }

      if (preferCache) {
        final cached = _readCache();
        if (cached != null && cached.isNotEmpty) {
          return Result.success(cached);
        }
      }

      return fetched;
    } catch (e, stackTrace) {
      final cached = _readCache();
      if (cached != null && cached.isNotEmpty) {
        return Result.success(cached);
      }
      return Result.failure(
        NetworkError(
          message: 'Unable to load the contact form. Please try again.',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<Result<List<ContactFormField>>> _fetchForm() async {
    final response = await apiService.get<GetContactFormResponse>(
      ApiEndpoints.getForm,
      queryParameters: {
        '_': DateTime.now().millisecondsSinceEpoch,
      },
      fromJson: (data) {
        if (data is! Map) {
          throw const FormatException('Malformed get-form response');
        }
        return GetContactFormResponse.fromJson(
          Map<String, dynamic>.from(data),
        );
      },
    );

    if (!response.success || response.data == null) {
      return Result.failure(
        ApiError(
          message: _friendly(
            response.message,
            'Unable to load the contact form. Please try again.',
          ),
          statusCode: response.statusCode,
        ),
      );
    }

    final payload = response.data!;
    if (!payload.success) {
      return Result.failure(
        ApiError(
          message: _friendly(
            payload.message,
            'The contact form is currently unavailable.',
          ),
        ),
      );
    }

    final fields =
        payload.fields.where((field) => field.id.isNotEmpty).toList();
    if (fields.isEmpty) {
      return Result.failure(
        const ApiError(message: 'The contact form has no fields yet.'),
      );
    }

    return Result.success(fields);
  }

  Future<void> _refreshInBackground() async {
    if (!_isOnline) return;
    try {
      final fetched = await _fetchForm();
      if (fetched.isSuccess && (fetched.value?.isNotEmpty ?? false)) {
        await _writeCache(fetched.value!);
      }
    } catch (_) {
      // Keep cached schema if a background refresh fails.
    }
  }

  List<ContactFormField>? _readCache() {
    final cachedJson = databaseService.get<String>(_formCacheKey);
    if (cachedJson == null) return null;
    try {
      final decoded = jsonDecode(cachedJson);
      if (decoded is! List) return null;
      final fields = decoded
          .whereType<Map>()
          .map((e) => ContactFormField.fromJson(Map<String, dynamic>.from(e)))
          .where((field) => field.id.isNotEmpty)
          .toList();
      return fields.isEmpty ? null : fields;
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(List<ContactFormField> fields) async {
    await databaseService.save(
      _formCacheKey,
      jsonEncode(fields.map((field) => field.toJson()).toList()),
    );
  }

  Future<Result<String>> submitForm(Map<String, dynamic> fields) async {
    if (!_isOnline) {
      return Result.failure(
        const NetworkError(message: ConnectivityController.offlineMessage),
      );
    }

    try {
      final response = await apiService.post<SubmitContactFormResponse>(
        ApiEndpoints.submitForm,
        data: {'fields': fields},
        fromJson: (data) {
          if (data is! Map) {
            throw const FormatException('Malformed submit-form response');
          }
          return SubmitContactFormResponse.fromJson(
            Map<String, dynamic>.from(data),
          );
        },
      );

      if (!response.success || response.data == null) {
        return Result.failure(
          ApiError(
            message: _friendly(
              response.message,
              'Unable to send your message. Please try again.',
            ),
            statusCode: response.statusCode,
          ),
        );
      }

      final payload = response.data!;
      if (!payload.success) {
        return Result.failure(
          ApiError(
            message: _friendly(
              payload.message,
              'Unable to send your message. Please try again.',
            ),
          ),
        );
      }

      return Result.success(
        _friendly(payload.message, 'Your message has been sent.'),
      );
    } catch (e, stackTrace) {
      return Result.failure(
        NetworkError(
          message: 'Unable to send your message. Please try again.',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  static String _friendly(String? message, String fallback) {
    final value = message?.trim() ?? '';
    if (value.isEmpty) return fallback;
    final lower = value.toLowerCase();
    if (lower.startsWith('dioexception') ||
        lower.startsWith('exception') ||
        lower.startsWith('formatException'.toLowerCase()) ||
        lower.contains('failed to parse')) {
      return fallback;
    }
    return value;
  }
}
