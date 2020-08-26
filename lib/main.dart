import 'package:flutter/material.dart';
import 'package:jackie_notes/data/state/app_bloc.dart';
import 'package:jackie_notes/data/state/document_bloc.dart';
import 'package:jackie_notes/data/state/notelist_bloc.dart';
import 'package:jackie_notes/widgets/document.dart';
import 'package:jackie_notes/widgets/notelist.dart';
import 'package:jackie_notes/widgets/responsive_scaffold.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(JackieApp());
}

class JackieApp extends StatefulWidget {
  @override
  _JackieAppState createState() => _JackieAppState();
}

class _JackieAppState extends State<JackieApp> {
  final appBloc = AppBloc();

  @override
  void dispose() {
    appBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SafeArea(
        child: MultiProvider(
          providers: [
            Provider<NoteListBloc>(
              create: (_) => NoteListBloc(appBloc),
              dispose: (_, bloc) => bloc.dispose(),
            ),
            Provider<DocumentBloc>(
              create: (_) => DocumentBloc(appBloc),
              dispose: (_, bloc) => bloc.dispose(),
            ),
          ],
          child: ResponsiveScaffold(
            toolbar: Container(color: Colors.red, child: Text("Toolbar!")),
            sidebar: NoteList(),
            main: Document(),
          ),
        ),
      ),
    );
  }
}
