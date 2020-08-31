import 'dart:async';
import 'dart:io' as io;

import 'package:jackie_notes/data/document.dart';
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

//mock file with a path displaying "J" for testing
readMockFile() {
  final doc = Document();
  doc.pages.add(Page()
    ..elements.add(Path(
      [
        Coord(50, 0),
        Coord(0, 100),
        Coord(-50, 0),
        Coord(0, -30),
        Coord(60, 0),
      ],
      Coord(10, 10),
    )));
  return doc;
}
