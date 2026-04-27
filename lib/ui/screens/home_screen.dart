import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:movie_deck/domain/entities/movie.dart';
import 'package:movie_deck/providers/providers.dart';
import 'package:movie_deck/ui/screens/add_movie_screen.dart';
import 'package:movie_deck/ui/screens/onboarding_screen.dart';
import 'package:movie_deck/ui/screens/recommendations_screen.dart';
import 'package:page_transition/page_transition.dart';

import '../config.dart';
import '../widgets/movie_detail_sheet.dart';
import 'discover_screen.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  Widget movieDetails(String title, String data, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: RichText(
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          text: "$title  ",
          style: GoogleFonts.lato(
            fontSize: 12,
            color: colors.outline,
            fontWeight: FontWeight.bold,
          ),
          children: [
            TextSpan(
              text: data,
              style: GoogleFonts.lato(
                fontSize: 12.5,
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final themeProv = ref.watch(themeProvider);
    final userName = useState("User");

    // Memoize the future so it doesn't re-fire on rebuilds
    final fetchFuture = useMemoized(
      () => ref.read(dataProvider.notifier).fetchAndSetMovie(),
    );
    final snapshot = useFuture(fetchFuture);

    // Load username once
    useEffect(() {
      App.fss.read(key: "name").then((name) {
        if (name != null) userName.value = name;
      });
      return null;
    }, []);

    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: NestedScrollView(
          headerSliverBuilder: (_, bool innerBoxIsScrolled) {
            return [
              SliverPadding(
                padding: const EdgeInsets.only(top: 24),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    height: 100,
                    padding:
                        const EdgeInsets.only(left: 20, top: 20, right: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome,',
                                style: GoogleFonts.ubuntu(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  text: "${userName.value}! ",
                                  style: GoogleFonts.openSans(
                                    fontSize: 17,
                                    color: colors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  children: const [TextSpan(text: "😀")],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Theme toggle
                        IconButton(
                          onPressed: () =>
                              ref.read(themeProvider.notifier).toggleTheme(),
                          icon: Icon(
                            themeProv.isDark
                                ? Icons.light_mode
                                : Icons.dark_mode,
                            size: 24,
                            color: colors.onSurface,
                          ),
                          tooltip: 'Toggle theme',
                        ),
                        // AI Recommendations button
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              PageTransition(
                                child: const RecommendationsScreen(),
                                type: PageTransitionType.rightToLeft,
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.auto_awesome,
                            size: 28,
                            color: colors.primary,
                          ),
                          tooltip: 'AI Recommendations',
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                contentPadding: const EdgeInsets.only(
                                    top: 30, left: 20, right: 20),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                content: Text(
                                  "Are you sure you want to log out?",
                                  style: TextStyle(
                                      color: colors.onSurface, fontSize: 18),
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                  TextButton(
                                    child: Text(
                                      'Yes',
                                      style: TextStyle(
                                        color: colors.onSurface,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      ref
                                          .read(authProvider.notifier)
                                          .signOut()
                                          .whenComplete(
                                              () => Navigator.pushReplacement(
                                                    context,
                                                    PageTransition(
                                                      child: OnboardingScreen(),
                                                      type: PageTransitionType
                                                          .rightToLeft,
                                                    ),
                                                  ));
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Icon(Icons.logout,
                              size: 30, color: colors.onSurface),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'My Watchlist',
                          style: GoogleFonts.openSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Consumer(
                        builder: (_, ref, ch) {
                          final movies = ref.watch(dataProvider);
                          return SizedBox(
                            height: 50,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                icon: const Visibility(
                                  visible: false,
                                  child: Icon(Icons.arrow_downward),
                                ),
                                style: TextStyle(
                                    fontSize: 14, color: colors.onSurface),
                                value: movies.isSorted,
                                onChanged: (val) => ref
                                    .read(dataProvider.notifier)
                                    .toggle(val!),
                                items: const [
                                  DropdownMenuItem(
                                      value: 0, child: Text("Sort A-Z")),
                                  DropdownMenuItem(
                                      value: 1, child: Text("Sort Z-A")),
                                  DropdownMenuItem(
                                      value: 2, child: Text("Last Added")),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: _buildBody(context, ref, snapshot, colors),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: SizedBox(
          height: 60,
          width: 60,
          child: FittedBox(
            child: FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) {
                    final sheetColors = Theme.of(context).colorScheme;
                    return SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: sheetColors.outline,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text("Add Movie",
                                style: GoogleFonts.ubuntu(
                                    fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),
                            ListTile(
                              leading: Icon(Icons.explore,
                                  color: sheetColors.primary),
                              title: const Text('Discover'),
                              subtitle: const Text('Search & browse from TMDB'),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              tileColor: sheetColors.primaryContainer
                                  .withValues(alpha: 0.3),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.of(context).push(
                                  PageTransition(
                                    child: const DiscoverScreen(),
                                    type: PageTransitionType.rightToLeft,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            ListTile(
                              leading: Icon(Icons.auto_awesome,
                                  color: sheetColors.primary),
                              title: const Text('Get AI Recommendations'),
                              subtitle: const Text(
                                  'AI suggests movies based on your watchlist'),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              tileColor: sheetColors.primaryContainer
                                  .withValues(alpha: 0.3),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.of(context).push(
                                  PageTransition(
                                    child: const RecommendationsScreen(),
                                    type: PageTransitionType.rightToLeft,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            ListTile(
                              leading: Icon(Icons.edit_note,
                                  color: sheetColors.secondary),
                              title: const Text('Add Manually'),
                              subtitle:
                                  const Text('Enter movie details yourself'),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              tileColor: sheetColors.secondaryContainer
                                  .withValues(alpha: 0.3),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.of(context).push(
                                  PageTransition(
                                    child: const AddMovieScreen(),
                                    type: PageTransitionType.rightToLeft,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              elevation: 10,
              backgroundColor: colors.primary,
              child: Icon(Icons.add, color: colors.onPrimary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPosterImage(movie, ColorScheme colors) {
    final url = movie.imageUrl as String;

    // Network image (TMDB poster URL)
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        placeholder: (_, __) => _posterPlaceholder(movie.name, colors),
        errorWidget: (_, __, ___) => _posterPlaceholder(movie.name, colors),
      );
    }

    // Local file image
    if (url.isNotEmpty && File(url).existsSync()) {
      return Image.file(File(url),
          fit: BoxFit.cover, height: double.infinity, width: double.infinity);
    }

    // Placeholder
    return _posterPlaceholder(movie.name, colors);
  }

  Widget _posterPlaceholder(String name, ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryContainer, colors.tertiaryContainer],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: GoogleFonts.ubuntu(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: colors.onPrimaryContainer.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref,
      AsyncSnapshot<void> snapshot, ColorScheme colors) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    return Consumer(
      builder: (ctx, ref, ch) {
        final movies = ref.watch(dataProvider);
        // Show error SnackBar if any
        if (movies.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _messengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text(movies.errorMessage!),
                backgroundColor: colors.error,
              ),
            );
            ref.read(dataProvider.notifier).clearError();
          });
        }
        if (movies.displayItems.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                "Tap the + button to add movies via AI recommendations or manually :)",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 110),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: movies.displayItems.length,
          itemBuilder: (_, index) {
            final movie = movies.displayItems[index];
            return GestureDetector(
              onTap: () => _showMovieDetailSheet(context, ref, movie),
              child: Container(
                height: App.height(context) / 3.7,
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                child: Stack(
                  children: [
                    Container(
                      width: App.width(context) / 2.3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: colors.surfaceContainerHighest,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _buildPosterImage(movie, colors),
                    ),
                    Positioned(
                      left: App.width(context) / 2.7,
                      top: 13,
                      bottom: 13,
                      child: Container(
                        width: App.width(context) / 2,
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Border.all(
                                      color: colors.outlineVariant
                                          .withValues(alpha: 0.3),
                                      width: 1,
                                    )
                                  : null,
                          boxShadow: [
                            if (Theme.of(context).brightness ==
                                Brightness.light)
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 15,
                                spreadRadius: 3,
                                offset: const Offset(0, 0.8),
                              )
                            else
                              BoxShadow(
                                color: colors.primary.withValues(alpha: 0.15),
                                blurRadius: 12,
                                spreadRadius: 1,
                                offset: const Offset(0, 1),
                              ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                movie.name,
                                maxLines: 2,
                                style: GoogleFonts.lato(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            movieDetails(
                                "Directed by:", movie.director, colors),
                            if (movie.genre.isNotEmpty)
                              movieDetails("Genre:", movie.genre, colors),
                            movieDetails(
                              "Added on:",
                              DateFormat('dd-MM-yyyy')
                                  .format(DateTime.parse(movie.createdOn))
                                  .toString(),
                              colors,
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.touch_app,
                                    size: 18,
                                    color:
                                        colors.outline.withValues(alpha: 0.4)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMovieDetailSheet(BuildContext context, WidgetRef ref, Movie movie) {
    MovieDetailSheet.show(
      context,
      child: _WatchlistSheetContent(movie: movie),
    ).then((result) {
      if (result is Movie) {
        final notifier = ref.read(dataProvider.notifier);
        _messengerKey.currentState?.clearSnackBars();
        final snackBarController = _messengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('${result.name} removed from watchlist'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                notifier.addMovie(
                  movieName: result.name,
                  directorName: result.director,
                  genre: result.genre,
                  imagePath: result.imageUrl,
                  createdAt: result.createdOn,
                  updatedAt: result.updatedOn,
                );
              },
            ),
            duration: const Duration(seconds: 4),
          ),
        );
        // Manually dismiss snackbar after 2 seconds (snackbars with actions don't auto-dismiss)
        Future.delayed(const Duration(seconds: 2), () {
          try {
            snackBarController?.close();
          } catch (_) {
            // Snackbar was already dismissed (e.g., via Undo action)
          }
        });
      }
    });
  }
}

/// Stateful wrapper that fetches TMDB data and builds a [MovieDetailSheet].
class _WatchlistSheetContent extends ConsumerStatefulWidget {
  final Movie movie;
  const _WatchlistSheetContent({required this.movie});

  @override
  ConsumerState<_WatchlistSheetContent> createState() =>
      _WatchlistSheetContentState();
}

class _WatchlistSheetContentState
    extends ConsumerState<_WatchlistSheetContent> {
  String _year = '';
  double _rating = 0;
  String _overview = '';
  bool _loadingTmdb = true;

  @override
  void initState() {
    super.initState();
    _fetchTmdbInfo();
  }

  Future<void> _fetchTmdbInfo() async {
    try {
      final tmdb = ref.read(tmdbRepositoryProvider);
      final results = await tmdb.searchMovies(widget.movie.name, page: 1);
      if (results.isNotEmpty && mounted) {
        final match = results.first;
        setState(() {
          _year = match.year;
          _rating = match.voteAverage;
          _overview = match.overview ?? '';
          _loadingTmdb = false;
        });
      } else if (mounted) {
        setState(() => _loadingTmdb = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingTmdb = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final movie = widget.movie;

    return MovieDetailSheet(
      title: movie.name,
      posterUrl: movie.imageUrl,
      year: _year,
      rating: _rating,
      genre: movie.genre,
      director: movie.director,
      overview: _overview,
      isLoading: _loadingTmdb,
      subtitle: movie.createdOn.isNotEmpty
          ? 'Added on  ${DateFormat('dd MMM yyyy').format(DateTime.parse(movie.createdOn))}'
          : null,
      actionButtons: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  PageTransition(
                    child: AddMovieScreen(movie: movie),
                    type: PageTransitionType.rightToLeft,
                  ),
                );
              },
              icon: const Icon(Icons.edit, size: 20),
              label: const Text('Edit', style: TextStyle(fontSize: 15)),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primary,
                side: BorderSide(color: colors.primary, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: () {
                final deletedMovie = movie;
                ref.read(dataProvider.notifier).deleteMovie(movie.name);
                Navigator.pop(context, deletedMovie);
              },
              icon: const Icon(Icons.delete_outline, size: 20),
              label: const Text('Remove', style: TextStyle(fontSize: 15)),
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
