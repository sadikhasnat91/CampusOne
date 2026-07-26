import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:campusone/main.dart';
import 'package:campusone/database/hive_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    await HiveService.instance.initHive(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets('CampusOne app builds test', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusOneApp());
    expect(find.byType(CampusOneApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}
