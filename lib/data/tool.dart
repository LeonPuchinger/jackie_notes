import 'package:flutter/rendering.dart' show Color;

enum ToolType { pen, eraser }

abstract class Tool {
  double width;

  Tool(this.width);

  ToolType get type;
}

class Pen extends Tool {
  Color color;

  Pen(this.color, double width) : super(width);

  ToolType get type => ToolType.pen;
}

class Eraser extends Tool {
  Eraser(double width) : super(width);

  ToolType get type => ToolType.eraser;
}
