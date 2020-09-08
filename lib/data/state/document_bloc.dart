import 'package:jackie_notes/data/document.dart';
import 'package:jackie_notes/data/state/app_bloc.dart';
import 'package:jackie_notes/data/state/bloc.dart';
import 'package:jackie_notes/data/services/filesystem.dart';
import 'package:rxdart/subjects.dart';

class DocumentBloc extends Bloc {
  final AppBloc appBloc;

  final _documentController = BehaviorSubject<Document>();

  Stream<Document> get document => _documentController.stream;

  DocumentBloc(this.appBloc);

  @override
  void dispose() {
    _documentController.close();
  }

  @override
  void init() {
    //TODO: find better way for appbloc to tell document_bloc which note to use (esp. for multiple document_blocs)
    appBloc.edit.listen((note) async {
      final doc = readMockFile();
      _documentController.add(doc);
    });
  }
}
