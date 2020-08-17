import 'package:flutter/material.dart';

const vert_breakpoint = 600;

class ResponsiveScaffold extends StatelessWidget {
  final toolbar, sidebar, main;

  ResponsiveScaffold({
    @required this.toolbar,
    @required this.sidebar,
    @required this.main,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (size.width > vert_breakpoint) {
      return Material(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            this.sidebar,
            Expanded(
              child: buildMainArea(size),
            ),
          ],
        ),
      );
    }
    return Material(
      child: sidebar,
    );
  }

  Widget buildMainArea(size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        this.toolbar,
        Expanded(
          child: this.main,
        )
      ],
    );
  }
}
