import 'package:hive/hive.dart';

part 'note_folder_model.g.dart';

@HiveType(typeId: 11)
class NoteFolderModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int colorHex;

  @HiveField(3)
  final DateTime createdAt;

  NoteFolderModel({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.createdAt,
  });

  static List<NoteFolderModel> getDefaultFolders() {
    return [
      NoteFolderModel(id: 'folder_1', name: 'Lecture Notes', colorHex: 0xFF0061A4, createdAt: DateTime.now()),
      NoteFolderModel(id: 'folder_2', name: 'Research', colorHex: 0xFF5856D6, createdAt: DateTime.now()),
      NoteFolderModel(id: 'folder_3', name: 'Personal', colorHex: 0xFF2E7D32, createdAt: DateTime.now()),
      NoteFolderModel(id: 'folder_4', name: 'Quick Capture', colorHex: 0xFFED6C02, createdAt: DateTime.now()),
    ];
  }
}
