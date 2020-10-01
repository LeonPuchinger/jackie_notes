import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jackie_notes/data/state/app_bloc.dart';
import 'package:jackie_notes/data/state/toolbar_bloc.dart';
import 'package:jackie_notes/data/tool.dart';
import 'package:jackie_notes/util/dual_streambuilder.dart';
import 'package:provider/provider.dart';

class Toolbar extends StatefulWidget {
  @override
  _ToolbarState createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  ToolbarBloc bloc;

  List<bool> isSelected(int selection, int length) {
    final selected = List.filled(length + 1, false);
    if (selection != null) selected[selection] = true;
    return selected;
  }

  @override
  void dispose() {
    bloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _appBloc = context.watch<AppBloc>();
    bloc ??= ToolbarBloc(_appBloc);

    return AppBar(
      title: Row(
        children: [
          DualStreamBuilder<List<Pen>, int>(
            streamA: bloc.pens,
            streamB: bloc.selection,
            initialDataA: [],
            builder: (_, snapshotA, snapshotB) {
              return ToggleButtons(
                children: [
                  Eraser(),
                  for (final pen in snapshotA.data) Pencil(pen.color)
                ],
                renderBorder: false,
                onPressed: bloc.selectPen,
                isSelected: isSelected(snapshotB.data, snapshotA.data.length),
              );
            },
          )
        ],
      ),
    );
  }
}

class Pencil extends StatelessWidget {
  final Color color;
  final height = 35.0;

  Pencil(this.color);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SvgPicture.asset(
          "assets/pen_inlay_0.svg",
          height: height,
          color: color,
        ),
        SvgPicture.asset(
          "assets/pen_inlay_1.svg",
          height: height,
        ),
        SvgPicture.asset(
          "assets/pen_overlay.svg",
          height: height,
          color: Theme.of(context).dividerColor,
        ),
      ],
    );
  }
}

class Eraser extends StatelessWidget {
  final height = 35.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SvgPicture.asset(
          "assets/eraser_inlay.svg",
          height: height,
        ),
        SvgPicture.asset(
          "assets/eraser_overlay.svg",
          color: Theme.of(context).dividerColor,
          height: height,
        ),
      ],
    );
  }
}
