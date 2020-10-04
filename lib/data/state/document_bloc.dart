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

  panStart(double x, double y) {
    final tool = _tool.relock();
    if (tool != null) {
      switch (tool.type) {
        case ToolType.pen:
          final Pen pen = tool;
          _current =
              new Path([], pen.color, Coord(x, y), Coord(x, y), Coord(x, y));
          _document.pages[0].elements.add(_current);
          break;
        case ToolType.eraser:
          break;
      }
    }
  }

  panUpdate(double x, double y, double dx, double dy) {
    final tool = _tool.value;
    if (tool != null) {
      switch (tool.type) {
        case ToolType.pen:
          final Path path = _current;
          path.points.add(Coord(dx, dy));
          if (x > path.end.x)
            path.end.x = x;
          else if (x < path.start.x) path.start.x = x;
          if (y > path.end.y)
            path.end.y = y;
          else if (y < path.start.y) path.start.y = y;
          _documentController.add(_document);
          break;
        case ToolType.eraser:
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
