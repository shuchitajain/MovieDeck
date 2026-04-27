import 'package:flutter/material.dart';

Widget formFieldWidget({
  required BuildContext context,
  required String title,
  required TextEditingController controller,
  TextInputType keyboard = TextInputType.text,
  FormFieldValidator<String>? validator,
  required Function onTap,
  required Widget prefixIcon,
  bool obscure = false,
  Color? accentColor,
}) {
  final colors = Theme.of(context).colorScheme;
  final fill = accentColor != null
      ? Color.alphaBlend(
          accentColor.withValues(alpha: 0.18),
          colors.surfaceContainerHighest,
        )
      : colors.surfaceContainerHighest;
  final focusBorder = accentColor ?? colors.primary;
  final iconColor = accentColor?.withValues(alpha: 0.7) ??
      colors.onSurface.withValues(alpha: 0.6);
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colors.onSurface),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscure,
          onTap: () => onTap(),
          keyboardType: keyboard,
          textCapitalization: TextCapitalization.words,
          maxLines: 1,
          style: TextStyle(color: colors.onSurface),
          decoration: InputDecoration(
            border: InputBorder.none,
            fillColor: fill,
            hintText: title.startsWith("Movie name")
                ? "Sherlock Holmes"
                : title.startsWith("Director name")
                    ? "Guy Ritchie"
                    : "Detective Sherlock Holmes...",
            hintStyle:
                TextStyle(color: colors.onSurface.withValues(alpha: 0.4)),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 10),
              child: IconTheme(
                data: IconThemeData(color: iconColor),
                child: prefixIcon,
              ),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            errorStyle: const TextStyle(fontSize: 14),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(width: 2.0, color: focusBorder),
            ),
          ),
        ),
      ],
    ),
  );
}
