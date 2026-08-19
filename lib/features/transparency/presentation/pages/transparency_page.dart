import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/apa_assets.dart';
import '../../../../core/constants/apa_shell_insets.dart';
import '../../../../core/theme/apa_colors.dart';
import '../../../../core/theme/apa_fonts.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/apa_shared_widgets.dart';

/// Transparency Page — Figma frame `9:508`.
class TransparencyPage extends StatelessWidget {
  const TransparencyPage({
    super.key,
    this.scrollController,
    this.imageUrl,
  });

  final ScrollController? scrollController;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final navBottomPad = ApaShellInsets.contentBottom(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: ApaColors.white,
        child: CustomScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: ApaHeroHeader(
                imageAsset: ApaAssets.transparencyHero,
                imageUrl: imageUrl,
                height: 540,
                badge: 'OPEN BOOKS',
                headline: [
                  TextSpan(
                    text: 'EVERY DOLLAR,\n',
                    style: ApaFonts.inter(
                      color: ApaColors.white,
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w800,
                      height: 40 / 36,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextSpan(
                    text: 'ON THE RECORD.',
                    style: ApaFonts.inter(
                      color: ApaColors.primaryRedDeep,
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w800,
                      height: 40 / 36,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
                subtitle:
                    'A running ledger of phase-one work in Sud — updated as '
                    'each project moves forward.',
              ),
            ),
            SliverToBoxAdapter(
              child: ApaPageWidth(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    R.isTabletLandscape(context) ? 48 : 24.w,
                    40.h,
                    R.isTabletLandscape(context) ? 48 : 24.w,
                    navBottomPad,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (R.isTabletLandscape(context))
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const _RaisedBox(),
                            SizedBox(width: 40.w),
                            const Expanded(child: _ProgressBlock()),
                          ],
                        )
                      else ...[
                        const _RaisedBox(),
                        SizedBox(height: 24.h),
                        const _ProgressBlock(),
                      ],
                      SizedBox(height: 24.h),
                      const ColoredBox(
                        color: ApaColors.black,
                        child: SizedBox(height: 1, width: double.infinity),
                      ),
                      SizedBox(height: 32.h),
                      Text(
                        'PROJECT LEDGER',
                        style: ApaFonts.inter(
                          color: ApaColors.black,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w800,
                          height: 34 / 28,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      const _LedgerHeader(),
                      const _LedgerRow(
                        project: 'Solar street lighting, phase 1',
                        community: 'Haiti',
                        status: 'IN PROGRESS',
                        committed: '\$9,400',
                        statusHighlighted: true,
                      ),
                      const _LedgerRow(
                        project: 'Road repair — market route',
                        community: 'Torbeck',
                        status: 'SURVEYING',
                        committed: '\$7,200',
                      ),
                      const _LedgerRow(
                        project: 'Community park & playground',
                        community: 'Haiti',
                        status: 'DESIGN',
                        committed: '\$5,100',
                      ),
                      const _LedgerRow(
                        project: 'Operations & reporting',
                        community: '—',
                        status: 'ONGOING',
                        committed: '\$3,300',
                      ),
                      SizedBox(height: 48.h),
                      Text(
                        'OUR COMMITMENT',
                        style: ApaFonts.inter(
                          color: ApaColors.black,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w800,
                          height: 34 / 28,
                        ),
                      ),
                      SizedBox(height: 28.h),
                      if (R.isTabletLandscape(context))
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _CommitmentBlock(
                                title: 'Accountability',
                                body:
                                    'Financial transparency and independent review of '
                                    'the books.',
                              ),
                            ),
                            SizedBox(width: 28),
                            Expanded(
                              child: _CommitmentBlock(
                                title: 'Community first',
                                body:
                                    'Neighbors involved at every stage, from choosing a '
                                    'site to maintaining it.',
                              ),
                            ),
                            SizedBox(width: 28),
                            Expanded(
                              child: _CommitmentBlock(
                                title: 'Built to last',
                                body:
                                    'Sustainable, environmentally responsible solutions '
                                    'and regular reporting to donors.',
                              ),
                            ),
                          ],
                        )
                      else ...[
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
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RaisedBox extends StatelessWidget {
  const _RaisedBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.w,
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: ApaColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: ApaColors.black, width: 2),
      ),
      child: Column(
        children: [
          Text(
            '\$25,000',
            style: ApaFonts.inter(
              color: ApaColors.nearBlack,
              fontSize: 32.sp,
              fontWeight: FontWeight.w800,
              height: 32 / 28,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'RAISED TO DATE',
            textAlign: TextAlign.center,
            style: ApaFonts.inter(
              color: ApaColors.primaryRed,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              height: 20 / 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBlock extends StatelessWidget {
  const _ProgressBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: SizedBox(
            height: 14.h,
            child: const LinearProgressIndicator(
              value: 0.21,
              backgroundColor: ApaColors.gray100,
              color: ApaColors.navy,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          '21% of phase-one goal — \$120,000 for Sud',
          style: ApaFonts.inter(
            color: ApaColors.gray700,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            height: 20 / 14,
          ),
        ),
      ],
    );
  }
}

class _ThickSeparator extends StatelessWidget {
  const _ThickSeparator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: const ColoredBox(
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
          style: ApaFonts.inter(
            color: ApaColors.black,
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            height: 28 / 22,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          body,
          style: ApaFonts.inter(
            color: ApaColors.gray700,
            fontSize: 15.sp,
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
    final style = ApaFonts.inter(
      color: ApaColors.gray500,
      fontSize: 11.sp,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 3, child: Text('PROJECT', style: style)),
            Expanded(flex: 2, child: Text('COMMUNITY', style: style)),
            Expanded(flex: 2, child: Text('STATUS', style: style)),
            Expanded(
              flex: 2,
              child: Text(
                'COMMITTED',
                style: style,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        const ColoredBox(
          color: ApaColors.black,
          child: SizedBox(height: 2, width: double.infinity),
        ),
      ],
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({
    required this.project,
    required this.community,
    required this.status,
    required this.committed,
    this.statusHighlighted = false,
  });

  final String project;
  final String community;
  final String status;
  final String committed;
  final bool statusHighlighted;

  @override
  Widget build(BuildContext context) {
    final statusBackground =
        statusHighlighted ? ApaColors.navy : ApaColors.gray100;
    final statusTextColor =
        statusHighlighted ? ApaColors.white : ApaColors.nearBlack;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h),
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
              style: ApaFonts.inter(
                color: ApaColors.nearBlack,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                height: 16 / 12,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              community,
              style: ApaFonts.inter(
                color: ApaColors.gray800,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  status,
                  style: ApaFonts.inter(
                    color: statusTextColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              committed,
              textAlign: TextAlign.right,
              style: ApaFonts.inter(
                color: ApaColors.nearBlack,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
