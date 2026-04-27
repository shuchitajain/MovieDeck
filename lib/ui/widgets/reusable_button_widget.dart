import 'package:flutter/material.dart';

Widget submitButton(
    {required BuildContext context,
    required String text,
    required Function() onTap,
    bool enabled = true,
    List<Color>? gradientColors}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final rawColors =
      gradientColors ?? const [Color(0xfffbb448), Color(0xfff7892b)];
  // Ensure button colors are dark enough for white text contrast
  final btnColors = rawColors.map((c) {
    final lum = c.computeLuminance();
    return lum > 0.5
        ? Color.alphaBlend(Colors.black.withValues(alpha: 0.2), c)
        : c;
  }).toList();
  final shadowColor =
      isDark ? btnColors.last.withValues(alpha: 0.3) : Colors.grey.shade200;
  return InkWell(
    onTap: enabled ? onTap : null,
    child: Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: shadowColor,
                  offset: const Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: btnColors)),
        child: Text(
          text,
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    ),
  );
}
