import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xffe46b10);
const Color kWhiteColor = Colors.white;
const Color kGreyColor = Colors.grey;
const Color kBlackColor = Colors.black;

const List<String> kGenres = [
  'Action',
  'Adventure',
  'Animation',
  'Comedy',
  'Crime',
  'Documentary',
  'Drama',
  'Family',
  'Fantasy',
  'History',
  'Horror',
  'Music',
  'Mystery',
  'Romance',
  'Sci-Fi',
  'Thriller',
  'War',
  'Western',
  'Other',
];

/// Maps TMDB / Gemini genre names to kGenres values
const Map<String, String> kGenreAliases = {
  'Science Fiction': 'Sci-Fi',
  'Musical': 'Music',
  'TV Movie': 'Other',
};
