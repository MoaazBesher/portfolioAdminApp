import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/app_models.dart';
import '../../../providers/data_provider.dart';
import '../../components/generic_list_tab.dart';
import '../../components/custom_text_field.dart';

class ProjectsTab extends StatelessWidget {
  const ProjectsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, provider, child) {
        return GenericListTab<Project>(
          title: 'Manage Projects',
          emptyMessage: 'No projects yet. Add your first!',
          items: provider.projects,
          onAddPressed: () => _showProjectForm(context, null),
          itemBuilder: (ctx, project) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(project.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(project.category.toUpperCase(), style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: () => _showProjectForm(context, project),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () async {
                      if (await showConfirmDelete(context, project.title)) {
                        provider.deleteProject(project.id);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showProjectForm(BuildContext context, Project? existingProject) {
    final formKey = GlobalKey<FormState>();
    final provider = context.read<DataProvider>();

    String title = existingProject?.title ?? '';
    String description = existingProject?.description ?? '';
    String category = existingProject?.category ?? 'web';
    String link = existingProject?.link ?? '';
    String date = existingProject?.date ?? '';
    bool featured = existingProject?.featured ?? false;
    String techString = (existingProject?.tech ?? []).join(', ');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // For glass effect if we wrap with blur
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16, right: 16, top: 24,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(existingProject == null ? 'Add Project' : 'Edit Project', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                CustomTextField(label: 'Title', initialValue: title, isRequired: true, onSaved: (v) => title = v!),
                CustomTextField(label: 'Category', initialValue: category, onSaved: (v) => category = v!),
                CustomTextField(label: 'Date (e.g. 2023)', initialValue: date, onSaved: (v) => date = v!),
                CustomTextField(label: 'Link', initialValue: link, onSaved: (v) => link = v!),
                CustomTextField(label: 'Technologies (comma separated)', initialValue: techString, onSaved: (v) => techString = v!),
                CustomTextField(label: 'Description', initialValue: description, maxLines: 4, isRequired: true, onSaved: (v) => description = v!),
                SwitchListTile(
                  title: const Text('Featured Project'),
                  value: featured,
                  onChanged: (v) => featured = v,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          final newProject = Project(
                            id: existingProject?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                            title: title,
                            description: description,
                            category: category,
                            link: link,
                            date: date,
                            featured: featured,
                            tech: techString.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                          );
                          provider.saveProject(newProject);
                          Navigator.pop(ctx);
                        }
                      },
                      child: const Text('Save Project'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
