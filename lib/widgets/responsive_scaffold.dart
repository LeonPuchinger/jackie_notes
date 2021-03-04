import 'package:flutter/material.dart';
import 'package:jackie_notes/data/state/app_bloc.dart';
import 'package:jackie_notes/widgets/document_viewer.dart';
import 'package:jackie_notes/widgets/notelist.dart';
import 'package:jackie_notes/widgets/toolbar.dart';
import 'package:provider/provider.dart';

const vert_breakpoint = 600;

class ResponsiveScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _appBloc = context.watch<AppBloc>();
    final size = MediaQuery.of(context).size;

    if (size.width > vert_breakpoint) {
      return Material(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                    right: BorderSide(
                        width: 1, color: Theme.of(context).dividerColor)),
              ),
              child: NoteList(),
              width: 280,
            ),
            Expanded(
              child: buildMainArea(_appBloc.edit),
            ),
          ],
        ),
      );
    }
    return Material(
      child: NoteList(
        onEntrySelected: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => buildMainArea(_appBloc.edit),
            ),
          );
        },
      ),
    );
  }

  Widget buildMainArea(Stream documentOpened) {
    return StreamBuilder(
      stream: documentOpened,
      builder: (_, snapshot) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: snapshot.hasData
              ? [
                  Toolbar(),
                  Expanded(child: DocumentViewer()),
                ]
              : [
                  Center(child: Text("No Documents opened")),
                ],
        );
      },
    );
  }
}
