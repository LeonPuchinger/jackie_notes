import 'package:flutter/material.dart';
import 'package:jackie_notes/widgets/notelist.dart';
import 'package:jackie_notes/widgets/responsive_scaffold.dart';

void main() {
  runApp(JackieApp());
}

class JackieApp extends StatelessWidget {
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
        child: ResponsiveScaffold(
          toolbar: Container(color: Colors.red, child: Text("Toolbar!")),
          sidebar: NoteList(),
          main: Container(color: Colors.green, child: Text("Main Area!")),
        ),
      ),
    );
  }
}
