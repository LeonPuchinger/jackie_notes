import 'dart:io';

import 'package:jackie_notes/data/document.dart';
import 'package:jackie_notes/data/state/app_bloc.dart';
import 'package:jackie_notes/data/state/bloc.dart';
import 'package:jackie_notes/data/services/filesystem.dart';
import 'package:jackie_notes/data/tool.dart';
import 'package:jackie_notes/util/cabinet.dart';
import 'package:rxdart/rxdart.dart';

class DocumentBloc extends Bloc {
  final AppBloc _appBloc;
  File _file;
  Document _document;
  RenderElement _current;
  final _tool = Cabinet<Tool>();

  final _documentController = BehaviorSubject<Document>();

  Stream<Document> get document => _documentController.stream;

  DocumentBloc(this._appBloc);

  _initPath(double x, double y) {
    final Pen pen = _tool.value;
    _current = new Path(
        [], pen.color, pen.width, Coord(x, y), Coord(x, y), Coord(x, y));
    _document.pages[0].elements.add(_current);
    _documentController.add(_document);
  }

  _drawPath(double x, double y) {
    final Path path = _current;
    path.points.add(Coord(x, y) - path.offset);
    if (x > path.end.x)
      path.end.x = x;
    else if (x < path.start.x) path.start.x = x;
    if (y > path.end.y)
      path.end.y = y;
    else if (y < path.start.y) path.start.y = y;
    _documentController.add(_document);
  }

  _erase(double x, double y) {
    remove(r) {
      _document.pages[0].elements.remove(r);
      _documentController.add(_document);
    }

    final Eraser e = _tool.value;
    for (final r in _document.pages[0].elements) {
      if (r.type == RenderType.path) {
        final boxMatchesX = x >= r.start.x - e.width && x <= r.end.x + e.width;
        final boxMatchesY = y >= r.start.y - e.width && y <= r.end.y + e.width;
        if (boxMatchesX && boxMatchesY) {
          final relative = Coord(x, y) - (r as Path).offset;
          if ((r as Path).points.isEmpty) return remove(r);
          for (final c in (r as Path).points) {
            if ((c.x - relative.x).abs() < e.width &&
                (c.y - relative.y).abs() < e.width) {
              return remove(r);
            }
          }
        }
      }
    }
  }

  panStart(double x, double y) {
    final tool = _tool.relock();
    if (tool != null) {
      switch (tool.type) {
        case ToolType.pen:
          _initPath(x, y);
          break;
        case ToolType.eraser:
          _erase(x, y);
          break;
      }
    }
  }

  panUpdate(double x, double y) {
    final tool = _tool.value;
    if (tool != null) {
      switch (tool.type) {
        case ToolType.pen:
          _drawPath(x, y);
          break;
        case ToolType.eraser:
          _erase(x, y);
          break;
      }
    }
  }

  @override
  void dispose() {
    _documentController.close();
  }

  @override
  void init() {
    //TODO: find better way for appbloc to tell document_bloc which note to use (esp. for multiple document_blocs)
    _appBloc.edit.listen((note) async {
      _file = File(note.path);
      _document = await readJvg(_file);
      _documentController.add(_document);
    });
    _appBloc.tool.listen((tool) => _tool.value = tool);
    document
        .debounceTime(Duration(seconds: 1))
        .listen((document) => writeJvg(document, _file));
  }
}
