import 'package:jackie_notes/data/state/app_bloc.dart';
import 'package:jackie_notes/data/state/bloc.dart';
import 'package:jackie_notes/data/tool.dart';
import 'package:rxdart/rxdart.dart';

//FIXME: should probably replace with non-ui class to separate concerns
import 'package:flutter/rendering.dart' show Color;

class ToolbarBloc extends Bloc {
  final AppBloc _appBloc;

  final _penController = BehaviorSubject<List<Pen>>();
  final _selectionController = BehaviorSubject<int>();

  Stream<List<Pen>> get pens => _penController.stream;
  Stream<int> get selection => _selectionController.stream;

  ToolbarBloc(this._appBloc);

  selectPen(int index) async {
    _selectionController.add(index);
    final tool = index == 0 ? Eraser() : _penController.value[index - 1];
    _appBloc.addTool(tool);
  }

  @override
  void dispose() {
    _penController.close();
    _selectionController.close();
  }

  @override
  void init() {
    _penController.add(<Pen>[
      Pen(Color(0xffc7c7c7)),
      Pen(Color(0xfff02252)),
      Pen(Color(0xff73db63)),
      Pen(Color(0xff4990d6)),
    ]);
  }
}
