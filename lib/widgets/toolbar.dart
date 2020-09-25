import 'package:flutter/material.dart';
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
                  Icon(Icons.remove_circle_outline),
                  for (final pen in snapshotA.data)
                    Icon(Icons.create, color: pen.color)
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

class Tool extends StatelessWidget {
  final Color color;

  Tool(this.color);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.edit, color: color),
      onPressed: () {},
    );
  }
}
