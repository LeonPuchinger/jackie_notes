import 'package:flutter/material.dart';
import 'package:jackie_notes/data/document.dart';
import 'package:jackie_notes/data/state/document_bloc.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

class DocumentViewer extends StatefulWidget {
  @override
  _DocumentViewerState createState() => _DocumentViewerState();
}

class _DocumentViewerState extends State<DocumentViewer> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<DocumentBloc>(context);

    return StreamBuilder<Document>(
        stream: bloc.document,
        initialData: Document(),
        builder: (context, snapshot) {
          return CustomPaint(
            size: Size.infinite,
            painter: DocumentPainter(snapshot.data),
          );
        });
  }
}

class DocumentPainter extends CustomPainter {
  final Document document;

  DocumentPainter(this.document);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke;
    for (final p in document.pages) {
      for (final r in p.elements) {
        switch (r.type) {
          case RenderType.path:
            final path = ui.Path();
            path.moveTo(r.offset.x, r.offset.y);
            for (final c in (r as Path).points) {
              path.relativeLineTo(c.x, c.y);
            }
            canvas.drawPath(path, paint);
            break;
        }
      }
    }
  }

  @override
  bool shouldRepaint(DocumentPainter oldDelegate) => true;
}
