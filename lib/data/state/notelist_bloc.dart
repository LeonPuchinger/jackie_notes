import 'dart:async';
import 'dart:io' as io;

import 'package:jackie_notes/data/note.dart';
import 'package:jackie_notes/data/services/filesystem.dart';
import 'package:jackie_notes/data/state/app_bloc.dart';
import 'package:jackie_notes/data/state/bloc.dart';
import 'package:rxdart/rxdart.dart';

class NoteListBloc extends Bloc {
  final AppBloc appBloc;
  final _dirStack = [Directory("Files", root, true)];

  final _entityController = BehaviorSubject<List<NoteEntity>>();
  final _currentDirectory = BehaviorSubject<Directory>();

  Stream<List<NoteEntity>> get entities => _entityController.stream;
  Stream<Directory> get currentDirectory => _currentDirectory.stream;

  NoteListBloc(this.appBloc);

  selectEntity(int index) async {
    final entity = _entityController.value[index];
    if (entity.type == EntityType.dir) {
      _entityController.add(await listDirectory(io.Directory(entity.path)));
      _dirStack.add(entity);
      _currentDirectory.add(entity);
    } else {
      appBloc.addEdit(entity);
    }
  }

  moveToParent() async {
    _dirStack.removeLast();
    final parent = _dirStack.last;
    _currentDirectory.add(parent);
    _entityController.add(await listDirectory(io.Directory(parent.path)));
  }

  @override
  void init() async {
    _entityController.add(await listDirectory(io.Directory(root)));
  }

  @override
  void dispose() async {
    _entityController.close();
    _currentDirectory.close();
  }
}
