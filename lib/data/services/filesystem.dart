import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/rendering.dart' show Color;
import 'package:jackie_notes/data/document.dart';
import 'package:jackie_notes/data/note.dart';
import 'package:jackie_notes/data/services/parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';
import 'package:jackie_notes/util/color_to_hex.dart';

Future<io.Directory> get documentsDir async =>
    getApplicationDocumentsDirectory();

Future<List<NoteEntity>> listDirectory(io.Directory dir) async {
  final List<NoteEntity> entities = [];
  for (final e in dir.listSync(recursive: false, followLinks: false)) {
    final type = e.toString().split(":")[0];
    if (type == "File") {
      final name = e.path.split("/").last.split(".");
      if (name.length == 2 && name.last == "jvg") {
        entities.add(Note(name.first, e.path));
      }
    }
    if (type == "Directory") {
      entities.add(Directory(e.path.split("/").last, e.path));
    }
  }
  return entities;
}

createJvg(String path) async {
  final document = Document()..pages.add(Page());
  final file = io.File("$path/New File.jvg")..createSync(recursive: false);
  await writeJvg(document, file);
}

writeJvg(Document document, io.File file) async {
  buildPath(XmlBuilder builder, Path path) {
    builder.element("path", attributes: {
      "start": "${path.start}",
      "end": "${path.end}",
      "offset": "${path.offset}",
      "color": "0x${path.color.hexString}",
      "width": "${path.width}",
    }, nest: () {
      builder.text(path.contents);
    });
  }

  buildText(XmlBuilder builder, Text text) {
    builder.element("text", attributes: {
      "start": "${text.start}",
      "end": "${text.end}",
      "color": "0x${text.color.hexString}",
      "font-size": "${text.fontSize}",
      "width": "${text.width}",
    }, nest: () {
      builder.text(text.text);
    });
  }

  final builder = XmlBuilder();
  builder.element("jvg", attributes: {
    "page-height": "${document.pageHeight}",
    "page-margin": "${document.pageMargin}",
  }, nest: () {
    for (final page in document.pages) {
      builder.element("page", nest: () {
        for (final element in page.elements) {
          switch (element.type) {
            case RenderType.path:
              buildPath(builder, element);
              continue;
            case RenderType.text:
              buildText(builder, element);
              continue;
          }
        }
      });
    }
  });
  file.writeAsString(builder.buildDocument().toXmlString(pretty: true));
}

Future<Document> readJvg(io.File file) async {
  readDocument(XmlElement xml) {
    readPageHeight(XmlElement xml) {
      final height = xml.getAttribute("page-height");
      if (height != null) {
        final result = float.parse(height);
        if (result.isSuccess) return result.value;
      }
      return 2000.0;
    }

    readPageMargin(XmlElement xml) {
      final margin = xml.getAttribute("page-margin");
      if (margin != null) {
        final result = float.parse(margin);
        if (result.isSuccess) return result.value;
      }
      return 20.0;
    }

    final height = readPageHeight(xml);
    final margin = readPageMargin(xml);
    return Document(pageHeight: height, pageMargin: margin);
  }

  readColor(XmlElement xml) {
    final color = xml.getAttribute("color");
    if (color != null) {
      final result = hex.parse(color);
      if (result.isSuccess) return Color(result.value);
    }
    return Color(0xffaaaaaa);
  }

  readStart(XmlElement xml) {
    final start = xml.getAttribute("start");
    if (start != null) {
      final result = coord.parse(start);
      if (result.isSuccess) return result.value;
    }
    return Coord(0, 0);
  }

  readEnd(XmlElement xml) {
    final end = xml.getAttribute("end");
    if (end != null) {
      final result = coord.parse(end);
      if (result.isSuccess) return result.value;
    }
    return null;
  }

  readPath(XmlElement xml) {
    readPoints() {
      final points = xml.innerText.replaceAll("\n", "");
      if (points != null) {
        final result = coords.parse(points);
        if (result.isSuccess) return result.value;
      }
      return null;
    }

    readWidth() {
      final width = xml.getAttribute("width");
      if (width != null) {
        final result = double.tryParse(width);
        if (result != null) return result;
      }
      return 2.0;
    }

    readOffset() {
      final offset = xml.getAttribute("offset");
      if (offset != null) {
        final result = coord.parse(offset);
        if (result.isSuccess) return result.value;
      }
      return null;
    }

    final points = readPoints();
    if (points == null) return null;
    final color = readColor(xml);
    final width = readWidth();
    final start = readStart(xml);
    final end = readEnd(xml) ?? Coord(start.x, start.y);
    final offset = readOffset() ?? Coord(start.x, start.y);
    return Path(points, color, width, offset, start, end);
  }

  readText(XmlElement xml) {
    readWidth() {
      final width = xml.getAttribute("width");
      if (width != null) {
        final result = double.tryParse(width);
        if (result != null) return result;
      }
      return 100.0;
    }

    readFontSize() {
      final size = xml.getAttribute("font-size");
      if (size != null) {
        final result = double.tryParse(size);
        if (result != null) return result;
      }
      return 12.0;
    }

    readText() {
      final text = xml.innerText;
      if (text == null || text.length == 0) return null;
      return text;
    }

    final text = readText();
    if (text == null) return null;
    final color = readColor(xml);
    final size = readFontSize();
    final width = readWidth();
    final start = readStart(xml);
    final end = readEnd(xml) ?? Coord(start.x, start.y);
    return Text(text, color, size, width, start, end);
  }

  final xml = XmlDocument.parse(file.readAsStringSync());
  final xmlJvg = xml.getElement("jvg");
  final document = readDocument(xmlJvg);
  for (final xmlPage in xmlJvg.findElements("page")) {
    final page = Page();
    for (final xmlElement in xmlPage.children) {
      if (xmlElement.nodeType == XmlNodeType.ELEMENT) {
        switch ((xmlElement as XmlElement).name.toString()) {
          case "path":
            final path = readPath(xmlElement);
            if (path != null) page.elements.add(path);
            break;
          case "text":
            final text = readText(xmlElement);
            if (text != null) page.elements.add(text);
            break;
        }
      }
    }
    document.pages.add(page);
  }
  if (document.pages.isEmpty) document.pages.add(Page());
  return document;
}
