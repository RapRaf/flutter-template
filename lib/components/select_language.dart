import 'package:flutter/material.dart';

class LanguageImage extends StatefulWidget {
  const LanguageImage({super.key, required this.lang});
  final String lang;

  @override
  State<LanguageImage> createState() => _LanguageImageState();
}

class _LanguageImageState extends State<LanguageImage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: SizedBox(
          width: 37,
          child: Image.asset(
              'assets/images/flags/${widget.lang.toUpperCase()}.png')),
    );
  }
}
