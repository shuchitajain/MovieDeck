import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movie_deck/constants.dart';
import 'package:movie_deck/domain/entities/movie.dart';
import 'package:movie_deck/providers/providers.dart';
import 'package:movie_deck/ui/config.dart';
import 'package:movie_deck/ui/widgets/back_button_widget.dart';
import 'package:movie_deck/ui/widgets/form_field_widget.dart';
import 'package:movie_deck/ui/widgets/reusable_button_widget.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../domain/utils/genre_utils.dart';

class AddMovieScreen extends ConsumerStatefulWidget {
  final Movie? movie;
  const AddMovieScreen({Key? key, this.movie}) : super(key: key);

  @override
  ConsumerState<AddMovieScreen> createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends ConsumerState<AddMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _movieNameController;
  late TextEditingController _directorNameController;
  File? _moviePoster;
  String? _creation;
  String _selectedGenre = '';
  String _networkPosterUrl = '';
  bool _isMovieNameValid = false;

  // Original values for change detection (edit mode)
  String _originalName = '';
  String _originalDirector = '';
  String _originalGenre = '';
  String _originalPosterPath = '';

  // Poster palette colors for edit mode gradient
  List<Color> _paletteColors = [];
  Color? _paletteDominant;
  Color? _paletteVibrant;

  bool get _isEditing => widget.movie != null;

  bool get _hasChanges {
    if (!_isEditing) return true;
    final currentPoster = _moviePoster?.path ?? _networkPosterUrl;
    return _movieNameController.text.trim() != _originalName ||
        _directorNameController.text.trim() != _originalDirector ||
        _selectedGenre != _originalGenre ||
        currentPoster != _originalPosterPath;
  }

