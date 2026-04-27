import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movie_deck/domain/entities/recommendation.dart';
import 'package:movie_deck/providers/providers.dart';
import 'package:movie_deck/ui/widgets/back_button_widget.dart';

class RecommendationsScreen extends ConsumerStatefulWidget {
  const RecommendationsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RecommendationsScreen> createState() =>
      _RecommendationsScreenState();
}

class _RecommendationsScreenState extends ConsumerState<RecommendationsScreen> {
  final TextEditingController _moodController = TextEditingController();
  final List<String> _moodSuggestions = [
    '🎭 Something fun and light',
    '😱 A thrilling ride',
    '💕 A romantic evening',
    '🧠 Make me think',
    '🚀 Epic adventure',
    '😂 Need a good laugh',
  ];

  @override
  void dispose() {
    _moodController.dispose();
    super.dispose();
  }

  void _getRecommendations({String? mood}) {
    final gemini = ref.read(geminiProvider.notifier);
    final data = ref.read(dataProvider);

    if (!gemini.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add your Gemini API key in .env file'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    gemini.getRecommendations(data.items, mood: mood);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  backButton(context),
                  const Spacer(flex: 1),
                  Text(
                    "AI Recommendations",
                    style: GoogleFonts.ubuntu(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),

            // Mood input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "What are you in the mood for?",
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Mood chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _moodSuggestions.map((mood) {
                      return ActionChip(
                        label: Text(mood, style: const TextStyle(fontSize: 13)),
                        backgroundColor:
                            colors.primaryContainer.withValues(alpha: 0.5),
                        side: BorderSide(
                            color: colors.primary.withValues(alpha: 0.3)),
                        onPressed: () {
                          _moodController.text = mood;
                          _getRecommendations(mood: mood);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  // Custom mood input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _moodController,
                          decoration: InputDecoration(
                            hintText: "Or type your own mood...",
                            filled: true,
                            fillColor: colors.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Consumer(
                        builder: (_, ref, __) {
                          final gemini = ref.watch(geminiProvider);
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  colors.primary,
                                  colors.tertiary,
                                ],
                              ),
                            ),
                            child: IconButton(
                              onPressed: gemini.isLoading
                                  ? null
                                  : () => _getRecommendations(
                                        mood: _moodController.text,
                                      ),
                              icon: gemini.isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colors.onPrimary,
                                      ),
                                    )
                                  : Icon(Icons.auto_awesome,
                                      color: colors.onPrimary),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),

            // Results
            Expanded(
              child: Consumer(
                builder: (_, ref, __) {
                  final gemini = ref.watch(geminiProvider);

                  if (gemini.isLoading) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: colors.primary),
                          const SizedBox(height: 16),
                          Text(
                            "AI is thinking...",
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              color: colors.outline,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (gemini.error != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline,
                                size: 48, color: colors.error),
                            const SizedBox(height: 16),
                            Text(
                              gemini.error!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _getRecommendations(
                                mood: _moodController.text,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.primary,
                              ),
                              child: Text("Retry",
                                  style: TextStyle(color: colors.onPrimary)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (gemini.recommendations.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.movie_filter,
                                size: 64,
                                color: colors.primary.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            Text(
                              "Pick a mood or describe what you want to watch, and AI will recommend movies based on your watchlist!",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: colors.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: gemini.recommendations.length,
                    itemBuilder: (_, index) {
                      final rec = gemini.recommendations[index];
                      return _RecommendationCard(
                        recommendation: rec,
                        index: index + 1,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends ConsumerWidget {
  final Recommendation recommendation;
  final int index;

  const _RecommendationCard({
    required this.recommendation,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final data = ref.watch(dataProvider);
    final alreadyInWatchlist =
        data.items.any((m) => m.name == recommendation.title);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.15),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 120,
                child: recommendation.posterUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: recommendation.posterUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _posterPlaceholder(colors),
                        errorWidget: (_, __, ___) => _posterPlaceholder(colors),
                      )
                    : _posterPlaceholder(colors),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendation.title,
                    style: GoogleFonts.lato(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (recommendation.director.isNotEmpty &&
                      recommendation.director != 'Unknown')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'Directed by ${recommendation.director}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.outline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      if (recommendation.genre.isNotEmpty)
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              recommendation.genre,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      if (recommendation.year.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          recommendation.year,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.outline,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    recommendation.reason,
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      color: colors.onSurfaceVariant,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Add to Watchlist button
                  Align(
                    alignment: Alignment.centerRight,
                    child: alreadyInWatchlist
                        ? Chip(
                            avatar: Icon(Icons.check,
                                size: 16, color: colors.primary),
                            label: Text(
                              'In Watchlist',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.primary,
                              ),
                            ),
                            backgroundColor:
                                colors.primaryContainer.withValues(alpha: 0.5),
                            side: BorderSide.none,
                          )
                        : FilledButton.tonalIcon(
                            onPressed: () {
                              final now = DateTime.now().toString();
                              ref.read(dataProvider.notifier).addMovie(
                                    movieName: recommendation.title,
                                    directorName: recommendation.director,
                                    genre: recommendation.genre,
                                    imagePath: recommendation.posterUrl,
                                    createdAt: now,
                                    updatedAt: now,
                                  );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${recommendation.title} added to watchlist!'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add to Watchlist',
                                style: TextStyle(fontSize: 13)),
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

  Widget _posterPlaceholder(ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryContainer, colors.tertiaryContainer],
        ),
      ),
      child: Center(
        child: Text(
          recommendation.title.isNotEmpty
              ? recommendation.title[0].toUpperCase()
              : '?',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: colors.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
