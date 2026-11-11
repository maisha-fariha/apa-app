import '../../../data/models/post/post_model.dart';

class DonationAllocationItem {
  const DonationAllocationItem({required this.label, required this.value});

  final String label;
  final String value;
}

class DonationSupportItem {
  const DonationSupportItem({required this.highlight, required this.text});

  final String highlight;
  final String text;
}

/// CMS content for Donation (`page-donation.php`), from `get-post-details`.
class DonationPageContent {
  const DonationPageContent({
    required this.topTagLine,
    required this.headingTextOne,
    required this.headingTextTwo,
    required this.lastContent,
    required this.imageUrl,
    required this.onceLabel,
    required this.monthlyLabel,
    required this.customAmountLabel,
    required this.customAmountPlaceholder,
    required this.buttonText,
    required this.paymentNote,
    required this.allocationTitle,
    required this.allocationDescription,
    required this.allocationItems,
    required this.supportTitle,
    required this.supportItems,
    required this.thankYouTitle,
    required this.thankYouMessage,
  });

  final String topTagLine;
  final String headingTextOne;
  final String headingTextTwo;
  final String lastContent;
  final String? imageUrl;
  final String onceLabel;
  final String monthlyLabel;
  final String customAmountLabel;
  final String customAmountPlaceholder;
  final String buttonText;
  final String paymentNote;
  final String allocationTitle;
  final String allocationDescription;
  final List<DonationAllocationItem> allocationItems;
  final String supportTitle;
  final List<DonationSupportItem> supportItems;
  final String thankYouTitle;
  final String thankYouMessage;

  static const fallback = DonationPageContent(
    topTagLine: 'Every gift funds work in Haiti',
    headingTextOne: 'Every dollar,',
    headingTextTwo: 'on the record.',
    lastContent:
        'We publish what came in, what went out, and what it built. If a number here is wrong, tell us and we will correct it in public.',
    imageUrl: null,
    onceLabel: 'One time',
    monthlyLabel: 'Monthly',
    customAmountLabel: 'Other amount',
    customAmountPlaceholder: 'Enter an amount',
    buttonText: 'Continue to payment',
    paymentNote:
        'Payment is handled on our secure processor — this screen never stores card details. Donations are directed to project funds, not overhead.',
    allocationTitle: 'What it pays for',
    allocationDescription: 'Estimated, based on phase-one costing in Haiti.',
    allocationItems: [
      DonationAllocationItem(label: 'Solar street lights installed', value: '1'),
      DonationAllocationItem(label: 'Metres of road resurfaced', value: '14'),
      DonationAllocationItem(label: 'Park benches built and set', value: '2'),
      DonationAllocationItem(label: 'Days of local crew wages', value: '4'),
    ],
    supportTitle: 'Where support comes from',
    supportItems: [
      DonationSupportItem(
        highlight: 'Haitian',
        text: 'diaspora communities worldwide',
      ),
      DonationSupportItem(
        highlight: 'Individual',
        text: 'donors giving once or monthly',
      ),
      DonationSupportItem(
        highlight: 'Businesses',
        text: 'and corporate sponsors',
      ),
      DonationSupportItem(
        highlight: 'Foundations',
        text: 'and philanthropic partners',
      ),
    ],
    thankYouTitle: 'Thank You For Your Donation!',
    thankYouMessage:
        'Your generous support directly funds critical projects and relief in Haiti.',
  );

  factory DonationPageContent.fromPost(PostItem page) {
    final acf = page.acfFields;
    final header = _asMap(acf['common_header']);
    final form = _asMap(acf['donation_form']);
    final allocation = _asMap(acf['allocation']);
    final support = _asMap(acf['support']);
    final thankYou = _asMap(acf['thank_you']);

    final content = DonationPageContent(
      topTagLine: _or(header['top_tag_line'], fallback.topTagLine),
      headingTextOne: _or(header['heading_text_one'], fallback.headingTextOne),
      headingTextTwo: _or(header['heading_text_two'], fallback.headingTextTwo),
      lastContent: _or(header['last_content'], fallback.lastContent),
      imageUrl: page.featuredImageUrl,
      onceLabel: _or(form['once_label'], fallback.onceLabel),
      monthlyLabel: _or(form['monthly_label'], fallback.monthlyLabel),
      customAmountLabel:
          _or(form['custom_amount_label'], fallback.customAmountLabel),
      customAmountPlaceholder: _or(
        form['custom_amount_placeholder'],
        fallback.customAmountPlaceholder,
      ),
      buttonText: _or(form['button_text'], fallback.buttonText),
      paymentNote: _or(form['payment_note'], fallback.paymentNote),
      allocationTitle: _or(allocation['title'], fallback.allocationTitle),
      allocationDescription:
          _or(allocation['description'], fallback.allocationDescription),
      allocationItems: _allocationItems(allocation['items']),
      supportTitle: _or(support['title'], fallback.supportTitle),
      supportItems: _supportItems(support['items']),
      thankYouTitle: _or(thankYou['title'], fallback.thankYouTitle),
      thankYouMessage: _or(thankYou['message'], fallback.thankYouMessage),
    );
    return content;
  }

  static List<DonationAllocationItem> _allocationItems(dynamic raw) {
    if (raw is! List) return fallback.allocationItems;
    final items = <DonationAllocationItem>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      final map = Map<String, dynamic>.from(entry);
      final label = _asString(map['label']);
      final value = _asString(map['value']);
      if (label.isEmpty && value.isEmpty) continue;
      items.add(DonationAllocationItem(label: label, value: value));
    }
    return items.isEmpty ? fallback.allocationItems : items;
  }

  static List<DonationSupportItem> _supportItems(dynamic raw) {
    if (raw is! List) return fallback.supportItems;
    final items = <DonationSupportItem>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      final map = Map<String, dynamic>.from(entry);
      final highlight = _asString(map['highlight']);
      final text = _asString(map['text']);
      if (highlight.isEmpty && text.isEmpty) continue;
      items.add(DonationSupportItem(highlight: highlight, text: text));
    }
    return items.isEmpty ? fallback.supportItems : items;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static String _or(dynamic value, String fallbackValue) {
    final text = _asString(value);
    return text.isNotEmpty ? text : fallbackValue;
  }
}
