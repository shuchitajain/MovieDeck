import 'package:flutter/foundation.dart';

/// Core movie entity — immutable, used across all layers.
@immutable
class Movie {
  final String name;
  final String director;
  final String genre;
  final String imageUrl;
  final String createdOn;
  final String updatedOn;

  const Movie({
    this.name = '',
    this.director = '',
    this.genre = '',
    this.imageUrl = '',
    this.createdOn = '',
    this.updatedOn = '',
  });

  Movie copyWith({
    String? name,
    String? director,
    String? genre,
    String? imageUrl,
    String? createdOn,
    String? updatedOn,
  }) {
    return Movie(
      name: name ?? this.name,
      director: director ?? this.director,
      genre: genre ?? this.genre,
      imageUrl: imageUrl ?? this.imageUrl,
      createdOn: createdOn ?? this.createdOn,
      updatedOn: updatedOn ?? this.updatedOn,
    );
  }

  factory Movie.fromMap(Map<dynamic, dynamic> map) {
    return Movie(
      name: map['name'] ?? '',
      director: map['director'] ?? '',
      genre: map['genre'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdOn: map['createdOn'] ?? '',
      updatedOn: map['updatedOn'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'director': director,
      'genre': genre,
      'imageUrl': imageUrl,
      'createdOn': createdOn,
      'updatedOn': updatedOn,
    };
  }

  @override
  String toString() => '$name ($genre) - directed by $director';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Movie &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          createdOn == other.createdOn;

  @override
  int get hashCode => name.hashCode ^ createdOn.hashCode;
}
