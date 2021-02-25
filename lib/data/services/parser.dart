import 'package:jackie_notes/data/document.dart';
import 'package:petitparser/petitparser.dart';

final float = [
  char('-').optional(),
  digit().plus(),
  (char('.') & digit().plus()).optional()
].toSequenceParser().flatten().map<double>(double.parse);

final coord = (float & char(' ').plus() & float)
    .map<Coord>((value) => Coord(value[0], value[2]));

final coords = coord
    .separatedBy(char(' ').plus(), includeSeparators: false)
    .castList<Coord>();

final hex = [
  char('0'),
  (char('X') | char('x')),
  pattern("0-9a-fA-F").plus().flatten()
].toSequenceParser().map<int>((value) => int.parse(value[2], radix: 16));
