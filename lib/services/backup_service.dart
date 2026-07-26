import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

class BackupService {
  static Future<void> createBackup() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${appDir.path}/backups');
      if (!await backupDir.exists()) {
        await backupDir.create();
      }

      final zipFile = File('${backupDir.path}/campusone_backup_${DateTime.now().millisecondsSinceEpoch}.campusone');
      
      final encoder = ZipFileEncoder();
      encoder.create(zipFile.path);
      
      // Find hive files
      final files = appDir.listSync();
      for (var file in files) {
        if (file is File && file.path.endsWith('.hive')) {
          encoder.addFile(file);
        }
      }
      encoder.close();

      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(zipFile.path)], text: 'CampusOne Data Backup');
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  static Future<bool> restoreBackup() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Android might not resolve custom extensions well without any
      );

      if (result != null && result.files.single.path != null) {
        final backupFile = File(result.files.single.path!);
        
        final bytes = await backupFile.readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        
        final appDir = await getApplicationDocumentsDirectory();
        
        for (final file in archive) {
          final filename = file.name;
          if (file.isFile && filename.endsWith('.hive')) {
            final data = file.content as List<int>;
            File('${appDir.path}/$filename')
              ..createSync(recursive: true)
              ..writeAsBytesSync(data);
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to restore backup: $e');
    }
  }
}
