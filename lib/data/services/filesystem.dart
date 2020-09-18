import 'dart:async';
import 'dart:io' as io;

import 'package:jackie_notes/data/document.dart';
import 'package:jackie_notes/data/note.dart';
import 'package:jackie_notes/data/services/parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

Future<io.Directory> get documentsDir async =>
    getApplicationDocumentsDirectory();

Future<List<NoteEntity>> listDirectory(io.Directory dir) async {
  final List<NoteEntity> entities = [];
  for (final e in dir.listSync(recursive: false, followLinks: false)) {
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

writeJvg(Document document, io.File file) async {
  final buffer = StringBuffer();
  buffer.writeln("<jvg>");
  for (final page in document.pages) {
    buffer.writeln("<page>");
    for (final element in page.elements) {
      switch (element.type) {
        case RenderType.path:
          buffer.write('<path offset="');
          buffer.write(element.offset);
          buffer.writeln('">');
          buffer.writeAll((element as Path).points, " ");
          buffer.writeln("</path>");
          break;
      }
    }
    buffer.writeln("</page>");
  }
  buffer.writeln("</jvg>");
  file.writeAsString(buffer.toString());
}

Future<Document> readJvg(io.File file) async {
  readPath(XmlElement xml) {
    readOffset() {
      final offset = xml.getAttribute("offset");
      if (offset != null) {
        final result = coord.parse(SpanScanner(offset));
        if (result.successful) return result.value;
      }
      return Coord(0, 0);
    }

    readPoints() {
      final points = xml.innerText.replaceAll("\n", "");
      if (points != null) {
        final result = coords.parse(SpanScanner(points));
        if (result.successful) return result.value;
      }
      return null;
    }

    final points = readPoints();
    if (points == null) return null;
    final offset = readOffset();
    return Path(points, offset);
  }

  final xml = XmlDocument.parse(file.readAsStringSync());
  final document = Document();
  for (final xmlJvg in xml.findElements("jvg")) {
    for (final xmlPage in xmlJvg.findElements("page")) {
      final page = Page();
      for (final xmlElement in xmlPage.children) {
        if (xmlElement.nodeType == XmlNodeType.ELEMENT) {
          switch ((xmlElement as XmlElement).name.toString()) {
            case "path":
              final path = readPath(xmlElement);
              if (path != null) page.elements.add(path);
              break;
          }
        }
      }
      document.pages.add(page);
    }
  }
  if (document.pages.isEmpty) document.pages.add(Page());
  return document;
}
