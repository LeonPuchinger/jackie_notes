import 'dart:io';

import 'package:jackie_notes/data/document.dart';
import 'package:jackie_notes/data/state/app_bloc.dart';
import 'package:jackie_notes/data/state/bloc.dart';
import 'package:jackie_notes/data/services/filesystem.dart';
import 'package:rxdart/rxdart.dart';

class DocumentBloc extends Bloc {
  final AppBloc _appBloc;
  File _file;
  Document _document;
  RenderElement _current;

  final _documentController = BehaviorSubject<Document>();

  Stream<Document> get document => _documentController.stream;

  DocumentBloc(this._appBloc);

  panStart(double x, double y) {
    _current = new Path([], Coord(x, y));
    _document.pages[0].elements.add(_current);
  }
  
  panUpdate(double x, double y) {
    (_current as Path).points.add(Coord(x, y));
    _documentController.add(_document);
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
      _document = readMockFile();
      _documentController.add(_document);
    });
    document.debounceTime(Duration(seconds: 2)).listen((document) => writeJvg(document, _file));
  }
}
