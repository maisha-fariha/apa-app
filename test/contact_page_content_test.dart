import 'package:apa/data/models/post/post_model.dart';
import 'package:apa/features/contact/domain/contact_page_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps nested contact_information.items + contact_items', () {
    final page = PostItem.fromJson({
      'success': true,
      'id': 10,
      'title': 'Contact Us',
      'slug': 'contact-us',
      'template': 'page-contact.php',
      'featured_image': {
        'id': 79,
        'url':
            'https://ansanmpouayiti.com/wp-content/uploads/2026/08/contact.webp',
        'alt': '',
      },
      'acf_fields': {
        'contact_information': {
          'top_text_lebel': 'Reach us',
          'items': [
            {
              'label': 'Email',
              'type': 'email',
              'value': 'bonjou@ansanmpouhaiti.org',
            },
            {
              'label': 'Phone',
              'type': 'whatsapp',
              'value': '+509 00 00 0000',
            },
            {
              'label': 'Field office',
              'type': 'text',
              'value': 'Les Cayes, Sud, Haiti',
            },
            {
              'label': 'Diaspora relations',
              'type': 'email',
              'value': 'diaspora@ansanmpouhaiti.org',
            },
          ],
          'final_text_start':
              'Together, we can build safer roads, brighter communities, and better opportunities for',
          'final_text_end': 'future generations.',
        },
        'common_header': {
          'hide_header': false,
          'top_tag_line': 'Join our mission',
          'heading_text_one': 'Partner',
          'heading_text_two': 'with us.',
          'last_content':
              'We invite individuals, organizations, businesses, and members of the Haitian diaspora to build alongside Ansanm Pou Haiti.',
        },
        'contact_items': [
          {
            'label': 'Email',
            'type': 'email',
            'value': 'bonjou@ansanmpouhaiti.org',
            'link': 'mailto:bonjou@ansanmpouhaiti.org',
            'is_link': true,
          },
        ],
      },
    });

    final content = ContactPageContent.fromPost(page);

    expect(content.hideHeader, isFalse);
    expect(content.topTagLine, 'Join our mission');
    expect(content.headingTextOne, 'Partner');
    expect(content.headingTextTwo, 'with us.');
    expect(content.reachTitle, 'Reach us');
    expect(content.reachHeading, 'Reach us');
    expect(content.infoRows, hasLength(1));
    expect(content.infoRows.first.label, 'Email');
    expect(content.infoRows.first.link, 'mailto:bonjou@ansanmpouhaiti.org');
    expect(content.finalTextEnd, 'future generations.');
    expect(content.showHeader, isTrue);
    expect(content.hasReachUs, isTrue);
  });

  test('falls back to nested items when contact_items missing', () {
    final page = PostItem.fromJson({
      'id': 10,
      'template': 'page-contact.php',
      'acf_fields': {
        'common_header': {
          'top_tag_line': 'Join our mission',
          'heading_text_one': 'Partner',
          'heading_text_two': 'with us.',
        },
        'contact_information': {
          'top_text_lebel': 'Reach us',
          'items': [
            {
              'label': 'Field office',
              'type': 'text',
              'value': 'Les Cayes, Sud, Haiti',
            },
          ],
          'final_text_start': 'Together',
          'final_text_end': 'future generations.',
        },
      },
    });

    final content = ContactPageContent.fromPost(page);
    expect(content.infoRows, hasLength(1));
    expect(content.infoRows.single.label, 'Field office');
    expect(content.reachHeading, 'Reach us');
  });

  test('maps legacy flat contact_information keys', () {
    final page = PostItem.fromJson({
      'success': true,
      'id': 10,
      'title': 'Contact Us',
      'slug': 'contact-us',
      'template': 'page-contact.php',
      'featured_image': {
        'id': 79,
        'url':
            'https://encoder-staging.space/ansanm-pou-haiti/wp-content/uploads/2026/08/contact.webp',
        'alt': '',
      },
      'acf_fields': {
        'contact_information': {
          'email': 'bonjou@ansanmpouhaiti.org',
          'phone': '+509 00 00 0000',
          'the_field_office': 'Les Cayes, Sud, Haiti',
          'diaspora_relations': 'diaspora@ansanmpouhaiti.org',
          'final_text_start':
              'Together, we can build safer roads, brighter communities, and better opportunities for',
          'final_text_end': 'future generations.',
        },
        'common_header': {
          'hide_header': false,
          'top_tag_line': 'Join our mission',
          'heading_text_one': 'Partner',
          'heading_text_two': 'with us.',
          'last_content':
              'We invite individuals, organizations, businesses, and members of the Haitian diaspora to build alongside Ansanm Pou Haiti.',
        },
      },
    });

    final content = ContactPageContent.fromPost(page);

    expect(content.infoRows, hasLength(4));
    expect(content.infoRows.first.label, 'Email');
    expect(content.infoRows.first.value, 'bonjou@ansanmpouhaiti.org');
    expect(content.infoRows[2].label, 'Field office');
    expect(content.finalTextEnd, 'future generations.');
  });

  test('omits empty contact rows and honors hide_header', () {
    final page = PostItem.fromJson({
      'id': 10,
      'template': 'page-contact.php',
      'acf_fields': {
        'common_header': {
          'hide_header': '1',
          'top_tag_line': '',
          'heading_text_one': '',
        },
        'contact_information': {
          'email': 'hello@example.com',
          'phone': '',
          'final_text_start': '',
          'final_text_end': '',
        },
      },
    });

    final content = ContactPageContent.fromPost(page);

    expect(content.hideHeader, isTrue);
    expect(content.showHeader, isFalse);
    expect(content.infoRows, hasLength(1));
    expect(content.infoRows.single.value, 'hello@example.com');
    expect(content.hasClosingText, isFalse);
  });
}
