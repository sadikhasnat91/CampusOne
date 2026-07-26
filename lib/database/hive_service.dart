import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/hive_box_keys.dart';
import '../models/app_settings_model.dart';
import '../models/student_profile_model.dart';
import '../models/dashboard_stats_model.dart';
import '../models/routine_item_model.dart';
import '../models/subject_model.dart';
import '../models/course_material_model.dart';
import '../models/academic_event_model.dart';
import '../models/task_item_model.dart';
import '../models/habit_item_model.dart';
import '../models/goal_item_model.dart';
import '../models/note_model.dart';
import '../models/note_folder_model.dart';
import '../models/campus_location_model.dart';
import '../models/faculty_member_model.dart';
import '../models/campus_info_model.dart';
import '../models/expense_item_model.dart';
import '../models/cover_page_model.dart';

class HiveService {
  static final HiveService instance = HiveService._internal();
  HiveService._internal();

  bool _isInitialized = false;

  Future<void> initHive([String? path]) async {
    if (_isInitialized) return;

    if (path != null) {
      Hive.init(path);
    } else {
      await Hive.initFlutter();
    }

    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(AppSettingsModelAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(StudentProfileModelAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(DashboardStatsModelAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(RoutineItemModelAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(SubjectModelAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(CourseMaterialModelAdapter());
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(AcademicEventModelAdapter());
    if (!Hive.isAdapterRegistered(7)) Hive.registerAdapter(TaskItemModelAdapter());
    if (!Hive.isAdapterRegistered(8)) Hive.registerAdapter(HabitItemModelAdapter());
    if (!Hive.isAdapterRegistered(9)) Hive.registerAdapter(GoalItemModelAdapter());
    if (!Hive.isAdapterRegistered(10)) Hive.registerAdapter(NoteModelAdapter());
    if (!Hive.isAdapterRegistered(11)) Hive.registerAdapter(NoteFolderModelAdapter());
    if (!Hive.isAdapterRegistered(12)) Hive.registerAdapter(CampusLocationModelAdapter());
    if (!Hive.isAdapterRegistered(13)) Hive.registerAdapter(FacultyMemberModelAdapter());
    if (!Hive.isAdapterRegistered(14)) Hive.registerAdapter(CampusInfoModelAdapter());
    if (!Hive.isAdapterRegistered(15)) Hive.registerAdapter(ExpenseItemModelAdapter());
    if (!Hive.isAdapterRegistered(16)) Hive.registerAdapter(CoverPageModelAdapter());

    await Hive.openBox<AppSettingsModel>(HiveBoxKeys.appSettingsBox);
    await Hive.openBox<StudentProfileModel>(HiveBoxKeys.userProfileBox);
    await Hive.openBox<DashboardStatsModel>(HiveBoxKeys.dashboardStatsBox);
    await Hive.openBox<RoutineItemModel>(HiveBoxKeys.routineItemsBox);
    await Hive.openBox<SubjectModel>(HiveBoxKeys.subjectsBox);
    await Hive.openBox<CourseMaterialModel>(HiveBoxKeys.courseMaterialsBox);
    await Hive.openBox<AcademicEventModel>(HiveBoxKeys.academicEventsBox);
    await Hive.openBox<TaskItemModel>(HiveBoxKeys.tasksBox);
    await Hive.openBox<HabitItemModel>(HiveBoxKeys.habitsBox);
    await Hive.openBox<GoalItemModel>(HiveBoxKeys.goalsBox);
    await Hive.openBox<NoteModel>(HiveBoxKeys.notesBox);
    await Hive.openBox<NoteFolderModel>(HiveBoxKeys.foldersBox);
    await Hive.openBox<CampusLocationModel>(HiveBoxKeys.campusLocationsBox);
    await Hive.openBox<FacultyMemberModel>(HiveBoxKeys.facultyBox);
    await Hive.openBox<CampusInfoModel>(HiveBoxKeys.campusInfoBox);
    await Hive.openBox<ExpenseItemModel>(HiveBoxKeys.expensesBox);
    await Hive.openBox<CoverPageModel>(HiveBoxKeys.coverPagesBox);

    _isInitialized = true;
    debugPrint('Hive Database fully initialized with all modules.');
  }

  Box<AppSettingsModel> get appSettingsBox => Hive.box<AppSettingsModel>(HiveBoxKeys.appSettingsBox);
  Box<StudentProfileModel> get userProfileBox => Hive.box<StudentProfileModel>(HiveBoxKeys.userProfileBox);
  Box<DashboardStatsModel> get dashboardStatsBox => Hive.box<DashboardStatsModel>(HiveBoxKeys.dashboardStatsBox);
  Box<RoutineItemModel> get routineItemsBox => Hive.box<RoutineItemModel>(HiveBoxKeys.routineItemsBox);
  Box<SubjectModel> get subjectsBox => Hive.box<SubjectModel>(HiveBoxKeys.subjectsBox);
  Box<CourseMaterialModel> get courseMaterialsBox => Hive.box<CourseMaterialModel>(HiveBoxKeys.courseMaterialsBox);
  Box<AcademicEventModel> get academicEventsBox => Hive.box<AcademicEventModel>(HiveBoxKeys.academicEventsBox);
  Box<TaskItemModel> get tasksBox => Hive.box<TaskItemModel>(HiveBoxKeys.tasksBox);
  Box<HabitItemModel> get habitsBox => Hive.box<HabitItemModel>(HiveBoxKeys.habitsBox);
  Box<GoalItemModel> get goalsBox => Hive.box<GoalItemModel>(HiveBoxKeys.goalsBox);
  Box<NoteModel> get notesBox => Hive.box<NoteModel>(HiveBoxKeys.notesBox);
  Box<NoteFolderModel> get foldersBox => Hive.box<NoteFolderModel>(HiveBoxKeys.foldersBox);
  Box<CampusLocationModel> get campusLocationsBox => Hive.box<CampusLocationModel>(HiveBoxKeys.campusLocationsBox);
  Box<FacultyMemberModel> get facultyBox => Hive.box<FacultyMemberModel>(HiveBoxKeys.facultyBox);
  Box<CampusInfoModel> get campusInfoBox => Hive.box<CampusInfoModel>(HiveBoxKeys.campusInfoBox);
  Box<ExpenseItemModel> get expensesBox => Hive.box<ExpenseItemModel>(HiveBoxKeys.expensesBox);
  Box<CoverPageModel> get coverPagesBox => Hive.box<CoverPageModel>(HiveBoxKeys.coverPagesBox);
}
