import 'package:flutter/foundation.dart';
import '../database/hive_service.dart';
import '../models/campus_info_model.dart';
import '../models/campus_location_model.dart';
import '../models/faculty_member_model.dart';

class CampusController extends ChangeNotifier {
  List<CampusLocationModel> _locations = [];
  List<FacultyMemberModel> _faculty = [];
  List<CampusInfoModel> _campusInfo = [];

  String _searchQuery = '';
  String _activeSection = 'Faculty'; // Faculty | Bus | Notices | Events | Emergency | Map

  CampusController() {
    _loadData();
  }

  // Getters
  String get activeSection => _activeSection;
  String get searchQuery => _searchQuery;

  List<FacultyMemberModel> get allFaculty => _faculty;
  List<FacultyMemberModel> get favoriteFaculty => _faculty.where((f) => f.isFavorite).toList();

  List<CampusLocationModel> get allLocations => _locations;
  List<CampusLocationModel> get favoriteLocations => _locations.where((l) => l.isFavorite).toList();

  List<CampusInfoModel> get notices =>
      _campusInfo.where((i) => i.type == 'notice').toList();
  List<CampusInfoModel> get events =>
      _campusInfo.where((i) => i.type == 'event').toList();
  List<CampusInfoModel> get busRoutes =>
      _campusInfo.where((i) => i.type == 'bus').toList();
  List<CampusInfoModel> get emergencyContacts =>
      _campusInfo.where((i) => i.type == 'emergency').toList();

  List<CampusLocationModel> locationsByType(String type) =>
      _locations.where((l) => l.type == type).toList();

  List<FacultyMemberModel> get filteredFaculty {
    if (_searchQuery.isEmpty) return _faculty;
    final q = _searchQuery.toLowerCase();
    return _faculty.where((f) =>
      f.name.toLowerCase().contains(q) ||
      f.department.toLowerCase().contains(q) ||
      f.designation.toLowerCase().contains(q),
    ).toList();
  }

  List<CampusLocationModel> get filteredLocations {
    if (_searchQuery.isEmpty) return _locations;
    final q = _searchQuery.toLowerCase();
    return _locations.where((l) =>
      l.name.toLowerCase().contains(q) ||
      l.type.toLowerCase().contains(q) ||
      l.description.toLowerCase().contains(q),
    ).toList();
  }

  void setSection(String section) {
    _activeSection = section;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  Future<void> toggleFacultyFavorite(FacultyMemberModel faculty) async {
    final updated = faculty.copyWith(isFavorite: !faculty.isFavorite);
    await HiveService.instance.facultyBox.put(updated.id, updated);
    _loadData();
  }

  Future<void> toggleLocationFavorite(CampusLocationModel location) async {
    final updated = location.copyWith(isFavorite: !location.isFavorite);
    await HiveService.instance.campusLocationsBox.put(updated.id, updated);
    _loadData();
  }

  void _loadData() {
    final locationBox = HiveService.instance.campusLocationsBox;
    final facultyBox = HiveService.instance.facultyBox;
    final infoBox = HiveService.instance.campusInfoBox;

    if (locationBox.isEmpty) {
      final defaults = CampusLocationModel.getDefaultLocations();
      for (var loc in defaults) {
        locationBox.put(loc.id, loc);
      }
      _locations = defaults;
    } else {
      _locations = locationBox.values.toList();
    }

    if (facultyBox.isEmpty) {
      final defaults = FacultyMemberModel.getDefaultFaculty();
      for (var fac in defaults) {
        facultyBox.put(fac.id, fac);
      }
      _faculty = defaults;
    } else {
      _faculty = facultyBox.values.toList();
    }

    if (infoBox.isEmpty) {
      final defaults = CampusInfoModel.getDefaultItems();
      for (var info in defaults) {
        infoBox.put(info.id, info);
      }
      _campusInfo = defaults;
    } else {
      _campusInfo = infoBox.values.toList();
    }

    notifyListeners();
  }
}
