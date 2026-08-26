import 'package:apa/data/models/contact/contact_form_model.dart';
import 'package:apa/features/contact/domain/contact_form_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const payload = {
    'success': true,
    'fields': [
      {
        'id': 'name-1',
        'type': 'name',
        'label': 'Name',
        'placeholder': '',
        'required': true,
        'description': '',
        'options': [],
      },
      {
        'id': 'email-1',
        'type': 'email',
        'label': 'Email Address',
        'placeholder': '',
        'required': false,
        'description': '',
        'options': [],
      },
      {
        'id': 'select-1',
        'type': 'select',
        'label': "I'm reaching out about",
        'placeholder': '',
        'required': false,
        'description': '',
        'options': [
          {
            'label': 'Partnering on a project',
            'value': 'Partnering on a project',
            'default': false,
          },
          {
            'label': 'Volunteering',
            'value': 'Volunteering',
            'default': true,
          },
        ],
      },
      {
        'id': 'textarea-1',
        'type': 'textarea',
        'label': 'Message',
        'placeholder': '',
        'required': false,
        'description': '',
        'options': [],
      },
    ],
  };

  test('parses dynamic get-form payload and option defaults', () {
    final response = GetContactFormResponse.fromJson(payload);

    expect(response.success, isTrue);
    expect(response.fields, hasLength(4));
    expect(response.fields.first.kind, ContactFieldKind.text);
    expect(response.fields.first.required, isTrue);
    expect(response.fields[1].kind, ContactFieldKind.email);
    expect(response.fields[2].kind, ContactFieldKind.select);
    expect(response.fields[2].defaultOptionValue, 'Volunteering');
    expect(response.fields[2].options.last.isDefault, isTrue);
    expect(response.fields.last.kind, ContactFieldKind.textarea);
  });

  test('coerces wordpress required flags and string options', () {
    final field = ContactFormField.fromJson({
      'id': 'phone-1',
      'type': 'phone',
      'label': 'Phone',
      'required': '1',
      'options': ['Mobile', {'label': 'Office', 'value': 'office'}],
    });

    expect(field.required, isTrue);
    expect(field.kind, ContactFieldKind.phone);
    expect(field.options, hasLength(2));
    expect(field.options.first.submitValue, 'Mobile');
    expect(field.options.last.submitValue, 'office');
  });

  test('validates required and email fields', () {
    final response = GetContactFormResponse.fromJson(payload);
    final errors = ContactFormValidator.validate(
      fields: response.fields,
      values: const {
        'name-1': '  ',
        'email-1': 'not-an-email',
      },
    );

    expect(errors['name-1'], 'Name is required');
    expect(errors['email-1'], 'Enter a valid email address');
    expect(errors.containsKey('select-1'), isFalse);
  });

  test('rejects numeric-only name values', () {
    final response = GetContactFormResponse.fromJson(payload);
    final errors = ContactFormValidator.validate(
      fields: response.fields,
      values: const {
        'name-1': '12345',
        'email-1': 'valid@example.com',
      },
    );

    expect(errors['name-1'], 'Enter a valid name');
    expect(errors.containsKey('email-1'), isFalse);
  });

  test('builds a dynamic submit body from current form values', () {
    final response = GetContactFormResponse.fromJson(payload);
    final body = ContactFormValidator.submitFields(
      fields: response.fields,
      values: const {
        'name-1': 'Harun',
        'email-1': 'hanrun.khan@example.com',
        'select-1': 'Partnering on a project',
        'textarea-1':
            'Hello, I would like to partner with Ansanm Pou Haiti on a project.',
      },
    );

    expect(body, {
      'name-1': 'Harun',
      'email-1': 'hanrun.khan@example.com',
      'select-1': 'Partnering on a project',
      'textarea-1':
          'Hello, I would like to partner with Ansanm Pou Haiti on a project.',
    });
  });
}
