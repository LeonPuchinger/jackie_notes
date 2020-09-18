class Document {
  final List<Page> pages = [];
}

class Page {
  final List<RenderElement> elements = [];
}

enum RenderType { path }

abstract class RenderElement {
  final Coord offset;

  RenderElement(this.offset);

  RenderType get type;

  String get contents;
}

class Path extends RenderElement {
  final List<Coord> points;

  Path(this.points, Coord offset) : super(offset);

  RenderType get type => RenderType.path;

  String get contents {
    final buffer = StringBuffer()..writeAll(points, " ");
    return buffer.toString();
  }
}

class Coord {
  final double x, y;

  Coord(this.x, this.y);

  @override
  String toString() => "$x $y";
}
