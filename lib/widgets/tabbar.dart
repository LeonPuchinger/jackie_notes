import 'package:flutter/material.dart';
import 'package:jackie_notes/data/state/app_bloc.dart';
import 'package:provider/provider.dart';

class TabBar extends StatefulWidget {
  @override
  _TabBarState createState() => _TabBarState();
}

class _TabBarState extends State<TabBar> {
  @override
  Widget build(BuildContext context) {
    final appBloc = context.watch<AppBloc>();

    return StreamBuilder(
      stream: appBloc.edit,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          return AppBar(title: Text(snapshot.data.name));
        }
        return Container();
      },
    );
  }
}
