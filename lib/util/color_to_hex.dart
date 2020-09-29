import 'package:flutter/rendering.dart' show Color;

extension ToHexString on Color {
  String get hexString => value.toRadixString(16).padLeft(8, '0');
}