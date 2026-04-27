import 'package:flutter/foundation.dart';

/// AI recommendation — immutable.
@immutable
class Recommendation {
  final String title;
  final String genre;
  final String year;
  final String reason;
  final String director;
  final String posterUrl;

  const Recommendation({
    required this.title,
    required this.genre,
    required this.year,
    required this.reason,
    this.director = 'Unknown',
    this.posterUrl = '',
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      title: json['title'] ?? '',
      genre: json['genre'] ?? '',
      year: json['year']?.toString() ?? '',
      reason: json['reason'] ?? '',
      director: json['director'] ?? 'Unknown',
    );
  }

  Recommendation copyWith({String? posterUrl}) {
    return Recommendation(
      title: title,
      genre: genre,
      year: year,
      reason: reason,
      director: director,
      posterUrl: posterUrl ?? this.posterUrl,
    );
  }
}
