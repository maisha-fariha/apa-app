import '../../../data/models/post/post_model.dart';

/// CMS content for Home (`front-page.php`), from `get-post-details`.
class HomePageContent {
  const HomePageContent({
    required this.heading,
    required this.donateButtonText,
    required this.afterDonateButtonContent,
    required this.minimumDonateAmount,
    required this.imageUrl,
  });

  final String heading;
  final String donateButtonText;
  final String afterDonateButtonContent;
  final int minimumDonateAmount;
  final String? imageUrl;

  static const fallback = HomePageContent(
    heading: 'Sud, Haiti',
    donateButtonText: 'Donate',
    afterDonateButtonContent: 'All donations are 100% for Haiti',
    minimumDonateAmount: 25,
    imageUrl: null,
  );

  factory HomePageContent.fromPost(PostItem page) {
    final acf = page.acfFields;
    final min = _asInt(acf['minimum_donate_amount']) ?? 25;
    return HomePageContent(
      heading: _asString(acf['heading']).isNotEmpty
          ? _asString(acf['heading'])
          : fallback.heading,
      donateButtonText: _asString(acf['donate_button_text']).isNotEmpty
          ? _asString(acf['donate_button_text'])
          : fallback.donateButtonText,
      afterDonateButtonContent:
          _asString(acf['after_donate_button_content']).isNotEmpty
              ? _asString(acf['after_donate_button_content'])
              : fallback.afterDonateButtonContent,
      minimumDonateAmount: min > 0 ? min : fallback.minimumDonateAmount,
      imageUrl: page.featuredImageUrl,
    );
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value.toString().trim());
  }
}
