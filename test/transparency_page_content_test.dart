import 'package:apa/data/models/post/post_model.dart';
import 'package:apa/features/transparency/domain/transparency_page_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps transparency get-post-details (ledger + funding labels)', () {
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
        'common_header': {
          'top_tag_line': 'Open books',
          'heading_text_one': 'Every dollar,',
          'heading_text_two': 'on the record.',
          'last_content':
              'We publish what came in, what went out, and what it built.',
        },
        'funding_summary': {
          'raised_label': 'Raised to date',
          'goal_label': 'Phase one goal',
          'funded_label': 'funded',
        },
        'project_ledger': {
          'title': 'Project ledger',
          'col_project': 'Project',
        },
        'commitment': {
          'title': 'Our commitment',
          'items': [
            {
              'heading': 'Accountability',
              'content':
                  'Financial transparency and independent review of the books.',
            },
            {
              'heading': 'Community first',
              'content': 'Neighbors involved at every stage.',
            },
          ],
        },
        'ledger_columns': [
          {
            'heading': 'Community',
            'fact': 'Community',
            'display': 'text',
            'align': 'left',
          },
          {
            'heading': 'Status',
            'fact': 'Status',
            'display': 'badge',
            'align': 'left',
            'text_color': '#0b0b0b',
            'bg_color': '#f1f2f6',
            'radius': 999,
            'hl_values': ['In progress', 'Ongoing'],
            'hl_text_color': '#ffffff',
            'hl_bg_color': '#00209f',
          },
          {
            'heading': 'Committed',
            'fact': 'Committed',
            'display': 'text',
            'align': 'right',
          },
        ],
        'ledger': [
          {
            'id': 347,
            'title': 'Community park &#038; playground #2',
            'community': 'Haiti2',
            'status': '',
            'committed': '',
            'cells': [
              {
                'heading': 'Community',
                'value': 'Haiti2',
                'display': 'text',
                'align': 'left',
              },
              {
                'heading': 'Status',
                'value': '',
                'display': 'badge',
                'align': 'left',
              },
              {
                'heading': 'Committed',
                'value': '',
                'display': 'text',
                'align': 'right',
              },
            ],
          },
          {
            'id': 339,
            'title': 'Exercitation ut aut',
            'cells': [
              {
                'value': 'Haiti',
                'display': 'text',
                'align': 'left',
              },
              {
                'value': 'Ongoing',
                'display': 'badge',
                'align': 'left',
                'text_color': '#ffffff',
                'bg_color': '#00209f',
                'highlighted': true,
                'radius': 999,
              },
              {
                'value': '\$76',
                'display': 'text',
                'align': 'right',
              },
            ],
          },
        ],
        'pagination': {
          'page': 1,
          'per_page': 5,
          'total_pages': 2,
          'has_more': true,
        },
        'total_projects': 8,
      },
      'funding_progress': {
        'raised_amount': 24425,
        'raised_formatted': '24,425',
        'target_amount': 120000,
        'target_formatted': '120,000',
        'percent_funded': 20,
      },
    });

    final content = TransparencyPageContent.fromPost(page);

    expect(content.topTagLine, 'Open books');
    expect(content.headingTextOne, 'Every dollar,');
    expect(content.headingTextTwo, 'on the record.');
    expect(content.funding.raisedLabel, r'$24,425');
    expect(content.funding.raisedCaption, 'Raised to date');
    expect(content.funding.progressValue, closeTo(0.20, 0.001));
    expect(
      content.funding.progressCaption,
      r'Phase one goal: $120,000 · 20% funded',
    );
    expect(content.ledgerTitle, 'Project ledger');
    expect(content.projectColumnHeading, 'Project');
    expect(content.ledgerColumns, hasLength(3));
    expect(content.ledgerItems, hasLength(2));
    expect(content.ledgerItems.first.project, 'Community park & playground #2');
    expect(content.ledgerItems.first.cells.first.value, 'Haiti2');
    expect(content.ledgerItems.last.cells[1].value, 'Ongoing');
    expect(content.ledgerItems.last.cells[1].highlighted, isTrue);
    expect(content.commitmentTitle, 'Our commitment');
    expect(content.commitments, hasLength(2));
    expect(content.commitments.first.title, 'Accountability');
    expect(content.pagination.totalPages, 2);
  });

  test('falls back to related_project + footer HTML', () {
    final page = PostItem.fromJson({
      'id': 14,
      'template': 'page-transparency.php',
      'acf_fields': {
        'common_header': {
          'top_tag_line': 'Open books',
          'heading_text_one': 'Every dollar,',
          'heading_text_two': 'on the record.',
        },
        'footer':
            '<h2>Our commitment</h2><article><h3>Accountability</h3><p>Financial transparency and independent review of the books.</p></article>',
        'related_project': [
          {
            'title': 'Community park &amp; playground',
            'acf_fields': {
              'community': 'Haiti',
              'status': 'In progress',
              'committed': '1500',
            },
          },
        ],
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

    expect(content.funding.raisedLabel, r'$20,825');
    expect(content.funding.progressCaption, contains('17% funded'));
    expect(content.ledgerItems, hasLength(1));
    expect(content.ledgerItems.first.project, 'Community park & playground');
    expect(content.commitmentTitle, 'Our commitment');
    expect(content.commitments.single.title, 'Accountability');
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

  test('builds ledger row from project + columns', () {
    final project = PostItem.fromJson({
      'id': 132,
      'title': 'Community park & playground',
      'acf_fields': {
        'project_details': [
          {'label': 'Community', 'text': 'Haiti'},
          {'label': 'Status', 'text': 'Design'},
          {'label': 'Committed', 'text': r'$1,500'},
          {'label': 'New Test', 'text': '15'},
        ],
      },
    });
    final columns = [
      TransparencyLedgerColumn.fromJson({
        'heading': 'Community',
        'fact': 'Community',
        'display': 'text',
        'align': 'left',
      }),
      TransparencyLedgerColumn.fromJson({
        'heading': 'Status',
        'fact': 'Status',
        'display': 'badge',
        'align': 'left',
        'hl_values': ['In progress', 'Ongoing', 'Completed'],
        'text_color': '#0b0b0b',
        'bg_color': '#f1f2f6',
        'hl_text_color': '#ffffff',
        'hl_bg_color': '#00209f',
        'radius': 999,
      }),
      TransparencyLedgerColumn.fromJson({
        'heading': 'Committed',
        'fact': 'Committed',
        'display': 'text',
        'align': 'right',
      }),
      TransparencyLedgerColumn.fromJson({
        'heading': 'News',
        'fact': 'New',
        'display': 'badge',
        'align': 'right',
        'hl_values': ['Good Job'],
      }),
      TransparencyLedgerColumn.fromJson({
        'heading': 'News2',
        'fact': 'New Test',
        'display': 'text',
        'align': 'right',
      }),
    ];

    final row = TransparencyLedgerItem.fromProject(project, columns);
    // Matches live web ledger page 2 first row.
    expect(row.project, 'Community park & playground');
    expect(row.cells.map((c) => c.value).toList(), [
      'Haiti',
      'Design',
      r'$1,500',
      '',
      '15',
    ]);
    expect(row.cells[1].highlighted, isFalse);
    expect(row.cells[1].bgColor, '#f1f2f6');
  });

  test('page-2 In progress row is highlighted navy badge', () {
    final project = PostItem.fromJson({
      'id': 128,
      'title': 'Solar street lighting, phase 1',
      'acf_fields': {
        'project_details': [
          {'label': 'Community', 'text': 'Haiti'},
          {'label': 'Status', 'text': 'In progress'},
          {'label': 'Committed', 'text': r'$9,400'},
        ],
      },
    });
    final columns = [
      TransparencyLedgerColumn.fromJson({
        'heading': 'Status',
        'fact': 'Status',
        'display': 'badge',
        'hl_values': ['In progress', 'Ongoing', 'Completed'],
        'hl_text_color': '#ffffff',
        'hl_bg_color': '#00209f',
      }),
      TransparencyLedgerColumn.fromJson({
        'heading': 'Committed',
        'fact': 'Committed',
        'display': 'text',
        'align': 'right',
      }),
    ];
    final row = TransparencyLedgerItem.fromProject(project, columns);
    expect(row.cells[0].value, 'In progress');
    expect(row.cells[0].highlighted, isTrue);
    expect(row.cells[0].bgColor, '#00209f');
    expect(row.cells[1].value, r'$9,400');
  });
}
