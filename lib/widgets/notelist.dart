import 'package:flutter/material.dart';
import 'package:jackie_notes/data/note.dart';
import 'package:jackie_notes/data/state/note_list_bloc.dart';

class NoteList extends StatefulWidget {
  final bloc = NoteListBloc();

  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder(
          stream: widget.bloc.currentDirectory,
          initialData: Directory("Files", "", true),
          builder: (_, snapshot) {
            return AppBar(
              title: Text(snapshot.data.name),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: snapshot.data.isRoot ? null : widget.bloc.moveToParent,
              ),
            );
          },
        ),
        Expanded(
          child: StreamBuilder<List<NoteEntity>>(
            stream: widget.bloc.entities,
            initialData: [],
            builder: (_, snapshot) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (_, index) {
                  return ListItem(
                    name: snapshot.data[index].name,
                    onTap: () => widget.bloc.selectEntity(index),
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
