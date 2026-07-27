import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../constants/app_dimensions.dart';
import '../../../models/student_profile_model.dart';
import '../../../widgets/custom_button.dart';

class EditProfileDialog extends StatefulWidget {
  final StudentProfileModel profile;
  final Function(
    String name,
    String department,
    String semester,
    String section,
    String group,
    String university,
    String institutionType,
    String? profilePictureUrl,
    String? institutionLogoUrl,
  )
  onSave;

  const EditProfileDialog({
    super.key,
    required this.profile,
    required this.onSave,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _deptController;
  late TextEditingController _sectionController;
  late TextEditingController _groupController;
  late TextEditingController _uniController;
  late TextEditingController _profileUrlController;
  late TextEditingController _logoUrlController;
  late String _institutionType;
  late String? _selectedSemester;

  Uint8List? _newProfileBytes;
  Uint8List? _newLogoBytes;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _deptController = TextEditingController(text: widget.profile.department);
    _sectionController = TextEditingController(text: widget.profile.section);
    _groupController = TextEditingController(text: widget.profile.group);
    _uniController = TextEditingController(text: widget.profile.university);
    _profileUrlController = TextEditingController(
      text: widget.profile.profilePictureUrl.startsWith('data:image')
          ? ''
          : widget.profile.profilePictureUrl,
    );
    _logoUrlController = TextEditingController(
      text: widget.profile.institutionLogoUrl.startsWith('data:image')
          ? ''
          : widget.profile.institutionLogoUrl,
    );
    _institutionType = widget.profile.institutionType;
    // Try to match saved semester to options list
    final opts = _semesterOptions(_institutionType);
    _selectedSemester = opts.contains(widget.profile.semester)
        ? widget.profile.semester
        : opts.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _deptController.dispose();
    _sectionController.dispose();
    _groupController.dispose();
    _uniController.dispose();
    _profileUrlController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  List<String> _semesterOptions(String type) {
    switch (type) {
      case 'school':
        return List.generate(12, (i) => 'Class ${i + 1}');
      case 'college':
        return ['1st Year', '2nd Year'];
      default:
        return List.generate(8, (i) => '${_ordinal(i + 1)} Semester');
    }
  }

  String _ordinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    switch (n % 10) {
      case 1:
        return '${n}st';
      case 2:
        return '${n}nd';
      case 3:
        return '${n}rd';
      default:
        return '${n}th';
    }
  }

  String _semesterLabel(String type) {
    switch (type) {
      case 'school':
        return 'Class / Grade';
      case 'college':
        return 'Year / Class';
      default:
        return 'Semester';
    }
  }

  Future<void> _pickImage({required bool isProfile}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        if (isProfile) {
          _newProfileBytes = result.files.single.bytes;
        } else {
          _newLogoBytes = result.files.single.bytes;
        }
      });
    }
  }

  String _encodeBase64(Uint8List bytes) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    final output = StringBuffer();
    int i = 0;
    while (i < bytes.length) {
      final b0 = bytes[i++];
      final b1 = i < bytes.length ? bytes[i++] : 0;
      final b2 = i < bytes.length ? bytes[i++] : 0;
      output.write(chars[(b0 >> 2) & 0x3f]);
      output.write(chars[((b0 << 4) | (b1 >> 4)) & 0x3f]);
      output.write(chars[((b1 << 2) | (b2 >> 6)) & 0x3f]);
      output.write(chars[b2 & 0x3f]);
    }
    final result = output.toString();
    final pad = bytes.length % 3;
    if (pad == 1) return '${result.substring(0, result.length - 2)}==';
    if (pad == 2) return '${result.substring(0, result.length - 1)}=';
    return result;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final profileText = _profileUrlController.text.trim();
      final logoText = _logoUrlController.text.trim();

      final profileUrl = _newProfileBytes != null
          ? 'data:image/png;base64,${_encodeBase64(_newProfileBytes!)}'
          : null;
      final logoUrl = _newLogoBytes != null
          ? 'data:image/png;base64,${_encodeBase64(_newLogoBytes!)}'
          : null;

      widget.onSave(
        _nameController.text.trim(),
        _deptController.text.trim(),
        _selectedSemester ?? _semesterOptions(_institutionType).first,
        _sectionController.text.trim(),
        _groupController.text.trim(),
        _uniController.text.trim(),
        _institutionType,
        profileText.isNotEmpty ? profileText : profileUrl,
        logoText.isNotEmpty ? logoText : logoUrl,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opts = _semesterOptions(_institutionType);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Student Profile',
                      style: theme.textTheme.headlineSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.md),

                // ── Image pickers row ──────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildImagePicker(
                      context: context,
                      label: 'Profile Photo',
                      icon: Icons.person_rounded,
                      bytes: _newProfileBytes,
                      urlText: _profileUrlController.text,
                      existingUrl: widget.profile.profilePictureUrl,
                      onTap: () => _pickImage(isProfile: true),
                    ),
                    const SizedBox(width: AppDimensions.xl),
                    _buildImagePicker(
                      context: context,
                      label: 'Institution Logo',
                      icon: Icons.account_balance_rounded,
                      bytes: _newLogoBytes,
                      urlText: _logoUrlController.text,
                      existingUrl: widget.profile.institutionLogoUrl,
                      onTap: () => _pickImage(isProfile: false),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.md),
                TextFormField(
                  controller: _profileUrlController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Profile Photo URL (optional)',
                    prefixIcon: Icon(Icons.link_rounded),
                    hintText: 'https://example.com/profile.jpg',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                TextFormField(
                  controller: _logoUrlController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Institution Logo URL (optional)',
                    prefixIcon: Icon(Icons.link_rounded),
                    hintText: 'https://example.com/logo.png',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),

                // ── Institution type ────────────────────────────────────────
                DropdownButtonFormField<String>(
                  value: _institutionType,
                  decoration: const InputDecoration(
                    labelText: 'Institution Type',
                    prefixIcon: Icon(Icons.account_balance_rounded),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'school',
                      child: Text('School Student'),
                    ),
                    DropdownMenuItem(
                      value: 'college',
                      child: Text('College Student'),
                    ),
                    DropdownMenuItem(
                      value: 'university',
                      child: Text('University Student'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _institutionType = val;
                        _selectedSemester = _semesterOptions(val).first;
                      });
                    }
                  },
                ),
                const SizedBox(height: AppDimensions.md),

                // ── Student Name ──────────────────────────────────────────
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Student Name',
                    prefixIcon: Icon(Icons.person_outline),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter name' : null,
                ),
                const SizedBox(height: AppDimensions.md),

                // ── Section (Roll/ID) ────────────────────────────────────
                TextFormField(
                  controller: _sectionController,
                  decoration: InputDecoration(
                    labelText: _institutionType == 'university'
                        ? 'Section / Roll'
                        : 'Roll Number',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),

                // ── Semester / Class (dynamic dropdown) ─────────────────
                DropdownButtonFormField<String>(
                  value: _selectedSemester,
                  decoration: InputDecoration(
                    labelText: _semesterLabel(_institutionType),
                    prefixIcon: const Icon(Icons.layers_outlined),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: opts.map((opt) {
                    return DropdownMenuItem(value: opt, child: Text(opt));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedSemester = val),
                ),
                const SizedBox(height: AppDimensions.md),

                // ── Department / Group ──────────────────────────────────
                TextFormField(
                  controller: _deptController,
                  decoration: InputDecoration(
                    labelText: _institutionType == 'school'
                        ? 'Class Group (e.g. Science, Arts)'
                        : _institutionType == 'college'
                        ? 'Group / Stream (e.g. Science, Commerce)'
                        : 'Department / Major',
                    prefixIcon: const Icon(Icons.school_outlined),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),

                // ── Group ───────────────────────────────────────────────
                TextFormField(
                  controller: _groupController,
                  decoration: const InputDecoration(
                    labelText: 'Group',
                    prefixIcon: Icon(Icons.groups_outlined),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),

                // ── Institution Name ────────────────────────────────────
                TextFormField(
                  controller: _uniController,
                  decoration: InputDecoration(
                    labelText: _institutionType == 'school'
                        ? 'School Name'
                        : _institutionType == 'college'
                        ? 'College Name'
                        : 'University Name',
                    prefixIcon: const Icon(Icons.account_balance_outlined),
                    hintText: _institutionType == 'school'
                        ? 'e.g. St. Joseph School'
                        : _institutionType == 'college'
                        ? 'e.g. City College'
                        : 'e.g. State University',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),

                CustomButton(
                  label: 'Save Profile Changes',
                  onPressed: _submit,
                  icon: Icons.check,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Uint8List? bytes,
    required String urlText,
    required String existingUrl,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final hasNew = bytes != null;
    final typedUrl = urlText.trim();
    final hasTypedUrl = typedUrl.isNotEmpty;
    final hasExisting = existingUrl.trim().isNotEmpty;

    ImageProvider? imgProvider;
    if (hasNew) {
      imgProvider = MemoryImage(bytes);
    } else if (hasTypedUrl) {
      imgProvider = _buildImageProvider(typedUrl);
    } else if (hasExisting) {
      imgProvider = _buildImageProvider(existingUrl.trim());
    }

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primaryContainer,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  image: imgProvider != null
                      ? DecorationImage(image: imgProvider, fit: BoxFit.cover)
                      : null,
                ),
                child: imgProvider == null
                    ? Icon(icon, size: 32, color: theme.colorScheme.primary)
                    : null,
              ),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, size: 12, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  ImageProvider? _buildImageProvider(String source) {
    if (source.startsWith('data:image')) {
      try {
        final base64Data = source.split(',').last;
        return MemoryImage(_decodeBase64(base64Data));
      } catch (_) {
        return null;
      }
    }

    if (source.startsWith('assets/')) {
      return AssetImage(source);
    }

    final uri = Uri.tryParse(source);
    final scheme = uri?.scheme.toLowerCase();
    if (uri != null && (scheme == 'http' || scheme == 'https')) {
      return NetworkImage(source);
    }

    return null;
  }

  Uint8List _decodeBase64(String base64Str) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    final lookup = <int, int>{};
    for (int i = 0; i < chars.length; i++) {
      lookup[chars.codeUnitAt(i)] = i;
    }
    final padded = base64Str.padRight((base64Str.length + 3) ~/ 4 * 4, '=');
    final output = <int>[];
    for (int i = 0; i < padded.length; i += 4) {
      final a = lookup[padded.codeUnitAt(i)] ?? 0;
      final b = lookup[padded.codeUnitAt(i + 1)] ?? 0;
      final c = lookup[padded.codeUnitAt(i + 2)] ?? 0;
      final d = lookup[padded.codeUnitAt(i + 3)] ?? 0;
      output.add((a << 2) | (b >> 4));
      if (padded[i + 2] != '=') output.add(((b & 0xf) << 4) | (c >> 2));
      if (padded[i + 3] != '=') output.add(((c & 0x3) << 6) | d);
    }
    return Uint8List.fromList(output);
  }
}
