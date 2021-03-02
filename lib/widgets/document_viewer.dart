import 'package:flutter/material.dart' hide Text;
import 'package:jackie_notes/data/document.dart';
import 'package:jackie_notes/data/state/app_bloc.dart';
import 'package:jackie_notes/data/state/document_bloc.dart';
import 'package:jackie_notes/util/dual_streambuilder.dart';
import 'package:provider/provider.dart';
import 'dart:math';
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
        return Scrollbar(
          child: SingleChildScrollView(
            child: AbsorbPointer(
              absorbing: snapshot.data == null,
              child: GestureDetector(
                onPanStart: (details) => bloc.panStart(
                    details.localPosition.dx, details.localPosition.dy),
                onPanUpdate: (details) => bloc.panUpdate(
                    details.localPosition.dx, details.localPosition.dy),
                child: DualStreamBuilder<Document, Map<String, bool>>(
                  streamA: bloc.document,
                  streamB: bloc.backgroundOptions,
                  initialDataA: Document(),
                  initialDataB: {"showGrid": false, "showOutline": false},
                  builder: (context, snapshotA, snapshotB) {
                    return CustomPaint(
                      size: Size(5000, 5000),
                      isComplex: true,
                      painter: BackgroundPainter(
                        snapshotA.data,
                        Theme.of(context).brightness,
                        snapshotB.data,
                      ),
                      foregroundPainter: DocumentPainter(snapshotA.data),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final Document document;
  final Brightness themeMode;
  final Map<String, bool> options;
  static const _gridSize = 20;

  BackgroundPainter(this.document, this.themeMode, this.options);

  paintBackgroundPattern(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color =
          themeMode == Brightness.dark ? Color(0x50000000) : Color(0xffffffff);
    canvas.drawRect(
        Rect.fromPoints(Offset(0, 0), Offset(size.width, size.height)),
        backgroundPaint);
    canvas.save();
    canvas.translate(-_gridSize / 2, -_gridSize / 2);
    final patternPaint = Paint()
      ..color =
          themeMode == Brightness.dark ? Color(0xff4a4a4a) : Color(0xffcaebfd);
    for (double x = 0; x <= size.width; x += _gridSize) {
      canvas.drawLine(
          Offset(x, 0), Offset(x, size.height + _gridSize), patternPaint);
    }
    for (double y = 0; y <= size.height; y += _gridSize) {
      canvas.drawLine(
          Offset(0, y), Offset(size.width + _gridSize, y), patternPaint);
    }
    canvas.restore();
  }

  paintPageOutline(Canvas canvas) {
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.grey;
    canvas.translate(document.pageMargin, 0);
    for (final _ in document.pages) {
      canvas.translate(0, document.pageMargin);
      final outline = Rect.fromLTWH(
          0, 0, document.pageHeight / sqrt(2), document.pageHeight);
      canvas.drawRect(outline, outlinePaint);
      canvas.translate(0, document.pageMargin);
      canvas.translate(0, document.pageHeight);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (options["showGrid"] ?? false) {
      paintBackgroundPattern(canvas, size);
    }
    if (options["showOutline"] ?? false) {
      paintPageOutline(canvas);
    }
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) => false;
}

class DocumentPainter extends CustomPainter {
  final Document document;

  DocumentPainter(this.document);

  paintPath(Path element, Canvas canvas) {
    final paint = Paint()
      ..strokeWidth = element.width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..color = element.color;
    final path = ui.Path();
    path.moveTo(element.offset.x, element.offset.y);
    if (element.points.isEmpty) {
      canvas.drawPoints(ui.PointMode.points,
          [Offset(element.offset.x, element.offset.y)], paint);
    }
    for (final c in element.points) {
      final relative = element.offset + c;
      path.lineTo(relative.x, relative.y);
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
    painter.paint(canvas, ui.Offset(element.start.x, element.start.y));
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final page in document.pages) {
      for (final element in page.elements) {
        switch (element.type) {
          case RenderType.path:
            paintPath(element, canvas);
            break;
          case RenderType.text:
            paintText(element, canvas);
            break;
        }
      }
      canvas.translate(0, document.pageHeight);
    }
  }

  @override
  bool shouldRepaint(DocumentPainter oldDelegate) => true;
}
