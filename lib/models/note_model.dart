import 'package:hive/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 10)
class NoteModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String contentJson; // flutter_quill Delta stored as JSON string

  @HiveField(3)
  final String folderId;

  @HiveField(4)
  final List<String> tags;

  @HiveField(5)
  final bool isFavorite;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  @HiveField(8)
  final bool hasAttachment;

  NoteModel({
    required this.id,
    required this.title,
    required this.contentJson,
    required this.folderId,
    required this.tags,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
    this.hasAttachment = false,
  });

  NoteModel copyWith({
    String? id,
    String? title,
    String? contentJson,
    String? folderId,
    List<String>? tags,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? hasAttachment,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      contentJson: contentJson ?? this.contentJson,
      folderId: folderId ?? this.folderId,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hasAttachment: hasAttachment ?? this.hasAttachment,
    );
  }

  String get previewText {
    // Strip JSON markers for simple preview
    final raw = contentJson.replaceAll(RegExp(r'[{}"\\[\]]'), ' ').trim();
    return raw.length > 120 ? '${raw.substring(0, 120)}...' : raw;
  }

  static List<NoteModel> getDefaultNotes() {
    final now = DateTime.now();
    const sampleContent = '[{"insert":"This is your first note!\\n"}]';
    const algorithmContent = '[{"insert":"Algorithms Study Notes\\n","attributes":{"bold":true}},{"insert":"- Big O Notation\\n- Graph Traversal\\n- Dynamic Programming\\n"}]';
    return [
      NoteModel(
        id: 'note_1',
        title: 'Database Systems Key Concepts',
        contentJson: algorithmContent,
        folderId: 'folder_1',
        tags: ['DBMS', 'SQL', 'Important'],
        isFavorite: true,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
      NoteModel(
        id: 'note_2',
        title: 'Algorithms Mid-Term Prep',
        contentJson: algorithmContent,
        folderId: 'folder_1',
        tags: ['Algorithms', 'Exam', 'Priority'],
        isFavorite: true,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      NoteModel(
        id: 'note_3',
        title: 'Research Ideas - AI in Education',
        contentJson: sampleContent,
        folderId: 'folder_2',
        tags: ['Research', 'AI'],
        isFavorite: false,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      NoteModel(
        id: 'note_4',
        title: 'Weekly Goals & Reflections',
        contentJson: sampleContent,
        folderId: 'folder_3',
        tags: ['Personal', 'Goals'],
        isFavorite: false,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
      ),
    ];
  }
}
