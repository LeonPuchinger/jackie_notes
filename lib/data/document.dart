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
}

class Path extends RenderElement {
  final List<Coord> points;

  Path(this.points, Coord offset) : super(offset);

  RenderType get type => RenderType.path;
}

class Coord {
  final double x, y;

  Coord(this.x, this.y);
}
