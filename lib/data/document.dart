import 'package:flutter/rendering.dart' show Color;

class Document {
  final double pageHeight, pageMargin;
  final List<Page> pages = [];

  Document({this.pageHeight = 1000, this.pageMargin = 20});

  Page accessPage(int index) {
    if (index >= pages.length) {
      for (int i = index - pages.length; i >= 0; i--) {
        pages.add(Page());
      }
    }
    return pages[index];
  }
}

class Page {
  final List<RenderElement> elements = [];
}

enum RenderType { path, text }

abstract class RenderElement {
  final Coord start, end;

  RenderElement(this.start, this.end);

  RenderType get type;
}

class Path extends RenderElement {
  final Coord offset;
  final List<Coord> points;
  final Color color;
  final double width;

  Path(
    this.points,
    this.color,
    this.width,
    this.offset,
    Coord start,
    Coord end,
  ) : super(start, end);

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
    Coord start,
    Coord end,
  ) : super(start, end);

  RenderType get type => RenderType.text;
}

class Coord {
  double x, y;

  Coord(this.x, this.y);

  @override
  String toString() => "$x $y";

  Coord operator -(Coord c) => Coord(this.x - c.x, this.y - c.y);

  Coord operator +(Coord c) => Coord(this.x + c.x, this.y + c.y);
}
