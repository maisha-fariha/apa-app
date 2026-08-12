import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/widgets/apa_shared_widgets.dart';

/// Transparency Page — Figma frame `9:508`.
class TransparencyPage extends StatelessWidget {
  const TransparencyPage({super.key});

  static const double _navBottomPad = 120;

  static const TextStyle _headlineWhite = TextStyle(
    color: ApaColors.white,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 40 / 36,
    letterSpacing: -0.5,
  );

  static const TextStyle _headlineRed = TextStyle(
    color: ApaColors.primaryRedDeep,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 40 / 36,
    letterSpacing: -0.5,
  );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: ApaColors.white,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: ApaHeroHeader(
                imageAsset: ApaAssets.transparencyHero,
                height: 540,
                badge: 'OPEN BOOKS',
                headline: const [
                  TextSpan(text: 'EVERY DOLLAR,\n', style: _headlineWhite),
                  TextSpan(text: 'ON THE RECORD.', style: _headlineRed),
                ],
                subtitle:
                    'A running ledger of phase-one work in Sud — updated as '
                    'each project moves forward.',
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, _navBottomPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 194,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: ApaColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ApaColors.black, width: 2),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            '\$25,000',
                            style: TextStyle(
                              color: ApaColors.nearBlack,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              height: 32 / 28,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'RAISED TO DATE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ApaColors.gray600,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              height: 20 / 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9999),
                      child: const SizedBox(
                        height: 14,
                        child: LinearProgressIndicator(
                          value: 0.21,
                          backgroundColor: ApaColors.gray100,
                          color: ApaColors.navy,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '21% of phase-one goal — \$120,000 for Sud',
                      style: TextStyle(
                        color: ApaColors.gray700,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 20 / 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const ColoredBox(
                      color: ApaColors.black,
                      child: SizedBox(height: 1, width: double.infinity),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'PROJECT LEDGER',
                      style: TextStyle(
                        color: ApaColors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 34 / 28,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _LedgerHeader(),
                    const _LedgerRow(
                      project: 'Solar street lighting, phase 1',
                      amount: '\$8,200',
                      status: 'In progress',
                      statusColor: ApaColors.navy,
                      date: 'Mar 2026',
                    ),
                    const _LedgerRow(
                      project: 'Road repair — market route',
                      amount: '\$12,400',
                      status: 'Surveying',
                      statusColor: ApaColors.gray700,
                      date: 'Apr 2026',
                    ),
                    const _LedgerRow(
                      project: 'Community park — Sainte-Anne',
                      amount: '\$4,400',
                      status: 'Design',
                      statusColor: ApaColors.gray600,
                      date: '—',
                    ),
                    const _LedgerRow(
                      project: 'Drainage study — market route',
                      amount: '—',
                      status: 'Planned',
                      statusColor: ApaColors.gray500,
                      date: 'Q3 2026',
                    ),
                    const SizedBox(height: 48),
                    const Text(
                      'OUR COMMITMENT',
                      style: TextStyle(
                        color: ApaColors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 34 / 28,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const _CommitmentBlock(
                      title: 'Accountability',
                      body:
                          'Financial transparency and independent review of '
                          'the books.',
                    ),
                    const _ThickSeparator(),
                    const _CommitmentBlock(
                      title: 'Community first',
                      body:
                          'Neighbors involved at every stage, from choosing a '
                          'site to maintaining it.',
                    ),
                    const _ThickSeparator(),
                    const _CommitmentBlock(
                      title: 'Built to last',
                      body:
                          'Sustainable, environmentally responsible solutions '
                          'and regular reporting to donors.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThickSeparator extends StatelessWidget {
  const _ThickSeparator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: ColoredBox(
        color: ApaColors.gray200,
        child: SizedBox(height: 3, width: double.infinity),
      ),
    );
  }
}

class _CommitmentBlock extends StatelessWidget {
  const _CommitmentBlock({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: ApaColors.black,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 28 / 22,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: const TextStyle(
            color: ApaColors.gray700,
            fontSize: 15,
            height: 22 / 15,
          ),
        ),
      ],
    );
  }
}

class _LedgerHeader extends StatelessWidget {
  const _LedgerHeader();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      color: ApaColors.gray500,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
    );
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('PROJECT', style: style)),
          Expanded(flex: 2, child: Text('AMOUNT', style: style)),
          Expanded(flex: 2, child: Text('STATUS', style: style)),
          Expanded(
            flex: 2,
            child: Text('DATE', style: style, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({
    required this.project,
    required this.amount,
    required this.status,
    required this.statusColor,
    required this.date,
  });

  final String project;
  final String amount;
  final String status;
  final Color statusColor;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ApaColors.gray200)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              project,
              style: const TextStyle(
                color: ApaColors.nearBlack,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 16 / 12,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              amount,
              style: const TextStyle(
                color: ApaColors.gray800,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              date,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: ApaColors.gray600,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
