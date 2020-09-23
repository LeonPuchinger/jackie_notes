import 'package:combinator/combinator.dart';
import 'package:jackie_notes/data/document.dart';
export 'package:string_scanner/string_scanner.dart' show SpanScanner;

final number = match(RegExp(r"-?[0-9]+(\.[0-9]+)?"))
    .map<double>((r) => double.parse(r.span.text));

final coord = chain([
  number,
  match(" ").space(),
  number,
]).map<Coord>((r) => Coord(r.value[0], r.value[2]));

final coords = coord.separatedBy(match(" ").space());

final hex32 = chain([
  match(RegExp("0[Xx]")),
  match(RegExp("[0-9a-fA-F]{8}")).map<String>((r) => r.span.text),
]).map<int>((r) => int.parse(r.value[1], radix: 16));