  Future<void> add({
    required String name,
    required String director,
    required String genre,
    required String poster,
    required String createdAt,
    required String updatedAt,
  }) async {
    ref.read(dataProvider.notifier).addMovie(
          movieName: name,
          directorName: director,
          genre: genre,
          imagePath: poster,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
    ref.read(dataProvider.notifier).filterItems("");
    Navigator.of(context).pop();
  }

  /// Get from gallery
  Future<File?> _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        _moviePoster = File(pickedFile.path);
      });
      return _moviePoster;
    }
    return null;
  }

  /// Get from Camera
  Future<File?> _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        _moviePoster = File(pickedFile.path);
      });
      return _moviePoster;
    }
    return null;
  }

  void _showBottomSheetMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (builder) {
        final colors = Theme.of(context).colorScheme;
        return Container(
          height: (_moviePoster != null || _networkPosterUrl.isNotEmpty)
              ? 250
              : 200,
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 5,
                  width: 40,
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: Text("Change Movie Poster",
                    style: GoogleFonts.lato(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Divider(color: colors.outline, thickness: 2),
              const SizedBox(height: 10),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: InkWell(
                  onTap: () => _getFromGallery()
                      .whenComplete(() => Navigator.pop(context)),
                  child: Text("Choose from gallery",
                      style: GoogleFonts.lato(fontSize: 20)),
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: InkWell(
                  onTap: () => _getFromCamera()
                      .whenComplete(() => Navigator.pop(context)),
                  child: Text("Click from camera",
                      style: GoogleFonts.lato(fontSize: 20)),
                ),
              ),
              if (_moviePoster != null || _networkPosterUrl.isNotEmpty) ...[
                const SizedBox(height: 5),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _moviePoster = null;
                        _networkPosterUrl = '';
                      });
                      Navigator.pop(context);
                    },
                    child: Text("Remove poster",
                        style:
                            GoogleFonts.lato(fontSize: 20, color: Colors.red)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  showErrorDialog() {
    final colors = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            const FaIcon(FontAwesomeIcons.circleExclamation, color: Colors.red),
            const SizedBox(width: 10),
            Text('Sorry', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          height: 50,
          child: Center(
            child: Text('Please upload a movie poster!',
                style: TextStyle(color: colors.onSurface, fontSize: 18)),
          ),
        ),
        actions: [
          TextButton(
            child: Text('OK',
                style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.movie != null) {
      _movieNameController = TextEditingController(text: widget.movie!.name);
      _directorNameController =
          TextEditingController(text: widget.movie!.director);
      final url = widget.movie!.imageUrl;
      if (url.startsWith('http://') || url.startsWith('https://')) {
        _networkPosterUrl = url;
      } else if (url.isNotEmpty && File(url).existsSync()) {
        _moviePoster = File(url);
      }
      _creation = widget.movie!.createdOn;
      _selectedGenre = widget.movie!.genre;
      if (_selectedGenre.isNotEmpty && !kGenres.contains(_selectedGenre)) {
        _selectedGenre = normalizeGenre(_selectedGenre);
      }
      _isMovieNameValid = widget.movie!.name.trim().isNotEmpty;
      _originalName = widget.movie!.name;
      _originalDirector = widget.movie!.director;
      _originalGenre = _selectedGenre;
      _originalPosterPath = _moviePoster?.path ?? _networkPosterUrl;
    } else {
      _movieNameController = TextEditingController();
      _directorNameController = TextEditingController();
    }
    _movieNameController.addListener(_onFieldChanged);
    _directorNameController.addListener(_onFieldChanged);

    if (_isEditing) _extractPalette();
  }

  Future<void> _extractPalette() async {
    try {
      ImageProvider imageProvider;
      if (_moviePoster != null) {
        imageProvider = FileImage(_moviePoster!);
      } else if (_networkPosterUrl.isNotEmpty) {
        imageProvider = NetworkImage(_networkPosterUrl);
      } else {
        return;
      }
      final palette = await PaletteGenerator.fromImageProvider(
        imageProvider,
        maximumColorCount: 6,
      );
      if (!mounted) return;
      setState(() {
        final dominant = palette.dominantColor?.color ?? Colors.transparent;
        final muted = palette.mutedColor?.color ??
            palette.lightMutedColor?.color ??
            dominant;
        final vibrant = palette.vibrantColor?.color ??
            palette.lightVibrantColor?.color ??
            dominant;
        _paletteDominant = dominant;
        _paletteVibrant = vibrant;
        _paletteColors = [
          dominant.withValues(alpha: 0.25),
          muted.withValues(alpha: 0.15),
          vibrant.withValues(alpha: 0.08),
          Colors.transparent,
        ];
      });
    } catch (_) {}
  }

  void _onFieldChanged() {
    final valid = _movieNameController.text.trim().isNotEmpty;
    if (valid != _isMovieNameValid) {
      setState(() => _isMovieNameValid = valid);
    } else {
      // Trigger rebuild to re-evaluate _hasChanges
      setState(() {});
    }
  }

  @override
  void dispose() {
    _movieNameController.removeListener(_onFieldChanged);
    _directorNameController.removeListener(_onFieldChanged);
    _movieNameController.dispose();
    _directorNameController.dispose();
    super.dispose();
  }

  Widget _buildPerforations(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          8,
          (_) => Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        ref.read(dataProvider.notifier).filterItems("");
      },
      child: Scaffold(
        body: Container(
          decoration: _isEditing && _paletteColors.isNotEmpty
              ? BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: _paletteColors,
                  ),
                )
              : null,
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: SizedBox(
                width: App.width(context),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            backButton(context),
                            const Spacer(flex: 1),
                            Text(_isEditing ? "Edit movie" : "Add a movie",
                                style: GoogleFonts.ubuntu(
                                    fontSize: 30, fontWeight: FontWeight.bold)),
                            const Spacer(flex: 2),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => _showBottomSheetMenu(),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Ticket-shaped poster
                              ClipPath(
                                clipper: _TicketClipper(),
                                child: Container(
                                  height: App.height(context) / 3.2,
                                  width: App.width(context) / 1.8,
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainerHighest,
                                  ),
                                  child: _moviePoster != null
                                      ? Image.file(_moviePoster!,
                                          fit: BoxFit.cover)
                                      : _networkPosterUrl.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: _networkPosterUrl,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                FaIcon(FontAwesomeIcons.camera,
                                                    size: 36,
                                                    color: colors.onSurface
                                                        .withValues(
                                                            alpha: 0.5)),
                                                const SizedBox(height: 12),
                                                Text("Tap to add poster",
                                                    style: TextStyle(
                                                        color: colors.onSurface
                                                            .withValues(
                                                                alpha: 0.4),
                                                        fontSize: 13)),
                                              ],
                                            ),
                                ),
                              ),
                              // Film perforations overlay (left + right)
                              SizedBox(
                                height: App.height(context) / 3.2,
                                width: App.width(context) / 1.8,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildPerforations(colors),
                                    _buildPerforations(colors),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      formFieldWidget(
                        context: context,
                        title: "Movie name",
                        controller: _movieNameController,
                        validator: (value) => (value!.isEmpty)
                            ? "Movie name can't be empty"
                            : null,
                        prefixIcon: FaIcon(FontAwesomeIcons.film),
                        accentColor: _paletteDominant,
                        onTap: () {},
                      ),
                      formFieldWidget(
                        context: context,
                        title: "Director name (optional)",
                        controller: _directorNameController,
                        prefixIcon: FaIcon(FontAwesomeIcons.user),
                        accentColor: _paletteDominant,
                        onTap: () {},
                      ),
                      // Genre dropdown
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Genre (optional)",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: colors.onSurface)),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedGenre.isEmpty ||
                                      !kGenres.contains(_selectedGenre)
                                  ? null
                                  : _selectedGenre,
                              dropdownColor: colors.surface,
                              iconEnabledColor: colors.onSurface,
                              style: TextStyle(
                                  color: colors.onSurface, fontSize: 16),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                fillColor: _paletteDominant != null
                                    ? Color.alphaBlend(
                                        _paletteDominant!
                                            .withValues(alpha: 0.18),
                                        colors.surfaceContainerHighest,
                                      )
                                    : colors.surfaceContainerHighest,
                                filled: true,
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12, right: 10),
                                  child: FaIcon(FontAwesomeIcons.masksTheater,
                                      color: _paletteDominant?.withValues(
                                              alpha: 0.7) ??
                                          colors.onSurface
                                              .withValues(alpha: 0.6)),
                                ),
                                prefixIconConstraints: const BoxConstraints(
                                    minWidth: 0, minHeight: 0),
                                contentPadding: const EdgeInsets.only(
                                    left: 8, top: 14, bottom: 8, right: 12),
                              ),
                              hint: Text("Select a genre",
                                  style: TextStyle(
                                      color: colors.onSurface
                                          .withValues(alpha: 0.4))),
                              items: kGenres.map((genre) {
                                return DropdownMenuItem(
                                    value: genre, child: Text(genre));
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedGenre = value ?? '';
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: submitButton(
                          context: context,
                          text: _isEditing ? "Update" : "Submit",
                          enabled: _isMovieNameValid &&
                              (_isEditing ? _hasChanges : true),
                          gradientColors: _paletteDominant != null &&
                                  _paletteVibrant != null
                              ? [_paletteDominant!, _paletteVibrant!]
                              : null,
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              final posterPath =
                                  _moviePoster?.path ?? _networkPosterUrl;
                              add(
                                name: _movieNameController.text.trim(),
                                director:
                                    _directorNameController.text.trim().isEmpty
                                        ? 'Unknown'
                                        : _directorNameController.text.trim(),
                                genre: _selectedGenre.isEmpty
                                    ? 'Other'
                                    : _selectedGenre,
                                poster: posterPath,
                                createdAt:
                                    _creation ?? DateTime.now().toString(),
                                updatedAt: DateTime.now().toString(),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Film-strip shaped clipper with rounded corners and side notches.
class _TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const radius = 12.0;
    const notchRadius = 14.0;

    final path = Path();

    // Top-left corner
    path.moveTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    // Top edge
    path.lineTo(size.width - radius, 0);

    // Top-right corner
    path.quadraticBezierTo(size.width, 0, size.width, radius);

    // Right edge with center notch
    path.lineTo(size.width, size.height / 2 - notchRadius);
    path.arcToPoint(
      Offset(size.width, size.height / 2 + notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );

    // Bottom-right corner
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(
        size.width, size.height, size.width - radius, size.height);

    // Bottom edge
    path.lineTo(radius, size.height);

    // Bottom-left corner
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);

    // Left edge with center notch
    path.lineTo(0, size.height / 2 + notchRadius);
    path.arcToPoint(
      Offset(0, size.height / 2 - notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
