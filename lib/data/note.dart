enum EntityType { file, dir }

abstract class NoteEntity {
  final String name, path;
  bool selected;

  NoteEntity(this.name, this.path);

  EntityType get type;
}

class Note extends NoteEntity {
  Note(name, path) : super(name, path);

  EntityType get type => EntityType.file;
}

class Directory extends NoteEntity {
  final bool isRoot;

  Directory(name, path, [this.isRoot = false]) : super(name, path);

  EntityType get type => EntityType.dir;
}
