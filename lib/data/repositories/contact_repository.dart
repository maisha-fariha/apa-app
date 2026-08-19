import 'package:gems_core/gems_core.dart';
import 'package:gems_data_layer/gems_data_layer.dart';

import '../../core/network/api_endpoints.dart';
import '../models/contact/contact_form_model.dart';

class ContactRepository {
  ContactRepository({required this.apiService});

  final ApiService apiService;

  Future<Result<List<ContactFormField>>> getForm() async {
    try {
      final response = await apiService.get<GetContactFormResponse>(
        ApiEndpoints.getForm,
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

      final fields = payload.fields.where((field) => field.id.isNotEmpty).toList();
      if (fields.isEmpty) {
        return Result.failure(
          const ApiError(message: 'The contact form has no fields yet.'),
        );
      }

      return Result.success(fields);
    } catch (e, stackTrace) {
      return Result.failure(
        NetworkError(
          message: 'Unable to load the contact form. Please try again.',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<Result<String>> submitForm(Map<String, dynamic> fields) async {
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
