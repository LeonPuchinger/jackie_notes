import 'package:flutter/rendering.dart' show Color;

class Document {
  final List<Page> pages = [];
}

class Page {
  final List<RenderElement> elements = [];
}

enum RenderType { path, text }

abstract class RenderElement {
  final Coord offset;

  RenderElement(this.offset);

  RenderType get type;
}

class Path extends RenderElement {
  final List<Coord> points;
  final Color color;

  Path(this.points, this.color, Coord offset) : super(offset);

  RenderType get type => RenderType.path;

  String get contents {
    final buffer = StringBuffer()..writeAll(points, " ");
    return buffer.toString();
  }
}

class Text extends RenderElement {
  final String text;
  final Color color;
  final double fontSize, width;

  Text(
    this.text,
    this.color,
    this.fontSize,
    this.width,
    Coord offset,
  ) : super(offset);

  RenderType get type => RenderType.text;
}

class Coord {
  final double x, y;

  Coord(this.x, this.y);

  @override
  String toString() => "$x $y";
}
