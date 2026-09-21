import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/track_pill.dart';
import '../../../../injection_container.dart';
import '../../../onboarding/data/stack_tracks.dart';
import '../../../onboarding/domain/entities/stack_track.dart';
import '../../../progress/domain/usecases/record_attempt.dart';

/// 3D flip-card practice view launched from a topic's "3D Flashcards" action.
class FlashcardPage extends StatelessWidget {
  const FlashcardPage({super.key, required this.topicId});

  final String topicId;

  @override
  Widget build(BuildContext context) {
    return _FlashcardView(topicId: topicId);
  }
}

class _FlashcardView extends StatefulWidget {
  const _FlashcardView({required this.topicId});

  final String topicId;

  @override
  State<_FlashcardView> createState() => _FlashcardViewState();
}

class _FlashcardViewState extends State<_FlashcardView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  int _index = 0;
  List<_Flashcard> _cards = [];
  bool _loading = true;
  int _masteredCount = 0;
  int _reviewLaterCount = 0;

  StackTrack? get _track {
    for (final t in kStackTracks) {
      if (t.id == widget.topicId) return t;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() => _loading = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('tracks')
          .doc(widget.topicId)
          .collection('flipcards')
          .get();
      final cards = snap.docs.map((d) {
        final data = d.data();
        _CodeSnippet? code;
        final language = (data['codeLanguage'] ?? '').toString();
        final codeLines = (data['codeLines'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList();
        if (language.isNotEmpty && (codeLines?.isNotEmpty ?? false)) {
          code = _CodeSnippet(
            filename:
                (data['codeHeader'] ?? language).toString(),
            language: language,
            lines: codeLines!,
          );
        }
        return _Flashcard(
          term: (data['term'] ?? '').toString(),
          definition: (data['definition'] ?? '').toString(),
          code: code,
        );
      }).toList();
      setState(() {
        _cards = cards;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _toggleFlip() {
    if (_flip.value < 0.5) {
      _flip.forward();
    } else {
      _flip.reverse();
    }
  }

  void _next({required bool mastered}) {
    if (_cards.isEmpty) return;
    if (mastered) {
      _masteredCount++;
    } else {
      _reviewLaterCount++;
    }
    setState(() {
      _flip.value = 0;
      _index = (_index + 1) % _cards.length;
    });
  }

  /// Rolls every card reviewed in this sitting into a single attempt, so
  /// "total sessions" on the progress tab counts one flashcard review as
  /// one session rather than one per card flipped.
  void _flushReviewSession() {
    final reviewed = _masteredCount + _reviewLaterCount;
    if (reviewed == 0) return;
    unawaited(
      sl<RecordAttempt>()(
        RecordAttemptParams(
          trackId: widget.topicId,
          type: 'flashcard',
          correct: _masteredCount,
          total: reviewed,
        ),
      ),
    );
    _masteredCount = 0;
    _reviewLaterCount = 0;
  }

  @override
  void dispose() {
    _flushReviewSession();
    _flip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final track = _track;
    final accentColor = track?.color ?? AppColors.primaryFixedDim;
    final trackName = track?.name ?? widget.topicId;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              trailing: InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: AppRadius.radiusSm,
                child: Padding(
                  padding: EdgeInsets.all(4.r),
                  child: Icon(
                    Icons.close_rounded,
                    size: 22.r,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const _FlashcardSkeleton()
                  : _cards.isEmpty
                      ? Center(
                          child: Text(
                            'No flashcards for $trackName yet.',
                            style: AppTypography.bodyLg.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        )
                      : _buildDeck(accentColor: accentColor, trackName: trackName),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeck({
    required Color accentColor,
    required String trackName,
  }) {
    final card = _cards[_index];
    return Padding(
      padding: EdgeInsets.all(AppSpacing.margin),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              'CARD ${_index + 1} OF ${_cards.length}',
              style: AppTypography.labelMono.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _flip,
              builder: (context, child) {
                final angle = _flip.value * math.pi;
                final showBack = angle > math.pi / 2;
                return GestureDetector(
                  onTap: _toggleFlip,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0012)
                      ..rotateY(angle),
                    child: showBack
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..rotateY(math.pi),
                            child: _CardBack(card: card),
                          )
                        : _CardFront(
                            card: card,
                            trackName: trackName,
                            accentColor: accentColor,
                          ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _next(mastered: false),
                  icon: Icon(
                    Icons.history_rounded,
                    size: 20.r,
                    color: AppColors.onSurfaceVariant,
                  ),
                  label: Text(
                    'Review Later',
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.outlineVariant,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusBase,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _next(mastered: true),
                  icon: Icon(
                    Icons.check_circle_rounded,
                    size: 20.r,
                    color: AppColors.onPrimaryContainer,
                  ),
                  label: Text(
                    'Mastered',
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusBase,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shimmering placeholder matching the flip card's front while flashcards
/// are still loading from Firestore.
class _FlashcardSkeleton extends StatelessWidget {
  const _FlashcardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.margin),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                'CARD 1 OF 5',
                style: AppTypography.labelMono.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: AppRadius.radiusLg,
                  border: Border.all(
                    color: AppColors.primaryFixedDim,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 90.r,
                        height: 28.r,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: AppRadius.radiusFull,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Flashcard Term',
                          textAlign: TextAlign.center,
                          style: AppTypography.headlineLg.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48.r,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: AppRadius.radiusBase,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Container(
                    height: 48.r,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: AppRadius.radiusBase,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  const _CardFront({
    required this.card,
    required this.trackName,
    required this.accentColor,
  });

  final _Flashcard card;
  final String trackName;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(color: AppColors.primaryFixedDim, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TrackPill(label: trackName, dotColor: accentColor),
              ],
            ),
            Expanded(
              child: Center(
                child: Text(
                  card.term,
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineLg.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ),
            const _DotDivider(),
            SizedBox(height: AppSpacing.sm),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cached_rounded,
                    size: 16.r,
                    color: AppColors.onSurfaceVariant,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'Tap to flip',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({required this.card});

  final _Flashcard card;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(color: AppColors.primaryFixedDim, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Definition',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.close_rounded,
                  size: 20.r,
                  color: AppColors.onSurfaceVariant,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.definition,
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    if (card.code != null) ...[
                      SizedBox(height: AppSpacing.lg),
                      _CodeBlock(snippet: card.code!),
                    ],
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

class _DotDivider extends StatelessWidget {
  const _DotDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4.r,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 10.0;
          final count = math.max(2, (constraints.maxWidth / spacing).floor());
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              count,
              (_) => Container(
                width: 3.r,
                height: 3.r,
                decoration: const BoxDecoration(
                  color: AppColors.outlineVariant,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.snippet});

  final _CodeSnippet snippet;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.radiusMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 28.r,
            color: AppColors.surfaceContainerLowest,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              children: [
                _trafficDot(const Color(0xFFFF5F56)),
                SizedBox(width: 6.r),
                _trafficDot(const Color(0xFFFFBD2E)),
                SizedBox(width: 6.r),
                _trafficDot(const Color(0xFF27C93F)),
                const Spacer(),
                Text(
                  snippet.filename,
                  style: AppTypography.labelMono.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: AppColors.codeBlockBackground,
            padding: EdgeInsets.all(AppSpacing.sm + 4.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line in snippet.lines)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.r),
                    child: RichText(
                      text: TextSpan(children: _highlightLine(line)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<InlineSpan> _highlightLine(String line) {
    final spans = <InlineSpan>[];
    final tokenPattern = RegExp(r'//.*$|"[^"]*"|\w+|[^\w\s]+|\s+');
    for (final match in tokenPattern.allMatches(line)) {
      final token = match.group(0)!;
      Color color;
      if (token.startsWith('//')) {
        color = AppColors.onSurfaceVariant.withValues(alpha: 0.7);
      } else if (token.startsWith('"')) {
        color = AppColors.primaryFixedDim;
      } else if (_kKeywords.contains(token)) {
        color = AppColors.primary;
      } else {
        color = AppColors.onSurface;
      }
      spans.add(
        TextSpan(
          text: token.isEmpty ? ' ' : token,
          style: AppTypography.codeSm.copyWith(color: color),
        ),
      );
    }
    return spans;
  }

  Widget _trafficDot(Color color) {
    return Container(
      width: 8.r,
      height: 8.r,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

const _kKeywords = <String>{
  'import',
  'fun',
  'val',
  'var',
  'return',
  'if',
  'else',
  'for',
  'while',
  'class',
  'object',
  'suspend',
  'launch',
  'async',
  'runBlocking',
  'coroutineScope',
  'supervisorScope',
  'CoroutineScope',
  'SupervisorJob',
  'delay',
  'println',
  'inline',
  'reified',
  'data',
  'when',
  'in',
  'is',
};

class _Flashcard {
  const _Flashcard({
    required this.term,
    required this.definition,
    this.code,
  });

  final String term;
  final String definition;
  final _CodeSnippet? code;
}

class _CodeSnippet {
  const _CodeSnippet({
    required this.filename,
    required this.language,
    required this.lines,
  });

  final String filename;
  final String language;
  final List<String> lines;
}
