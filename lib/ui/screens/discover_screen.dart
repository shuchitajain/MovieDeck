import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movie_deck/domain/entities/tmdb_movie.dart';
import 'package:movie_deck/providers/providers.dart';
import 'package:movie_deck/ui/widgets/back_button_widget.dart';

import '../widgets/movie_detail_sheet.dart';

class DiscoverScreen extends HookConsumerWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final searchController = useTextEditingController();
    final tmdbState = ref.watch(tmdbMoviesProvider);
    final movies = tmdbState.movies;
    final isSearching = useState(false);

    // Load trending on first build
    useEffect(() {
      Future.microtask(
          () => ref.read(tmdbMoviesProvider.notifier).getTrending());
      return null;
    }, []);

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
                    "Discover Movies",
                    style: GoogleFonts.ubuntu(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search movies...",
                  filled: true,
                  fillColor: colors.surfaceContainerHighest,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: FaIcon(FontAwesomeIcons.magnifyingGlass,
                        size: 18, color: colors.outline),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0),
                  suffixIcon: isSearching.value &&
                          searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            searchController.clear();
                            isSearching.value = false;
                            ref.read(tmdbMoviesProvider.notifier).getTrending();
                          },
                          icon: FaIcon(FontAwesomeIcons.xmark,
                              size: 18, color: colors.outline),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                onChanged: (val) {
                  isSearching.value = val.isNotEmpty;
                  if (val.length >= 2) {
                    ref
                        .read(tmdbMoviesProvider.notifier)
                        .searchMoviesDebounced(val);
                  } else if (val.isEmpty) {
                    ref.read(tmdbMoviesProvider.notifier).getTrending();
                  }
                },
              ),
            ),

            // Movies grid
            Expanded(
              child: movies.isEmpty && !tmdbState.isLoading
                  ? Center(
                      child: Text(
                        isSearching.value
                            ? "No movies found"
                            : "No trending movies available.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    )
                  : movies.isEmpty && tmdbState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (notification is ScrollEndNotification &&
                                notification.metrics.pixels >=
                                    notification.metrics.maxScrollExtent -
                                        300) {
                              ref.read(tmdbMoviesProvider.notifier).loadMore();
                            }
                            return false;
                          },
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.6,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount:
                                movies.length + (tmdbState.hasMore ? 1 : 0),
                            itemBuilder: (_, index) {
                              if (index >= movies.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final movie = movies[index];
                              return _MovieCard(
                                movie: movie,
                                colors: colors,
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovieCard extends ConsumerWidget {
  final TMDBMovie movie;
  final ColorScheme colors;

  const _MovieCard({
    required this.movie,
    required this.colors,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dataProvider);
    final alreadyInWatchlist = data.items.any((m) => m.name == movie.title);

    return GestureDetector(
      onTap: () => _showMovieDetails(context, ref, movie, alreadyInWatchlist),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: colors.surface,
          border: alreadyInWatchlist
              ? Border.all(color: colors.primary, width: 2)
              : null,
        ),
        child: Stack(
          children: [
            // Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: movie.fullPosterUrl.isEmpty
                  ? Container(
                      color: colors.surfaceContainerHighest,
                      child: Center(
                        child:
                            Icon(Icons.movie, size: 48, color: colors.outline),
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: movie.fullPosterUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (_, __) => Container(
                        color: colors.surfaceContainerHighest,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: colors.surfaceContainerHighest,
                        child: Center(
                          child: Icon(Icons.movie,
                              size: 48, color: colors.outline),
                        ),
                      ),
                    ),
            ),

            // Overlay info
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          movie.year,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                        if (movie.voteAverage > 0)
                          Row(
                            children: [
                              Icon(Icons.star, size: 12, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                movie.voteAverage.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Checkmark if already added
            if (alreadyInWatchlist)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.check, size: 16, color: colors.onPrimary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showMovieDetails(
      BuildContext context, WidgetRef ref, TMDBMovie movie, bool inWatchlist) {
    MovieDetailSheet.show(
      context,
      child: _DiscoverSheetContent(movie: movie),
    );
  }
}

/// Stateful wrapper that fetches director/genre and builds a [MovieDetailSheet].
class _DiscoverSheetContent extends ConsumerStatefulWidget {
  final TMDBMovie movie;
  const _DiscoverSheetContent({required this.movie});

  @override
  ConsumerState<_DiscoverSheetContent> createState() =>
      _DiscoverSheetContentState();
}

class _DiscoverSheetContentState extends ConsumerState<_DiscoverSheetContent> {
  String _director = '';
  String _genre = '';
  bool _loadingDetails = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final tmdb = ref.read(tmdbRepositoryProvider);
    final details = await tmdb.getMovieDetails(widget.movie.id);
    if (mounted) {
      setState(() {
        _director = details['director'] ?? 'Unknown';
        _genre = details['genre'] ?? 'Other';
        _loadingDetails = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final movie = widget.movie;
    final data = ref.watch(dataProvider);
    final alreadyInWatchlist = data.items.any((m) => m.name == movie.title);

    return MovieDetailSheet(
      title: movie.title,
      posterUrl: movie.fullPosterUrl,
      year: movie.year,
      rating: movie.voteAverage,
      genre: _genre,
      director: _director,
      overview: movie.overview ?? '',
      isLoading: _loadingDetails,
      actionButtons: SizedBox(
        width: double.infinity,
        height: 50,
        child: alreadyInWatchlist
            ? OutlinedButton.icon(
                onPressed: () {
                  ref.read(dataProvider.notifier).deleteMovie(movie.title);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${movie.title} removed from watchlist'),
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('In Watchlist — Tap to Remove',
                    style: TextStyle(fontSize: 15)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.primary,
                  side: BorderSide(color: colors.primary, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              )
            : FilledButton.icon(
                onPressed: _loadingDetails
                    ? null
                    : () {
                        final now = DateTime.now().toString();
                        ref.read(dataProvider.notifier).addMovie(
                              movieName: movie.title,
                              directorName: _director,
                              genre: _genre,
                              imagePath: movie.fullPosterUrl,
                              createdAt: now,
                              updatedAt: now,
                            );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${movie.title} added to watchlist!'),
                          ),
                        );
                      },
                icon: const Icon(Icons.add),
                label: Text(
                  _loadingDetails ? 'Loading...' : 'Add to Watchlist',
                  style: const TextStyle(fontSize: 15),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
      ),
    );
  }
}
