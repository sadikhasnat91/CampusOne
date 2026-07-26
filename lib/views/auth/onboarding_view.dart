import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_dimensions.dart';
import '../../controllers/app_state_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_logo.dart';
import '../../database/hive_service.dart';
import '../../constants/hive_box_keys.dart';
import '../../models/student_profile_model.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _universityController = TextEditingController();

  final List<OnboardingSlide> _slides = [
    const OnboardingSlide(
      icon: Icons.calendar_month_rounded,
      title: 'Smart Academic Organizer',
      subtitle: 'Effortlessly track your class routines, subjects, exams, and attendance in one place.',
    ),
    const OnboardingSlide(
      icon: Icons.description_rounded,
      title: 'Rich Notes & Timer',
      subtitle: 'Write study notes with rich text formatting, track study sessions, and visualize progress.',
    ),
    const OnboardingSlide(
      icon: Icons.assignment_turned_in_rounded,
      title: 'Cover Pages & Expenses',
      subtitle: 'Generate PDF cover pages for assignments and keep track of your semester budget.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _departmentController.dispose();
    _universityController.dispose();
    super.dispose();
  }

  void _finishOnboarding() async {
    final profileBox = HiveService.instance.userProfileBox;
    final profile = StudentProfileModel(
      name: _nameController.text.trim().isEmpty ? 'Campus Student' : _nameController.text.trim(),
      department: _departmentController.text.trim().isEmpty ? 'Computer Science' : _departmentController.text.trim(),
      university: _universityController.text.trim().isEmpty ? 'Campus University' : _universityController.text.trim(),
      semester: '1st Semester',
      section: 'A',
      group: 'Group 1',
      profilePictureUrl: '',
    );
    await profileBox.put(HiveBoxKeys.studentProfileKey, profile);

    if (!mounted) return;
    await context.read<AppStateController>().setFirstRunComplete();

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
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

                  // Profile setup slide
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(Icons.person_pin_rounded, size: 70, color: theme.colorScheme.primary),
                        const SizedBox(height: AppDimensions.md),
                        Text(
                          'Setup Your Student Profile',
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        Text(
                          'Personalize your CampusOne experience',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.xl),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Student Name',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.md),
                        TextField(
                          controller: _departmentController,
                          decoration: InputDecoration(
                            labelText: 'Department',
                            prefixIcon: const Icon(Icons.school_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.md),
                        TextField(
                          controller: _universityController,
                          decoration: InputDecoration(
                            labelText: 'University',
                            prefixIcon: const Icon(Icons.business_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                          ),
                        ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                      ),
                    ),
                    child: Text(_currentIndex < _slides.length ? 'Next' : 'Get Started'),
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
