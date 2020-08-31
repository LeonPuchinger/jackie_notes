import 'package:jackie_notes/data/note.dart';
import 'package:jackie_notes/data/state/bloc.dart';
import 'package:rxdart/subjects.dart';

class AppBloc extends Bloc {
  final _editController = BehaviorSubject<Note>();

  Stream<Note> get edit => _editController.stream;

  Function(Note) get addEdit => _editController.add;

  @override
  void dispose() {
    _editController.close();
  }

  @override
  void init() {
    // TODO: implement init
  }
}
