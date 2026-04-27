import '../../constants.dart';

/// Normalize any genre string to match kGenres. DRY: shared across layers.
String normalizeGenre(String raw) {
  if (raw.isEmpty) return 'Other';
  if (kGenreAliases.containsKey(raw)) return kGenreAliases[raw]!;
  if (kGenres.contains(raw)) return raw;
  for (final g in kGenres) {
    if (g.toLowerCase() == raw.toLowerCase()) return g;
  }
  return 'Other';
}
