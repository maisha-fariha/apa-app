import 'package:apa/data/models/post/post_model.dart';
import 'package:apa/features/vision/domain/vision_page_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps vision get-post-details ACF groups without dummy fallbacks', () {
    final page = PostItem.fromJson({
      'success': true,
      'id': 51,
      'title': 'Our Vision',
      'template': 'page-vision.php',
      'featured_image': {
        'id': 83,
        'url':
            'https://encoder-staging.space/ansanm-pou-haiti/wp-content/uploads/2026/08/mission-1-scaled.webp',
        'alt': '',
      },
      'acf_fields': {
        'common_header': {
          'hide_header': false,
          'top_tag_line': 'Our vision',
          'heading_text_one': 'Building a stronger',
          'heading_text_two': 'sustainable future together.',
          'last_content':
              'A future where innovation, unity, and opportunity empower communities for generations.',
        },
        'vision_statement_subheading': 'Our vision statement',
        'vision_statement_text':
            'We envision resilient communities powered by sustainable development, modern infrastructure, education, and collaboration.',
        'core_values_title': 'Core values',
        'future_goals_title': 'Future goals',
        'join_mission_title': 'Join our mission',
        'join_mission_button_text': 'Learn more',
        'join_mission_button_url':
            'https://encoder-staging.space/ansanm-pou-haiti/contact-us/',
        'core_values_item_1': {
          'icon': 253,
          'title': 'Sustainability',
          'content': 'Creating solutions that protect future generations.',
        },
        'core_values_item_2': {
          'icon': 254,
          'title': 'Unity',
          'content': 'Bringing people together around shared goals.',
        },
        'core_values_item_3': {
          'icon': 255,
          'title': 'Innovation',
          'content': 'Building creative solutions for real challenges.',
        },
        'core_values_item_4': {
          'icon': false,
          'title': 'Sustainability',
          'content': 'Creating solutions that protect future generations.',
        },
        'future_goal_item_group_1': {
          'heading': '2026 — Community growth',
          'sub_heading': 'Expand development programs.',
        },
        'future_goal_item_group_2': {
          'heading': '2026 — Community growth',
          'sub_heading': 'Expand development programs.',
        },
        'future_goal_item_group_3': {
          'heading': '2030 — Sustainable infrastructure',
          'sub_heading': 'Deliver long-term impact projects.',
        },
        'future_goal_item_group_4': {
          'heading': '2035 — Global collaboration',
          'sub_heading': 'Connect communities worldwide.',
        },
        'success_statistics_group_1': {
          'heading': '50+',
          'sub_heading': 'Projects',
        },
        'success_statistics_group_2': {
          'heading': '20K+',
          'sub_heading': 'People Impacted',
        },
        'success_statistics_group_3': {
          'heading': '15+',
          'sub_heading': 'Partners',
        },
        'success_statistics_group_4': {
          'heading': '10',
          'sub_heading': 'Years Vision',
        },
      },
    });

    final content = VisionPageContent.fromPost(page);

    expect(content.topTagLine, 'Our vision');
    expect(content.headingTextOne, 'Building a stronger');
    expect(content.headingTextTwo, 'sustainable future together.');
    expect(content.coreValues, hasLength(4));
    expect(content.coreValues.first.title, 'Sustainability');
    expect(content.coreValues.first.iconId, 253);
    expect(content.coreValues.last.iconId, isNull);
    expect(content.futureGoals, hasLength(4));
    expect(content.futureGoals.last.heading, '2035 — Global collaboration');
    expect(content.stats, hasLength(4));
    expect(content.stats[1].subHeading, 'People Impacted');
    expect(content.joinMissionButtonText, 'Learn more');
    expect(content.showHeader, isTrue);
  });

  test('skips empty numbered vision groups', () {
    final page = PostItem.fromJson({
      'id': 51,
      'template': 'page-vision.php',
      'acf_fields': {
        'common_header': {'hide_header': true},
        'core_values_item_2': {
          'title': 'Unity',
          'content': 'Bringing people together around shared goals.',
        },
        'future_goal_item_group_1': {
          'heading': '',
          'sub_heading': '',
        },
      },
    });

    final content = VisionPageContent.fromPost(page);

    expect(content.hideHeader, isTrue);
    expect(content.showHeader, isFalse);
    expect(content.coreValues, hasLength(1));
    expect(content.coreValues.single.title, 'Unity');
    expect(content.futureGoals, isEmpty);
    expect(content.hasJoinMission, isFalse);
  });
}
