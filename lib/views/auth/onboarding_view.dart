import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_dimensions.dart';
import '../../controllers/app_state_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_logo.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/academic_controller.dart';
import '../../controllers/routine_controller.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final _nameController = TextEditingController();
  final _rollController = TextEditingController();
  final _departmentController = TextEditingController();
  final _universityController = TextEditingController();

  String _institutionType = 'university';
  String? _selectedSemester;

  // File-picked bytes (web compatible)
  Uint8List? _profileImageBytes;
  Uint8List? _logoImageBytes;

  // URL-based images (alternative to file picker)
  final _profileUrlController = TextEditingController();
  final _logoUrlController = TextEditingController();

  final List<OnboardingSlide> _slides = [
    const OnboardingSlide(
      icon: Icons.calendar_month_rounded,
      title: 'Smart Academic Organizer',
      subtitle:
          'Effortlessly track your class routines, subjects, exams, and attendance in one place.',
    ),
    const OnboardingSlide(
      icon: Icons.description_rounded,
      title: 'Rich Notes & Timer',
      subtitle:
          'Write study notes with rich text formatting, track study sessions, and visualize progress.',
    ),
    const OnboardingSlide(
      icon: Icons.assignment_turned_in_rounded,
      title: 'Cover Pages & Expenses',
      subtitle:
          'Generate PDF cover pages for assignments and keep track of your semester budget.',
    ),
  ];

  List<String> get _semesterOptions {
    switch (_institutionType) {
      case 'school':
        return List.generate(12, (i) => 'Class ${i + 1}');
      case 'college':
        return ['1st Year', '2nd Year'];
      case 'university':
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

  String get _semesterLabel {
    switch (_institutionType) {
      case 'school':
        return 'Class / Grade';
      case 'college':
        return 'Year / Class';
      default:
        return 'Semester';
    }
  }

  String get _rollLabel {
    switch (_institutionType) {
      case 'school':
        return 'Roll Number';
      case 'college':
        return 'Roll / Reg. Number';
      default:
        return 'Student ID / Roll';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _rollController.dispose();
    _departmentController.dispose();
    _universityController.dispose();
    _profileUrlController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _profileImageBytes = result.files.single.bytes;
      });
    }
  }

  Future<void> _pickLogoImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _logoImageBytes = result.files.single.bytes;
      });
    }
  }

  void _finishOnboarding() async {
    // Use first option as default if user didn't pick
    final defaultSemester = _semesterOptions.first;
    final semester = _selectedSemester ?? defaultSemester;

    final name = _nameController.text.trim();
    final dept = _departmentController.text.trim();
    final uni = _universityController.text.trim();
    final roll = _rollController.text.trim();

    // Resolve image URLs: prefer pasted URL > file-picked bytes
    final pastedProfileUrl = _profileUrlController.text.trim();
    final pastedLogoUrl = _logoUrlController.text.trim();

    String profileUrl = '';
    String logoUrl = '';

    if (pastedProfileUrl.isNotEmpty) {
      profileUrl = pastedProfileUrl;
    } else if (_profileImageBytes != null) {
      profileUrl =
          'data:image/png;base64,${_encodeBase64(_profileImageBytes!)}';
    }
    if (pastedLogoUrl.isNotEmpty) {
      logoUrl = pastedLogoUrl;
    } else if (_logoImageBytes != null) {
      logoUrl = 'data:image/png;base64,${_encodeBase64(_logoImageBytes!)}';
    }

    final homeCtrl = context.read<HomeController>();
    await homeCtrl.updateProfile(
      name: name,
      department: dept,
      university: uni,
      semester: semester,
      section: roll,
      group: '',
      institutionType: _institutionType,
      profilePictureUrl: profileUrl.isEmpty ? null : profileUrl,
      institutionLogoUrl: logoUrl.isEmpty ? null : logoUrl,
    );

    if (mounted) {
      context.read<AcademicController>().syncWithProfile();
      context.read<RoutineController>().syncWithProfile();
    }

    if (!mounted) return;
    await context.read<AppStateController>().setFirstRunComplete();

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppLogo(size: 36),
                  if (_currentIndex < _slides.length)
                    TextButton(
                      onPressed: () => _pageController.animateToPage(
                        _slides.length,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: const Text('Skip'),
                    ),
                ],
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length + 1,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  if (index < _slides.length) {
                    final slide = _slides[index];
                    return Padding(
                      padding: const EdgeInsets.all(AppDimensions.xl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppDimensions.xl),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primaryContainer,
                            ),
                            child: Icon(
                              slide.icon,
                              size: 80,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.xl),
                          Text(
                            slide.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimensions.md),
                          Text(
                            slide.subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  // ── Profile setup slide ─────────────────────────────────
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Setup Your Profile',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        Text(
                          'Personalize your CampusOne experience',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.lg),

                        // ── Avatar & URL inputs ──
                        _ImagePickerWithUrl(
                          label: 'Profile Photo',
                          icon: Icons.person_rounded,
                          imageBytes: _profileImageBytes,
                          urlController: _profileUrlController,
                          onPickFile: _pickProfileImage,
                        ),
                        const SizedBox(height: AppDimensions.md),
                        _ImagePickerWithUrl(
                          label: 'Institution Logo',
                          icon: Icons.account_balance_rounded,
                          imageBytes: _logoImageBytes,
                          urlController: _logoUrlController,
                          onPickFile: _pickLogoImage,
                        ),
                        const SizedBox(height: AppDimensions.lg),

                        // ── Institution Type ──
                        DropdownButtonFormField<String>(
                          value: _institutionType,
                          decoration: InputDecoration(
                            labelText: 'Institution Type',
                            prefixIcon: const Icon(
                              Icons.account_balance_rounded,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd,
                              ),
                            ),
                          ),
                          dropdownColor: theme.colorScheme.surface,
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
                                _selectedSemester =
                                    null; // reset on type change
                              });
                            }
                          },
                        ),
                        const SizedBox(height: AppDimensions.md),

                        // ── Student Name ──
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Student Name',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.md),

                        // ── Roll / Student ID ──
                        TextField(
                          controller: _rollController,
                          decoration: InputDecoration(
                            labelText: _rollLabel,
                            prefixIcon: const Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.md),

                        // ── Semester / Class / Year (dynamic dropdown) ──
                        DropdownButtonFormField<String>(
                          value: _selectedSemester,
                          decoration: InputDecoration(
                            labelText: _semesterLabel,
                            prefixIcon: const Icon(Icons.layers_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd,
                              ),
                            ),
                          ),
                          dropdownColor: theme.colorScheme.surface,
                          hint: Text('Select $_semesterLabel'),
                          items: _semesterOptions.map((opt) {
                            return DropdownMenuItem(
                              value: opt,
                              child: Text(opt),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedSemester = val);
                          },
                        ),
                        const SizedBox(height: AppDimensions.md),

                        // ── Department / Stream ──
                        TextField(
                          controller: _departmentController,
                          decoration: InputDecoration(
                            labelText: _institutionType == 'school'
                                ? 'Class Group (e.g. Science, Arts)'
                                : _institutionType == 'college'
                                ? 'Group / Stream (e.g. Science, Commerce)'
                                : 'Department / Major',
                            prefixIcon: const Icon(Icons.school_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.md),

                        // ── Institution Name ──
                        TextField(
                          controller: _universityController,
                          decoration: InputDecoration(
                            labelText: _institutionType == 'school'
                                ? 'School Name'
                                : _institutionType == 'college'
                                ? 'College Name'
                                : 'University Name',
                            hintText: _institutionType == 'school'
                                ? 'e.g. St. Joseph School'
                                : _institutionType == 'college'
                                ? 'e.g. City College'
                                : 'e.g. State University',
                            prefixIcon: const Icon(Icons.business_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.xl),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Pagination indicator and control buttons
            Padding(
              padding: const EdgeInsets.all(AppDimensions.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _slides.length + 1,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        height: 8,
                        width: _currentIndex == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      if (_currentIndex < _slides.length) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _finishOnboarding();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLg,
                        ),
                      ),
                    ),
                    child: Text(
                      _currentIndex < _slides.length ? 'Next' : 'Get Started',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Combined image picker (file + URL) ────────────────────────────────────────

class _ImagePickerWithUrl extends StatelessWidget {
  final String label;
  final IconData icon;
  final Uint8List? imageBytes;
  final TextEditingController urlController;
  final VoidCallback onPickFile;

  const _ImagePickerWithUrl({
    required this.label,
    required this.icon,
    required this.imageBytes,
    required this.urlController,
    required this.onPickFile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Build preview: URL input takes priority over file bytes
    ImageProvider? preview;
    final urlText = urlController.text.trim();
    if (urlText.isNotEmpty) {
      preview = _buildImageProvider(urlText);
    } else if (imageBytes != null) {
      preview = MemoryImage(imageBytes!);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Circle avatar preview + file picker tap
        GestureDetector(
          onTap: onPickFile,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primaryContainer,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  image: preview != null
                      ? DecorationImage(image: preview, fit: BoxFit.cover)
                      : null,
                ),
                child: preview == null
                    ? Icon(icon, size: 28, color: theme.colorScheme.primary)
                    : null,
              ),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // URL input
        Expanded(
          child: TextField(
            controller: urlController,
            decoration: InputDecoration(
              labelText: '$label URL (optional)',
              hintText: 'https://example.com/image.jpg',
              prefixIcon: const Icon(Icons.link_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              helperText: 'Tap circle to upload file, or paste URL',
            ),
          ),
        ),
      ],
    );
  }

  ImageProvider? _buildImageProvider(String source) {
    if (source.startsWith('data:image')) {
      return null;
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
}

class OnboardingSlide {
  final IconData icon;
  final String title;
  final String subtitle;

  const OnboardingSlide({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
