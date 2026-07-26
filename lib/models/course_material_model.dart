import 'package:hive/hive.dart';

part 'course_material_model.g.dart';

@HiveType(typeId: 5)
class CourseMaterialModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String subjectId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String type; // 'pdf', 'image', 'note', 'link'

  @HiveField(4)
  final String contentUrl;

  @HiveField(5)
  final DateTime dateAdded;

  CourseMaterialModel({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.type,
    required this.contentUrl,
    required this.dateAdded,
  });

  static List<CourseMaterialModel> getDefaultMaterials() {
    return [
      CourseMaterialModel(
        id: 'mat_1',
        subjectId: 'sub_1',
        title: 'DBMS Lecture 01 - Normalization PDF',
        type: 'pdf',
        contentUrl: 'https://campusone.edu/dbms_lecture1.pdf',
        dateAdded: DateTime.now().subtract(const Duration(days: 2)),
      ),
      CourseMaterialModel(
        id: 'mat_2',
        subjectId: 'sub_2',
        title: 'Graph Theory Visual Notes',
        type: 'image',
        contentUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=500',
        dateAdded: DateTime.now().subtract(const Duration(days: 5)),
      ),
      CourseMaterialModel(
        id: 'mat_3',
        subjectId: 'sub_1',
        title: 'SQL Join Cheatsheet & Documentation',
        type: 'link',
        contentUrl: 'https://dev.mysql.com/doc/',
        dateAdded: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}
