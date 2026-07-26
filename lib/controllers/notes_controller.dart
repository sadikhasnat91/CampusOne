import 'package:flutter/foundation.dart';
import '../database/hive_service.dart';
import '../models/note_folder_model.dart';
import '../models/note_model.dart';

class NotesController extends ChangeNotifier {
  List<NoteModel> _notes = [];
  List<NoteFolderModel> _folders = [];

  String _searchQuery = '';
  String? _selectedFolderId;
  String? _selectedTag;
  bool _showFavoritesOnly = false;

  NotesController() {
    _loadData();
  }

  // Getters
  List<NoteFolderModel> get folders => _folders;
  String get searchQuery => _searchQuery;
  String? get selectedFolderId => _selectedFolderId;
  String? get selectedTag => _selectedTag;
  bool get showFavoritesOnly => _showFavoritesOnly;

  List<NoteModel> get filteredNotes {
    return _notes.where((note) {
      if (_showFavoritesOnly && !note.isFavorite) return false;
      if (_selectedFolderId != null && note.folderId != _selectedFolderId) return false;
      if (_selectedTag != null && !note.tags.contains(_selectedTag)) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return note.title.toLowerCase().contains(q) ||
            note.tags.any((t) => t.toLowerCase().contains(q));
      }
      return true;
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  List<NoteModel> get recentNotes => _notes
      .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  List<NoteModel> get favoriteNotes => _notes.where((n) => n.isFavorite).toList();

  List<String> get allTags {
    final tagSet = <String>{};
    for (var note in _notes) {
      tagSet.addAll(note.tags);
    }
    return tagSet.toList();
  }

  NoteFolderModel? getFolderById(String id) {
    try {
      return _folders.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  void _loadData() {
    final noteBox = HiveService.instance.notesBox;
    final folderBox = HiveService.instance.foldersBox;

    if (folderBox.isEmpty) {
      final defaults = NoteFolderModel.getDefaultFolders();
      for (var f in defaults) {
        folderBox.put(f.id, f);
      }
      _folders = defaults;
    } else {
      _folders = folderBox.values.toList();
    }

    if (noteBox.isEmpty) {
      final defaults = NoteModel.getDefaultNotes();
      for (var n in defaults) {
        noteBox.put(n.id, n);
      }
      _notes = defaults;
    } else {
      _notes = noteBox.values.toList();
    }

    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setFolderFilter(String? folderId) {
    _selectedFolderId = _selectedFolderId == folderId ? null : folderId;
    notifyListeners();
  }

  void setTagFilter(String? tag) {
    _selectedTag = _selectedTag == tag ? null : tag;
    notifyListeners();
  }

  void toggleFavoritesOnly() {
    _showFavoritesOnly = !_showFavoritesOnly;
    notifyListeners();
  }

  Future<void> saveNote(NoteModel note) async {
    await HiveService.instance.notesBox.put(note.id, note);
    _loadData();
  }

  Future<void> toggleFavorite(NoteModel note) async {
    final updated = note.copyWith(isFavorite: !note.isFavorite);
    await HiveService.instance.notesBox.put(updated.id, updated);
    _loadData();
  }

  Future<void> deleteNote(String id) async {
    await HiveService.instance.notesBox.delete(id);
    _loadData();
  }

  Future<void> addFolder(NoteFolderModel folder) async {
    await HiveService.instance.foldersBox.put(folder.id, folder);
    _loadData();
  }
}
