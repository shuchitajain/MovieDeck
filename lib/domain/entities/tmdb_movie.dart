import 'package:flutter/foundation.dart';

/// TMDB movie from API — immutable.
@immutable
class TMDBMovie {
  final int id;
  final String title;
  final String posterPath;
  final String releaseDate;
  final double voteAverage;
  final String? overview;

  const TMDBMovie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.releaseDate,
    required this.voteAverage,
    this.overview,
  });

  factory TMDBMovie.fromJson(Map<String, dynamic> json) {
    return TMDBMovie(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? 'Unknown',
      posterPath: json['poster_path'] ?? '',
      releaseDate: json['release_date'] ?? json['first_air_date'] ?? '',
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      overview: json['overview'],
    );
  }

  String get fullPosterUrl {
    if (posterPath.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  /// Smaller thumbnail for grid views — saves bandwidth + memory
  String get thumbnailUrl {
    if (posterPath.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/w200$posterPath';
  }

  String get year {
    if (releaseDate.isEmpty) return '';
    return releaseDate.split('-').first;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TMDBMovie && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
