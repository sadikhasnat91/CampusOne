import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/hive_service.dart';
import '../models/campus_info_model.dart';
import '../models/campus_location_model.dart';
import '../models/faculty_member_model.dart';
import '../services/notification_service.dart';

class CampusController extends ChangeNotifier {
  List<CampusLocationModel> _locations = [];
  List<FacultyMemberModel> _faculty = [];
  List<CampusInfoModel> _campusInfo = [];

  String _searchQuery = '';
  String _activeSection =
      'Faculty'; // Faculty | Bus | Notices | Events | Emergency | Map

  CampusController() {
    _loadData();
  }

  // Getters
  String get activeSection => _activeSection;
  String get searchQuery => _searchQuery;

  List<FacultyMemberModel> get allFaculty => _faculty;
  List<FacultyMemberModel> get favoriteFaculty =>
      _faculty.where((f) => f.isFavorite).toList();

  List<CampusLocationModel> get allLocations => _locations;
  List<CampusLocationModel> get favoriteLocations =>
      _locations.where((l) => l.isFavorite).toList();

  List<CampusInfoModel> get notices =>
      _campusInfo.where((i) => i.type == 'notice').toList();
  List<CampusInfoModel> get events =>
      _campusInfo.where((i) => i.type == 'event').toList();
  List<CampusInfoModel> get busRoutes =>
      _campusInfo.where((i) => i.type == 'bus').toList();
  List<CampusInfoModel> get busReminders {
    final reminders = _campusInfo
        .where((i) => i.type == 'bus_reminder')
        .toList();
    reminders.sort((a, b) => a.date.compareTo(b.date));
    return reminders;
  }

  List<CampusInfoModel> get emergencyContacts =>
      _campusInfo.where((i) => i.type == 'emergency').toList();

  List<CampusLocationModel> locationsByType(String type) =>
      _locations.where((l) => l.type == type).toList();

  List<FacultyMemberModel> get filteredFaculty {
    if (_searchQuery.isEmpty) return _faculty;
    final q = _searchQuery.toLowerCase();
    return _faculty
        .where(
          (f) =>
              f.name.toLowerCase().contains(q) ||
              f.department.toLowerCase().contains(q) ||
              f.designation.toLowerCase().contains(q),
        )
        .toList();
  }

  List<CampusLocationModel> get filteredLocations {
    if (_searchQuery.isEmpty) return _locations;
    final q = _searchQuery.toLowerCase();
    return _locations
        .where(
          (l) =>
              l.name.toLowerCase().contains(q) ||
              l.type.toLowerCase().contains(q) ||
              l.description.toLowerCase().contains(q),
        )
        .toList();
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

  Future<void> addBusReminder({
    required String place,
    required String stop,
    required TimeOfDay departureTime,
    int notifyBeforeMinutes = 10,
  }) async {
    final id = 'bus_reminder_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();
    var nextDeparture = DateTime(
      now.year,
      now.month,
      now.day,
      departureTime.hour,
      departureTime.minute,
    );
    if (!nextDeparture.isAfter(now)) {
      nextDeparture = nextDeparture.add(const Duration(days: 1));
    }

    final format = DateFormat('hh:mm a');
    final displayTime = format.format(nextDeparture);

    final reminder = CampusInfoModel(
      id: id,
      title: 'Bus from $place',
      body: 'Stop: $stop | Departure: $displayTime',
      type: 'bus_reminder',
      date: nextDeparture,
      metadata: '$place -> $stop | notify:$notifyBeforeMinutes',
    );

    await HiveService.instance.campusInfoBox.put(id, reminder);

    await NotificationService.instance.scheduleDailyNotification(
      id: _notificationIdFor(id),
      title: 'Bus Reminder',
      body: '$place to $stop at $displayTime',
      hour: departureTime.hour,
      minute: departureTime.minute,
      remindBeforeMinutes: notifyBeforeMinutes,
      payload: id,
    );

    _loadData();
  }

  Future<void> updateBusReminder({
    required String reminderId,
    required String place,
    required String stop,
    required TimeOfDay departureTime,
    int notifyBeforeMinutes = 10,
  }) async {
    final now = DateTime.now();
    var nextDeparture = DateTime(
      now.year,
      now.month,
      now.day,
      departureTime.hour,
      departureTime.minute,
    );
    if (!nextDeparture.isAfter(now)) {
      nextDeparture = nextDeparture.add(const Duration(days: 1));
    }

    final format = DateFormat('hh:mm a');
    final displayTime = format.format(nextDeparture);

    final updated = CampusInfoModel(
      id: reminderId,
      title: 'Bus from $place',
      body: 'Stop: $stop | Departure: $displayTime',
      type: 'bus_reminder',
      date: nextDeparture,
      metadata: '$place -> $stop | notify:$notifyBeforeMinutes',
    );

    await HiveService.instance.campusInfoBox.put(reminderId, updated);

    final notificationId = _notificationIdFor(reminderId);
    await NotificationService.instance.cancelNotification(notificationId);
    await NotificationService.instance.scheduleDailyNotification(
      id: notificationId,
      title: 'Bus Reminder',
      body: '$place to $stop at $displayTime',
      hour: departureTime.hour,
      minute: departureTime.minute,
      remindBeforeMinutes: notifyBeforeMinutes,
      payload: reminderId,
    );

    _loadData();
  }

  Future<void> deleteBusReminder(String id) async {
    await HiveService.instance.campusInfoBox.delete(id);
    await NotificationService.instance.cancelNotification(
      _notificationIdFor(id),
    );
    _loadData();
  }

  Future<void> addEmergencyContact({
    required String name,
    required String phone,
    String note = '',
  }) async {
    final id = 'emg_${DateTime.now().millisecondsSinceEpoch}';
    final contact = CampusInfoModel(
      id: id,
      title: name,
      body: note.isEmpty ? 'Tap to call' : note,
      type: 'emergency',
      date: DateTime.now(),
      metadata: phone,
    );

    await HiveService.instance.campusInfoBox.put(id, contact);
    _loadData();
  }

  Future<void> deleteEmergencyContact(String id) async {
    await HiveService.instance.campusInfoBox.delete(id);
    _loadData();
  }

  int _notificationIdFor(String reminderId) {
    return reminderId.hashCode & 0x7fffffff;
  }

  void _loadData() {
    final locationBox = HiveService.instance.campusLocationsBox;
    final facultyBox = HiveService.instance.facultyBox;
    final infoBox = HiveService.instance.campusInfoBox;

    _locations = locationBox.values.toList();
    _faculty = facultyBox.values.toList();
    _campusInfo = infoBox.values.toList();

    notifyListeners();
  }
}
