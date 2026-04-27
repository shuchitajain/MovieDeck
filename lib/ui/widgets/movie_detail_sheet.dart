import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable draggable bottom sheet for movie details.
///
/// Used by both the watchlist (home) and discover screens.
class MovieDetailSheet extends StatelessWidget {
  final String title;
  final String posterUrl;
  final String year;
  final double rating;
  final String genre;
  final String director;
  final String overview;
  final bool isLoading;
  final String? subtitle; // e.g. "Added on 12 Jan 2025"
  final Widget actionButtons;

  const MovieDetailSheet({
    super.key,
    required this.title,
    required this.posterUrl,
    this.year = '',
    this.rating = 0,
    this.genre = '',
    this.director = '',
    this.overview = '',
    this.isLoading = false,
    this.subtitle,
    required this.actionButtons,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster + overlays
                  Stack(
                    children: [
                      _buildPoster(colors),
                      // Drag handle
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 12),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // Gradient fade
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 120,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, colors.surface],
                            ),
                          ),
                        ),
                      ),
                      // Title
                      Positioned(
                        bottom: 16,
                        left: 20,
                        right: 20,
                        child: Text(
                          title,
                          style: GoogleFonts.ubuntu(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Close button
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.surface.withValues(alpha: 0.8),
                            ),
                            child: Icon(Icons.close,
                                size: 22, color: colors.onSurface),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Info chips
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        if (year.isNotEmpty)
                          _infoChip(Icons.calendar_today, year, colors),
                        if (rating > 0)
                          _infoChip(
                            Icons.star,
                            rating.toStringAsFixed(1),
                            colors,
                            iconColor: Colors.amber,
                          ),
                        if (genre.isNotEmpty)
                          _infoChip(Icons.movie_filter, genre, colors),
                        if (isLoading)
                          _infoChip(Icons.hourglass_top, 'Loading...', colors),
                      ],
                    ),
                  ),

                  // Director
                  if (director.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 4),
                      child: RichText(
                        text: TextSpan(
                          text: 'Directed by  ',
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            color: colors.outline,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: director,
                              style: GoogleFonts.lato(
                                fontSize: 15,
                                color: colors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Overview
                  if (overview.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Text(
                        'Overview',
                        style: GoogleFonts.ubuntu(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (overview.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        overview,
                        style: GoogleFonts.lato(
                          fontSize: 14.5,
                          height: 1.5,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),

                  // Subtitle (e.g. "Added on ...")
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Text(
                        subtitle!,
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          color: colors.outline,
                        ),
                      ),
                    ),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    child: actionButtons,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPoster(ColorScheme colors) {
    const borderRadius = BorderRadius.vertical(top: Radius.circular(24));
    if (posterUrl.startsWith('http://') || posterUrl.startsWith('https://')) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: CachedNetworkImage(
          imageUrl: posterUrl,
          width: double.infinity,
          height: 400,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      );
    }
    if (posterUrl.isNotEmpty && File(posterUrl).existsSync()) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.file(
          File(posterUrl),
          width: double.infinity,
          height: 400,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      );
    }
    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryContainer, colors.tertiaryContainer],
        ),
      ),
      child: Center(
        child: FaIcon(FontAwesomeIcons.film,
            size: 64, color: colors.onPrimaryContainer.withValues(alpha: 0.5)),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, ColorScheme colors,
      {Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: iconColor ?? colors.outline),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a [MovieDetailSheet] in a modal bottom sheet with standard config.
  /// Returns a [Future] that completes with an optional result when closed.
  static Future<T?> show<T>(BuildContext context, {required Widget child}) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => GestureDetector(
        onTap: () => Navigator.pop(context),
        behavior: HitTestBehavior.opaque,
        child: GestureDetector(
          onTap: () {},
          child: child,
        ),
      ),
    );
  }
}
