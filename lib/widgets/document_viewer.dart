import 'package:flutter/material.dart';
import 'package:jackie_notes/data/document.dart';
import 'package:jackie_notes/data/state/app_bloc.dart';
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
    final _appBloc = Provider.of<AppBloc>(context);
    final bloc = DocumentBloc(_appBloc);

    return StreamBuilder(
      stream: _appBloc.tool,
      builder: (_, snapshot) {
        return AbsorbPointer(
          absorbing: snapshot.data == null,
          child: GestureDetector(
            onPanStart: (details) => bloc.panStart(
                details.localPosition.dx, details.localPosition.dy),
            onPanUpdate: (details) =>
                bloc.panUpdate(details.delta.dx, details.delta.dy),
            child: StreamBuilder<Document>(
              stream: bloc.document,
              initialData: Document(),
              builder: (context, snapshot) {
                return CustomPaint(
                  size: Size.infinite,
                  isComplex: true,
                  painter: DocumentPainter(snapshot.data),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class DocumentPainter extends CustomPainter {
  final Document document;

  DocumentPainter(this.document);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (final p in document.pages) {
      for (final r in p.elements) {
        switch (r.type) {
          case RenderType.path:
            paint.color = (r as Path).color;
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
