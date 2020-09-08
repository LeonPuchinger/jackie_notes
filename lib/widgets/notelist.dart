import 'package:flutter/material.dart';
import 'package:jackie_notes/data/note.dart';
import 'package:jackie_notes/data/state/app_bloc.dart';
import 'package:jackie_notes/data/state/notelist_bloc.dart';
import 'package:jackie_notes/widgets/document_viewer.dart';
import 'package:provider/provider.dart';

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  @override
  Widget build(BuildContext context) {
    final _appBloc = Provider.of<AppBloc>(context);
    final bloc = NoteListBloc(_appBloc);

    return Column(
      children: [
        StreamBuilder(
          stream: bloc.currentDirectory,
          initialData: Directory("Files", "", true),
          builder: (_, snapshot) {
            return AppBar(
              title: Text(snapshot.data.name),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: snapshot.data.isRoot ? null : bloc.moveToParent,
              ),
            );
          },
        ),
        Expanded(
          child: StreamBuilder<List<NoteEntity>>(
            stream: bloc.entities,
            initialData: [],
            builder: (_, snapshot) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (_, index) {
                  return ListItem(
                    name: snapshot.data[index].name,
                    onTap: () => bloc.selectEntity(index),
                    directory: snapshot.data[index] is Directory,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class ListItem extends StatelessWidget {
  final String name;
  final GestureTapCallback onTap;
  final bool directory;

  ListItem({this.name, this.onTap, this.directory});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        title: Text(this.name),
        trailing: this.directory
            ? Icon(Icons.keyboard_arrow_right)
            : Container(width: 0),
        onTap: this.onTap,
        dense: true,
      ),
    );
  }
}
