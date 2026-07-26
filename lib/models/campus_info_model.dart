import 'package:hive/hive.dart';

part 'campus_info_model.g.dart';

@HiveType(typeId: 14)
class CampusInfoModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String body;

  @HiveField(3)
  final String type; // 'notice', 'event', 'bus', 'emergency'

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String metadata; // route name for bus / phone for emergency / location for events

  CampusInfoModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.date,
    this.metadata = '',
  });

  static List<CampusInfoModel> getDefaultItems() {
    final now = DateTime.now();
    return [
      // Notices
      CampusInfoModel(id: 'info_1', title: 'Mid-Term Exam Schedule Released', type: 'notice',
        body: 'Mid-term examinations for all semesters will be held from Aug 10–20, 2026. Check the academic portal for hall assignments.',
        date: now.subtract(const Duration(days: 1))),
      CampusInfoModel(id: 'info_2', title: 'Campus Wi-Fi Upgrade Scheduled', type: 'notice',
        body: 'Network maintenance will be performed on Saturday, Aug 3. Internet services will be intermittent from 10 PM to 6 AM.',
        date: now.subtract(const Duration(days: 2))),
      CampusInfoModel(id: 'info_3', title: 'Scholarship Application Open', type: 'notice',
        body: 'Merit scholarship applications for 2026-27 are now open. Deadline: Sep 1st, 2026. Visit the scholarship office for forms.',
        date: now.subtract(const Duration(days: 3))),
      // Events
      CampusInfoModel(id: 'info_4', title: 'Tech Fest 2026 – CampusCon', type: 'event',
        body: 'Annual technology festival featuring hackathons, project showcases, seminars, and cultural programs.', 
        date: now.add(const Duration(days: 7)), metadata: 'Main Auditorium'),
      CampusInfoModel(id: 'info_5', title: 'IEEE Student Branch Seminar', type: 'event',
        body: 'IEEE Chapter presents: "Future of AI in Robotics" – Free for all registered students.',
        date: now.add(const Duration(days: 3)), metadata: 'Room 401, Block A'),
      CampusInfoModel(id: 'info_6', title: 'Career Fair – Industry Connect', type: 'event',
        body: '30+ tech companies joining for on-campus recruitment and internship opportunities.',
        date: now.add(const Duration(days: 14)), metadata: 'Convention Hall'),
      // Bus Routes
      CampusInfoModel(id: 'info_7', title: 'Route 01 – City Center', type: 'bus',
        body: 'Departure: 7:30 AM, 12:00 PM, 5:30 PM. Return: 9:00 AM, 2:00 PM, 7:00 PM.',
        date: now, metadata: 'City Center → University Gate A'),
      CampusInfoModel(id: 'info_8', title: 'Route 02 – North Suburb', type: 'bus',
        body: 'Departure: 8:00 AM, 12:30 PM, 6:00 PM. Return: 9:30 AM, 2:30 PM, 7:30 PM.',
        date: now, metadata: 'North Suburb → Gate B'),
      CampusInfoModel(id: 'info_9', title: 'Route 03 – East District', type: 'bus',
        body: 'Departure: 7:45 AM, 1:00 PM, 5:45 PM. Return: 9:15 AM, 2:15 PM, 7:15 PM.',
        date: now, metadata: 'East District → Gate A'),
      // Emergency Contacts
      CampusInfoModel(id: 'info_10', title: 'Campus Security Office', type: 'emergency',
        body: '24/7 emergency security response. Report any incident immediately.', 
        date: now, metadata: '+880-1234-9999'),
      CampusInfoModel(id: 'info_11', title: 'Medical Center & First Aid', type: 'emergency',
        body: 'On-campus clinic available during office hours. For emergencies call immediately.', 
        date: now, metadata: '+880-1234-9911'),
      CampusInfoModel(id: 'info_12', title: 'Fire Safety & Emergency', type: 'emergency',
        body: 'In case of fire, evacuate immediately and contact emergency services.', 
        date: now, metadata: '+880-1234-9119'),
      CampusInfoModel(id: 'info_13', title: 'Dean of Student Affairs', type: 'emergency',
        body: 'For student welfare emergencies, harassment, or disciplinary issues.', 
        date: now, metadata: '+880-1234-8888'),
    ];
  }
}
