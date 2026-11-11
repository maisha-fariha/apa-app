import 'package:apa/data/models/post/post_model.dart';
import 'package:apa/features/donation/domain/donation_page_content.dart';
import 'package:apa/features/home/domain/home_page_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Home CMS', () {
    test('maps live Home ACF fields', () {
      final page = PostItem(
        id: 7,
        title: 'Home',
        template: 'front-page.php',
        featuredImage: const FeaturedImage(
          url: 'https://ansanmpouayiti.com/wp-content/uploads/home.webp',
        ),
        acfFields: {
          'heading': 'Sud, Haiti',
          'donate_button_text': 'Donate',
          'after_donate_button_content': 'All donations are 100% for Haiti',
          'minimum_donate_amount': '25',
        },
      );

      final content = HomePageContent.fromPost(page);
      expect(content.heading, 'Sud, Haiti');
      expect(content.donateButtonText, 'Donate');
      expect(content.afterDonateButtonContent, 'All donations are 100% for Haiti');
      expect(content.minimumDonateAmount, 25);
      expect(content.imageUrl, contains('home.webp'));
    });
  });

  group('Donation CMS', () {
    test('maps live Donation ACF groups used by the website', () {
      final page = PostItem(
        id: 17,
        title: 'Donation',
        template: 'page-donation.php',
        acfFields: {
          'common_header': {
            'top_tag_line': 'Every gift funds work in Haiti',
            'heading_text_one': 'Every dollar,',
            'heading_text_two': 'on the record.',
            'last_content': 'We publish what came in.',
          },
          'donation_form': {
            'once_label': 'One time',
            'monthly_label': 'Monthly',
            'custom_amount_label': 'Other amount',
            'custom_amount_placeholder': 'Enter an amount',
            'button_text': 'Continue to payment',
            'payment_note': 'Secure processor note',
          },
          'allocation': {
            'title': 'What it pays for',
            'description': 'Estimated, based on phase-one costing in Haiti Part.',
            'items': [
              {'label': 'Solar street lights installed', 'value': '1'},
              {'label': 'Metres of road resurfaced', 'value': '14'},
              {'label': 'Park benches built and set', 'value': '2'},
              {'label': 'Days of local crew wages', 'value': '4'},
            ],
          },
          'support': {
            'title': 'Where support comes from',
            'items': [
              {
                'highlight': 'Haitian',
                'text': 'diaspora communities worldwide',
              },
            ],
          },
          'thank_you': {
            'title': 'Thank You For Your Donation!',
            'message': 'Your generous support directly funds critical projects.',
          },
        },
      );

      final content = DonationPageContent.fromPost(page);
      expect(content.topTagLine, 'Every gift funds work in Haiti');
      expect(content.headingTextOne, 'Every dollar,');
      expect(content.headingTextTwo, 'on the record.');
      expect(content.onceLabel, 'One time');
      expect(content.buttonText, 'Continue to payment');
      expect(content.allocationItems, hasLength(4));
      expect(content.allocationItems[1].label, 'Metres of road resurfaced');
      expect(content.allocationItems[1].value, '14');
      expect(content.supportItems.first.highlight, 'Haitian');
      expect(content.thankYouMessage, contains('generous support'));
    });
  });
}
