import 'dart:async';

import 'package:jackie_notes/data/state/app_bloc.dart';
import 'package:jackie_notes/data/state/bloc.dart';
import 'package:jackie_notes/data/tool.dart';
import 'package:rxdart/rxdart.dart';

class ToolbarBloc extends Bloc {
  final AppBloc _appBloc;

  final _toolSelectionController = BehaviorSubject<int>();

  Stream<List<Pen>> get pens => _appBloc.settings.pens;
  Stream<int> get toolSelection => _toolSelectionController.stream;
  Stream<List<bool>> get optionSelection => CombineLatestStream(
        [
          _appBloc.settings.showGrid,
          _appBloc.settings.showOutline,
        ],
        (values) => values,
      );

  ToolbarBloc(this._appBloc);

  selectPen(int index) {
    _toolSelectionController.add(index);
    final tool =
        index == 0 ? Eraser(5) : _appBloc.settings.pensValue[index - 1];
    _appBloc.addTool(tool);
  }

  selectOption(int index) {
    switch (index) {
      case 0:
        final current = _appBloc.settings.showGridValue;
        _appBloc.settings.setShowGrid(!current);
        break;
      case 1:
        final current = _appBloc.settings.showOutlineValue;
        _appBloc.settings.setShowOutline(!current);
        break;
    }
  }

  @override
  void dispose() {
    _toolSelectionController.close();
  }

  @override
  void init() {}
}
