import 'package:flutter/material.dart' hide Text;
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
  DocumentBloc bloc;

  @override
  void dispose() {
    bloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _appBloc = Provider.of<AppBloc>(context);
    bloc ??= DocumentBloc(_appBloc);

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

  paintPath(Path element, Canvas canvas) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    paint.color = element.color;
    final path = ui.Path();
    path.moveTo(element.offset.x, element.offset.y);
    for (final c in element.points) {
      path.relativeLineTo(c.x, c.y);
    }
    canvas.drawPath(path, paint);
  }

  paintText(Text element, Canvas canvas) {
    final span = TextSpan(
      text: element.text,
      style: TextStyle(
        color: element.color,
        fontSize: element.fontSize,
      ),
    );
    final painter = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    );
    painter.layout(minWidth: 0, maxWidth: element.width);
    painter.paint(canvas, ui.Offset(element.offset.x, element.offset.y));
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in document.pages) {
      for (final r in p.elements) {
        switch (r.type) {
          case RenderType.path:
            paintPath(r, canvas);
            break;
          case RenderType.text:
            paintText(r, canvas);
            break;
        }
      }
    }
  }

  @override
  bool shouldRepaint(DocumentPainter oldDelegate) => true;
}
