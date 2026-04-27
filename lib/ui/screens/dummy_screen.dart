import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

import '../widgets/back_button_widget.dart';
import 'signup_screen.dart';

class DummyScreen extends StatefulWidget {
  const DummyScreen({Key? key}) : super(key: key);

  @override
  State<DummyScreen> createState() => _DummyScreenState();
}

class _DummyScreenState extends State<DummyScreen> {
  void _showLoginDialog() {
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
            child: Text(
              'Please login or register to continue!',
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
            child: const Text(
              'Register / Login',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: NestedScrollView(
        headerSliverBuilder: (_, bool innerBoxIsScrolled) {
          return [
            SliverPadding(
              padding: const EdgeInsets.only(top: 24),
              sliver: SliverToBoxAdapter(
                child: Container(
                  height: 100,
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
                              'Welcome,',
                              style: GoogleFonts.ubuntu(
                                  fontSize: 36, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                text: "Guest! ",
                                style: GoogleFonts.openSans(
                                  fontSize: 17,
                                  color: colors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                                children: const [TextSpan(text: "👋")],
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
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 50,
                margin: const EdgeInsets.fromLTRB(20, 25, 20, 30),
                child: TextFormField(
                  enabled: false,
                  decoration: InputDecoration(
                    fillColor: colors.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 12),
                    hintText: "Search for any movie",
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
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'My Watchlist',
                        style: GoogleFonts.openSans(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.movie_filter,
                    size: 64, color: colors.primary.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text(
                  "Register or login to start building your movie watchlist and get AI-powered recommendations!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: 16, color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      PageTransition(
                        child: const SignupScreen(),
                        type: PageTransitionType.rightToLeft,
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Get Started'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        height: 60,
        width: 60,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () => _showLoginDialog(),
            elevation: 10,
            backgroundColor: colors.primary,
            child: Icon(Icons.add, color: colors.onPrimary),
          ),
        ),
      ),
    );
  }
}
