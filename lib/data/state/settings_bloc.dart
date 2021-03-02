import 'dart:ui'; //FIXME: replace with non ui dependent types
import 'package:jackie_notes/data/state/bloc.dart';
import 'package:jackie_notes/data/tool.dart';
import 'package:rxdart/subjects.dart';

class Settings extends Bloc {
  BehaviorSubject<List<Pen>> _pens;
  BehaviorSubject<bool> _showGrid;
  BehaviorSubject<bool> _showOutline;

  Stream<List<Pen>> get pens => _pens.stream;
  Stream<bool> get showGrid => _showGrid.stream;
  Stream<bool> get showOutline => _showOutline.stream;

  List<Pen> get pensValue => _pens.value;
  bool get showGridValue => _showGrid.value;
  bool get showOutlineValue => _showOutline.value;

  Function(List<Pen>) get setPen => _pens.add;
  Function(bool) get setShowGrid => _showGrid.add;
  Function(bool) get setShowOutline => _showOutline.add;

  factory Settings() => Settings._fromDefault();

  Settings._fromDefault() {
    _pens = BehaviorSubject.seeded([
      Pen(Color(0xffc7c7c7), 2),
      Pen(Color(0xfff02252), 2),
      Pen(Color(0xff73db63), 2),
      Pen(Color(0xff4990d6), 2),
    ]);
    _showGrid = BehaviorSubject.seeded(false);
    _showOutline = BehaviorSubject.seeded(false);
  }

  @override
  void init() {}

  @override
  void dispose() {
    _pens.close();
    _showGrid.close();
    _showOutline.close();
  }
}
