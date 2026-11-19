import 'package:flutter/material.dart';

/// Flag of a language, from `assets/images/flags/<CODE>.png`.
class LanguageImage extends StatelessWidget {
  const LanguageImage({super.key, required this.lang, this.width = 28});

  final String lang;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SizedBox(
        width: width,
        child: Image.asset(
          'assets/images/flags/${lang.toUpperCase()}.png',
          // Missing flag: show nothing instead of an error.
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
