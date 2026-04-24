import 'package:flutter/material.dart';

class ColorUtils {
  /// Parses a hex color string (e.g., "#FF5733" or "FF5733") into a Flutter [Color].
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
