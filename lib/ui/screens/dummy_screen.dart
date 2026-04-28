import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movie_deck/providers/providers.dart';
import 'package:movie_deck/ui/widgets/movie_detail_sheet.dart';
import 'package:page_transition/page_transition.dart';

import '../widgets/back_button_widget.dart';
import 'signup_screen.dart';

/// Guest exploration screen - browse trending movies without login
class DummyScreen extends HookConsumerWidget {
  const DummyScreen({Key? key}) : super(key: key);

  void _showLoginDialog(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            const FaIcon(FontAwesomeIcons.circleExclamation, color: Colors.red),
            const SizedBox(width: 10),
            Text('Sign In Required',
                style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          height: 50,
          child: Center(
            child: Text(
              'Sign in to add movies to your watchlist!',
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 17),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.outline, fontSize: 15),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                PageTransition(
                  child: const SignupScreen(),
                  type: PageTransitionType.rightToLeft,
                ),
              );
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final tmdbState = ref.watch(tmdbMoviesProvider);
    final movies = tmdbState.movies;
    final searchController = useTextEditingController();

    useEffect(() {
      Future.microtask(
          () => ref.read(tmdbMoviesProvider.notifier).getTrending());
      return null;
    }, []);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: NestedScrollView(
        headerSliverBuilder: (_, bool innerBoxIsScrolled) {
          return [
            // Header
            SliverPadding(
              padding: const EdgeInsets.only(top: 24),
              sliver: SliverToBoxAdapter(
                child: Container(
                  height: 110,
                  padding: const EdgeInsets.only(left: 4, top: 20, right: 20),
                  child: Row(
                    children: [
                      backButton(context),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explore',
                              style: GoogleFonts.ubuntu(
                                  fontSize: 36, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Browse trending movies',
                              style: GoogleFonts.openSans(
                                fontSize: 14,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: () {
                          Navigator.of(context).push(
                            PageTransition(
                              child: const SignupScreen(),
                              type: PageTransitionType.rightToLeft,
                            ),
                          );
                        },
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Search bar
            SliverToBoxAdapter(
              child: Container(
                height: 50,
                margin: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                child: TextFormField(
                  controller: searchController,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      ref.read(tmdbMoviesProvider.notifier).getTrending();
                    } else {
                      ref.read(tmdbMoviesProvider.notifier).searchMovies(value);
                    }
                  },
                  decoration: InputDecoration(
                    fillColor: colors.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 12),
                    hintText: "Search movies...",
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 12),
                      child: FaIcon(FontAwesomeIcons.magnifyingGlass,
                          size: 18, color: colors.outline),
                    ),
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 0, minHeight: 0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28)),
                  ),
                ),
              ),
            ),
          ];
        },
        body: movies.isEmpty && tmdbState.isLoading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: colors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Loading movies...',
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              )
            : movies.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.movie_filter,
                            size: 64,
                            color: colors.primary.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'No movies found',
                          style: GoogleFonts.poppins(
                              fontSize: 16, color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.6,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final movie = movies[index];
                      return _GuestMovieCard(
                        movie: movie,
                        colors: colors,
                        onLoginTap: () => _showLoginDialog(context),
                      );
                    },
                  ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        height: 60,
        width: 60,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () => _showLoginDialog(context),
            elevation: 10,
            backgroundColor: colors.primary,
            tooltip: 'Sign in to add movies',
            child: Icon(Icons.person_add, color: colors.onPrimary),
          ),
        ),
      ),
    );
  }
}

class _GuestMovieCard extends ConsumerWidget {
  final dynamic movie;
  final ColorScheme colors;
  final VoidCallback onLoginTap;

  const _GuestMovieCard({
    required this.movie,
    required this.colors,
    required this.onLoginTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showMovieDetails(context, ref),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: colors.surfaceContainerLow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: CachedNetworkImage(
                imageUrl: 'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: colors.surfaceContainerHighest,
                  child: Center(
                    child: CircularProgressIndicator(color: colors.primary),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: colors.surfaceContainerHighest,
                  child: Icon(Icons.image_not_supported, color: colors.outline),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title ?? 'Unknown',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.openSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.star,
                        size: 12,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(movie.voteAverage ?? 0).toStringAsFixed(1)}/10',
                        style: GoogleFonts.lato(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMovieDetails(BuildContext context, WidgetRef ref) {
    MovieDetailSheet.show(
      context,
      child: _GuestSheetContent(movie: movie, onLoginTap: onLoginTap),
    );
  }
}

class _GuestSheetContent extends ConsumerStatefulWidget {
  final dynamic movie;
  final VoidCallback onLoginTap;

  const _GuestSheetContent({
    required this.movie,
    required this.onLoginTap,
  });

  @override
  ConsumerState<_GuestSheetContent> createState() => _GuestSheetContentState();
}

class _GuestSheetContentState extends ConsumerState<_GuestSheetContent> {
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
    final movie = widget.movie;

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
        child: FilledButton.icon(
          onPressed: widget.onLoginTap,
          icon: const Icon(Icons.person_add),
          label: const Text('Sign In to Add', style: TextStyle(fontSize: 15)),
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}
