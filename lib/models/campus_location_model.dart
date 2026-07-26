import 'package:hive/hive.dart';

part 'campus_location_model.g.dart';

@HiveType(typeId: 12)
class CampusLocationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String type; // 'department', 'building', 'lab', 'library', 'cafeteria'

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String floor;

  @HiveField(5)
  final String contactNumber;

  @HiveField(6)
  final String openHours;

  @HiveField(7)
  final bool isFavorite;

  @HiveField(8)
  final int colorHex;

  CampusLocationModel({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.floor,
    required this.contactNumber,
    required this.openHours,
    this.isFavorite = false,
    required this.colorHex,
  });

  CampusLocationModel copyWith({
    bool? isFavorite,
  }) {
    return CampusLocationModel(
      id: id, name: name, type: type, description: description,
      floor: floor, contactNumber: contactNumber, openHours: openHours,
      isFavorite: isFavorite ?? this.isFavorite, colorHex: colorHex,
    );
  }

  static List<CampusLocationModel> getDefaultLocations() {
    return [
      // Departments
      CampusLocationModel(id: 'loc_1', name: 'Dept. of CSE', type: 'department',
        description: 'Computer Science & Engineering Department', floor: '3rd Floor, Block A',
        contactNumber: '+880-1234-5678', openHours: 'Sun–Thu: 9 AM – 5 PM', colorHex: 0xFF0061A4),
      CampusLocationModel(id: 'loc_2', name: 'Dept. of EEE', type: 'department',
        description: 'Electrical & Electronic Engineering', floor: '2nd Floor, Block B',
        contactNumber: '+880-1234-5679', openHours: 'Sun–Thu: 9 AM – 5 PM', colorHex: 0xFF5856D6),
      CampusLocationModel(id: 'loc_3', name: 'Dept. of BBA', type: 'department',
        description: 'Business Administration', floor: '1st Floor, Block C',
        contactNumber: '+880-1234-5680', openHours: 'Sun–Thu: 9 AM – 5 PM', colorHex: 0xFF2E7D32),
      // Labs
      CampusLocationModel(id: 'loc_4', name: 'Computer Lab 1', type: 'lab',
        description: '60-seat PC Lab with high-speed internet', floor: '4th Floor, Block A',
        contactNumber: '+880-1234-5681', openHours: 'Sun–Thu: 8 AM – 8 PM', colorHex: 0xFFED6C02),
      CampusLocationModel(id: 'loc_5', name: 'Physics Lab', type: 'lab',
        description: 'Advanced Physics & Chemistry Lab', floor: '2nd Floor, Block D',
        contactNumber: '+880-1234-5682', openHours: 'Sun–Thu: 9 AM – 4 PM', colorHex: 0xFF6B5778),
      // Library
      CampusLocationModel(id: 'loc_6', name: 'Central Library', type: 'library',
        description: '50,000+ books & digital resources', floor: 'Ground Floor, Block E',
        contactNumber: '+880-1234-5683', openHours: 'Sat–Thu: 8 AM – 9 PM', colorHex: 0xFFBA1A1A,
        isFavorite: true),
      // Cafeteria
      CampusLocationModel(id: 'loc_7', name: 'Main Cafeteria', type: 'cafeteria',
        description: 'Full-service cafeteria with 300 seats', floor: 'Ground Floor, Main Building',
        contactNumber: '+880-1234-5684', openHours: 'Daily: 7 AM – 9 PM', colorHex: 0xFF0061A4),
      CampusLocationModel(id: 'loc_8', name: 'Faculty Lounge & Cafe', type: 'cafeteria',
        description: 'Light refreshments & beverages', floor: '3rd Floor, Admin Block',
        contactNumber: '+880-1234-5685', openHours: 'Sun–Thu: 9 AM – 5 PM', colorHex: 0xFF2E7D32),
      // Buildings
      CampusLocationModel(id: 'loc_9', name: 'Academic Block A', type: 'building',
        description: 'Main academic building with 40 classrooms', floor: 'All Floors',
        contactNumber: '+880-1234-5686', openHours: 'Daily: 7 AM – 10 PM', colorHex: 0xFF5856D6),
      CampusLocationModel(id: 'loc_10', name: 'Admin & Registrar', type: 'building',
        description: 'Administration offices & student services', floor: '1st Floor, Admin Block',
        contactNumber: '+880-1234-5687', openHours: 'Sun–Thu: 9 AM – 4 PM', colorHex: 0xFF535F70),
    ];
  }
}


