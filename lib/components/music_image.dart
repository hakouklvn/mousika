import 'dart:typed_data' as td;

import 'package:flutter/material.dart';
import 'package:mousika/config/config.dart';

class MusicImage extends StatelessWidget {
  const MusicImage({super.key, required this.image});
  final td.Uint8List image;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: MemoryImage(image),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(Sizes.defaultPadding * 0.5),
      ),
    );
  }
}
