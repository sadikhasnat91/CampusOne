import 'package:flutter/foundation.dart';
import '../database/hive_service.dart';
import '../models/routine_item_model.dart';

enum RoutineViewMode { daily, weekly, calendar }

class RoutineController extends ChangeNotifier {
  List<RoutineItemModel> _allRoutines = [];
  String _selectedSemester = '6th Semester';
  String _selectedSection = 'A';
  String _selectedGroup = 'Group 1';

  String _searchQuery = '';
  String _selectedDay = 'Monday';
  RoutineViewMode _viewMode = RoutineViewMode.daily;

  bool _showFavoritesOnly = false;
  String? _filterSubject;
  String? _filterTeacher;
  String? _filterRoom;

  RoutineController() {
    _loadRoutinesFromHive();
  }

  // Getters
  String get selectedSemester => _selectedSemester;
  String get selectedSection => _selectedSection;
  String get selectedGroup => _selectedGroup;
  String get searchQuery => _searchQuery;
  String get selectedDay => _selectedDay;
  RoutineViewMode get viewMode => _viewMode;
  bool get showFavoritesOnly => _showFavoritesOnly;

  void _loadRoutinesFromHive() {
    final box = HiveService.instance.routineItemsBox;
    if (box.isEmpty) {
      // Seed default master routines
      final defaults = RoutineItemModel.getMasterSampleRoutines();
      for (var item in defaults) {
        box.put(item.id, item);
      }
      _allRoutines = defaults;
    } else {
      _allRoutines = box.values.toList();
    }
    notifyListeners();
  }

  // Filter Routine based on Student's active Semester, Section, Group, Search & Tab filters
  List<RoutineItemModel> get filteredRoutines {
    return _allRoutines.where((item) {
      // Auto Routine Filter logic
      final matchesStudentProfile = item.semester == _selectedSemester &&
          item.section == _selectedSection &&
          item.group == _selectedGroup;

      if (!matchesStudentProfile) return false;

      // View mode filter
      if (_viewMode == RoutineViewMode.daily && item.dayOfWeek != _selectedDay) {
        return false;
      }

      // Search
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesQuery = item.subjectName.toLowerCase().contains(query) ||
            item.courseCode.toLowerCase().contains(query) ||
            item.teacherName.toLowerCase().contains(query) ||
            item.roomNo.toLowerCase().contains(query);
        if (!matchesQuery) return false;
      }

      // Favorites filter
      if (_showFavoritesOnly && !item.isFavorite) return false;

      // Subject filter
      if (_filterSubject != null && _filterSubject!.isNotEmpty) {
        if (item.subjectName != _filterSubject) return false;
      }

      // Teacher filter
      if (_filterTeacher != null && _filterTeacher!.isNotEmpty) {
        if (item.teacherName != _filterTeacher) return false;
      }

      // Room filter
      if (_filterRoom != null && _filterRoom!.isNotEmpty) {
        if (item.roomNo != _filterRoom) return false;
      }

      return true;
    }).toList();
  }

  void updateStudentProfileFilter(String semester, String section, String group) {
    _selectedSemester = semester;
    _selectedSection = section;
    _selectedGroup = group;
    notifyListeners();
  }

  void setViewMode(RoutineViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  void setSelectedDay(String day) {
    _selectedDay = day;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleFavoritesOnly() {
    _showFavoritesOnly = !_showFavoritesOnly;
    notifyListeners();
  }

  Future<void> toggleFavorite(RoutineItemModel item) async {
    final updated = item.copyWith(isFavorite: !item.isFavorite);
    await HiveService.instance.routineItemsBox.put(updated.id, updated);
    _loadRoutinesFromHive();
  }

  Future<void> addOrUpdateRoutine(RoutineItemModel item) async {
    await HiveService.instance.routineItemsBox.put(item.id, item);
    _loadRoutinesFromHive();
  }

  Future<void> deleteRoutine(String id) async {
    await HiveService.instance.routineItemsBox.delete(id);
    _loadRoutinesFromHive();
  }

  Future<void> importMasterRoutineSamples() async {
    final defaults = RoutineItemModel.getMasterSampleRoutines();
    final box = HiveService.instance.routineItemsBox;
    for (var item in defaults) {
      await box.put(item.id, item);
    }
    _loadRoutinesFromHive();
  }
}
