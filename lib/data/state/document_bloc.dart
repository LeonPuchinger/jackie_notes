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
  int _currentPage;
  final _tool = Cabinet<Tool>();

  final _documentController = BehaviorSubject<Document>();

  Stream<Document> get document => _documentController.stream;

  DocumentBloc(this._appBloc);

  _pageOffset(double y) {
    final pagestart = _currentPage * _document.pageHeight;
    return y - pagestart;
  }

  _updateCurrentPage(double y) => _currentPage = y ~/ _document.pageHeight;

  _initPath(double x, double y) {
    final Pen pen = _tool.value;
    _updateCurrentPage(y);
    final pageoffset = _pageOffset(y);
    _current = new Path([], pen.color, pen.width, Coord(x, pageoffset),
        Coord(x, pageoffset), Coord(x, pageoffset));
    _document.accessPage(_currentPage).elements.add(_current);
    _documentController.add(_document);
  }

  _drawPath(double x, double y) {
    final Path path = _current;
    final pageOffset = _pageOffset(y);
    path.points.add(Coord(x, pageOffset) - path.offset);
    if (x > path.end.x)
      path.end.x = x;
    else if (x < path.start.x) path.start.x = x;
    if (pageOffset > path.end.y)
      path.end.y = pageOffset;
    else if (pageOffset < path.start.y) path.start.y = pageOffset;
    _documentController.add(_document);
  }

  //TODO: add ability to erase elements overlapping onto current page
  _erase(double x, double y) {
    remove(r) {
      _document.pages[_currentPage].elements.remove(r);
      _documentController.add(_document);
    }

    final Eraser e = _tool.value;
    _updateCurrentPage(y);
    final pageOffset = _pageOffset(y);
    for (final r in _document.pages[_currentPage].elements) {
      if (r.type == RenderType.path) {
        final boxMatchesX = x >= r.start.x - e.width && x <= r.end.x + e.width;
        final boxMatchesY = pageOffset >= r.start.y - e.width &&
            pageOffset <= r.end.y + e.width;
        if (boxMatchesX && boxMatchesY) {
          final relative = Coord(x, pageOffset) - (r as Path).offset;
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
