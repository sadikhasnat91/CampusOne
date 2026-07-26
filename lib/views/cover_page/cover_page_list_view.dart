import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../../constants/app_dimensions.dart';
import '../../controllers/cover_page_controller.dart';
import '../../models/cover_page_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_card.dart';

class CoverPageListView extends StatelessWidget {
  const CoverPageListView({super.key});

  void _sharePdf(BuildContext context, CoverPageController ctrl, CoverPageModel template) async {
    final pdfBytes = await ctrl.generatePdf(template);
    await Printing.sharePdf(bytes: pdfBytes, filename: '${template.title.replaceAll(' ', '_')}_Cover.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cover Pages', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final newTemplate = context.read<CoverPageController>().createDefaultTemplate();
          Navigator.pushNamed(context, AppRoutes.coverPageEditor, arguments: newTemplate);
        },
        icon: const Icon(Icons.add),
        label: const Text('Create New'),
      ),
      body: Consumer<CoverPageController>(
        builder: (context, ctrl, child) {
          final templates = ctrl.templates;
          if (templates.isEmpty) {
            return _buildEmptyState(theme);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.md),
            itemCount: templates.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.md),
            itemBuilder: (context, index) {
              final template = templates[index];
              return CustomCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(Icons.description_outlined, color: theme.colorScheme.primary),
                  ),
                  title: Text(template.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${template.courseCode} - ${template.courseName}\nDue: ${template.submissionDate.day}/${template.submissionDate.month}/${template.submissionDate.year}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.coverPageEditor, arguments: template),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined),
                        onPressed: () => _sharePdf(context, ctrl, template),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => ctrl.deleteTemplate(template.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.file_copy_outlined, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: AppDimensions.lg),
            Text(
              'No Cover Pages Yet',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'Create professional assignment cover pages in seconds. Tap the button below to get started.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
