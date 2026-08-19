import 'package:apa/data/models/post/post_model.dart';
import 'package:apa/features/transparency/domain/transparency_page_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps transparency get-post-details without dummy fallbacks', () {
    final page = PostItem.fromJson({
      'success': true,
      'id': 14,
      'title': 'Transparency',
      'template': 'page-transparency.php',
      'featured_image': {
        'id': 80,
        'url':
            'https://encoder-staging.space/ansanm-pou-haiti/wp-content/uploads/2026/08/home-bg-1.webp',
        'alt': '',
      },
      'acf_fields': {
        'footer':
            '<h2>Our commitment</h2><article><h3>Accountability</h3><p>Financial transparency and independent review of the books.</p></article><article><h3>Community first</h3><p>Neighbors involved at every stage.</p></article>',
        'related_project': [
          {
            'title': 'Community park &amp; playground',
            'acf_fields': {
              'community': 'Haiti',
              'status': 'Design',
              'committed': '1500',
            },
          },
          {
            'title': 'Solar street lighting, phase 1',
            'acf_fields': {
              'community': 'Haiti',
              'status': 'In progress',
              'committed': '9400',
            },
          },
        ],
        'common_header': {
          'hide_header': false,
          'top_tag_line': 'Open books',
          'heading_text_one': 'Every dollar,',
          'heading_text_two': 'on the record.',
          'last_content': 'We publish what came in, what went out, and what it built.',
        },
      },
      'funding_progress': {
        'raised_amount': 20825,
        'raised_formatted': '20,825',
        'target_amount': 120000,
        'target_formatted': '120,000',
        'percent_funded': 17,
      },
    });

    final content = TransparencyPageContent.fromPost(page);

    expect(content.topTagLine, 'Open books');
    expect(content.headingTextOne, 'Every dollar,');
    expect(content.headingTextTwo, 'on the record.');
    expect(content.funding.raisedLabel, r'$20,825');
    expect(content.funding.progressValue, closeTo(0.17, 0.001));
    expect(content.funding.progressCaption, r'17% of goal — $120,000');
    expect(content.ledgerItems, hasLength(2));
    expect(content.ledgerItems.first.project, 'Community park & playground');
    expect(content.ledgerItems.first.committed, r'$1,500');
    expect(content.ledgerItems.last.status, 'IN PROGRESS');
    expect(content.ledgerItems.last.highlightStatus, isTrue);
    expect(content.commitmentTitle, 'Our commitment');
    expect(content.commitments, hasLength(2));
    expect(content.commitments.first.title, 'Accountability');
  });

  test('omits empty transparency sections', () {
    final page = PostItem.fromJson({
      'id': 14,
      'template': 'page-transparency.php',
      'acf_fields': {
        'common_header': {'hide_header': true},
      },
    });

    final content = TransparencyPageContent.fromPost(page);

    expect(content.hideHeader, isTrue);
    expect(content.showHeader, isFalse);
    expect(content.hasLedger, isFalse);
    expect(content.hasCommitments, isFalse);
    expect(content.hasFunding, isFalse);
  });
}
