import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/rendering.dart' show Color;
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
  buildPath(XmlBuilder builder, Path path) {
    builder.element("path", attributes: {
      "offset": "${path.offset}",
      "color": "0x${path.color.value.toRadixString(16).padLeft(8, '0')}"
    }, nest: () {
      builder.text(path.contents);
    });
  }

  final builder = XmlBuilder();
  builder.element("jvg", nest: () {
    for (final page in document.pages) {
      builder.element("page", nest: () {
        for (final element in page.elements) {
          switch (element.type) {
            case RenderType.path:
              buildPath(builder, element);
              continue;
          }
        }
      });
    }
  });
  file.writeAsString(builder.buildDocument().toString());
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

    readColor() {
      final color = xml.getAttribute("color");
      if (color != null) {
        final result = hex32.parse(SpanScanner(color));
        if (result.successful) return Color(result.value);
      }
      return Color(0xffaaaaaa);
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
    final color = readColor();
    return Path(points, color, offset);
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
