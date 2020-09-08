import 'dart:async';
import 'dart:io' as io;

import 'package:jackie_notes/data/document.dart';
import 'package:jackie_notes/data/note.dart';
import 'package:path_provider/path_provider.dart';

Future<io.Directory> get documentsDir async => getApplicationDocumentsDirectory();

Future<List<NoteEntity>> listDirectory(io.Directory dir) async {
  final List<NoteEntity> entities = [];
  for(final e in dir.listSync(recursive: false, followLinks: false)) {
    final type = e.toString().split(":")[0];
    if (type == "File") {
      entities.add(Note(e.path.split("/").last, e.path));
    }
    if (type == "Directory") {
      entities.add(Directory(e.path.split("/").last, e.path));
    }
  }
  return entities;
}

//mock file with a path displaying "J" for testing
readMockFile() {
  final doc = Document();
  doc.pages.add(Page());
  /* doc.pages.add(Page()
    ..elements.add(Path(
      [
        Coord(50, 0),
        Coord(0, 100),
        Coord(-50, 0),
        Coord(0, -30),
        Coord(60, 0),
      ],
      Coord(10, 10),
    ))); */
  return doc;
}
