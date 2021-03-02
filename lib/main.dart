import 'package:flutter/material.dart';
import 'package:jackie_notes/data/state/app_bloc.dart';
import 'package:jackie_notes/widgets/document_viewer.dart';
import 'package:jackie_notes/widgets/notelist.dart';
import 'package:jackie_notes/widgets/responsive_scaffold.dart';
import 'package:jackie_notes/widgets/toolbar.dart';
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
    return Provider<AppBloc>.value(
      value: appBloc,
      child: MaterialApp(
        themeMode: ThemeMode.system,
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.dark(),
          toggleButtonsTheme: ToggleButtonsThemeData(
            fillColor: Colors.white.withAlpha(40),
            hoverColor: Colors.white.withAlpha(30),
            selectedColor: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.light(),
          toggleButtonsTheme: ToggleButtonsThemeData(
            fillColor: Colors.white.withAlpha(60),
            hoverColor: Colors.white.withAlpha(30),
            selectedColor: Colors.black,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        home: SafeArea(
          child: ResponsiveScaffold(
            toolbar: StreamBuilder(
              stream: appBloc.edit,
              builder: (_, snapshot) {
                if (snapshot.hasData)
                  return Toolbar();
                else
                  return Container();
              },
            ),
            sidebar: NoteList(),
            main: StreamBuilder(
              stream: appBloc.edit,
              builder: (_, snapshot) {
                if (snapshot.hasData)
                  return DocumentViewer();
                else
                  return Center(child: Text("No Documents opened"));
              },
            ),
          ),
        ),
      ),
    );
  }
}
