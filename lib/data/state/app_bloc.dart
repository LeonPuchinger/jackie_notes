import 'package:jackie_notes/data/note.dart';
import 'package:jackie_notes/data/state/bloc.dart';
import 'package:jackie_notes/data/tool.dart';
import 'package:rxdart/subjects.dart';

class AppBloc extends Bloc {
  final _editController = BehaviorSubject<Note>();
  final _toolController = BehaviorSubject<Tool>();

  Stream<Note> get edit => _editController.stream;
  Stream<Tool> get tool => _toolController.stream;

  Function(Note) get addEdit => _editController.add;
  Function(Tool) get addTool => _toolController.add;

  @override
  void dispose() {
    _editController.close();
    _toolController.close();
  }

  @override
  void init() {}
}
