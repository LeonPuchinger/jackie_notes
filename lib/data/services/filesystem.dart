import 'dart:async';
import 'dart:io' as io;

import 'package:jackie_notes/data/note.dart';

const root = String.fromEnvironment("jackie_root_path");

Future<List<NoteEntity>> listDirectory(io.Directory dir) async {
  final entities = dir.listSync(recursive: false, followLinks: false);
  return entities.map((e) {
    final type = e.toString().split(":")[0];
    if (type == "File") {
      return Note(e.path.split("/").last, e.path);
    }
    if (type == "Directory") {
      return Directory(e.path.split("/").last, e.path);
    }
  }).toList();
}
