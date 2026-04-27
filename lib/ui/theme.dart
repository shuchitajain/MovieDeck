import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_deck/constants.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorSchemeSeed: kPrimaryColor,
  brightness: Brightness.light,
  fontFamily: GoogleFonts.lato().fontFamily,
  scaffoldBackgroundColor: const Color(0xFFF9F9F9), // subtle cool grey
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorSchemeSeed: kPrimaryColor,
  brightness: Brightness.dark,
  fontFamily: GoogleFonts.lato().fontFamily,
);
