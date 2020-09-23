import 'package:flutter/rendering.dart' show Color;

enum ToolType { pen, eraser }

abstract class Tool {
  double width;

  ToolType get type;
}

class Pen extends Tool {
  Color color;

  Pen(this.color);

  ToolType get type => ToolType.pen;
}

class Eraser extends Tool {
  ToolType get type => ToolType.eraser;
}
