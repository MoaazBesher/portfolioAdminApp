import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/app_models.dart';
import '../../../providers/data_provider.dart';
import '../../components/generic_list_tab.dart';
import '../../components/custom_text_field.dart';
import '../../components/icon_picker_field.dart';

class ExperienceTab extends StatelessWidget {
  const ExperienceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, provider, child) {
        return GenericListTab<Experience>(
          title: 'Experience Timeline',
          emptyMessage: 'No experience listed yet.',
          items: provider.experience,
          onAddPressed: () => _showExperienceForm(context, null),
          itemBuilder: (ctx, exp) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(exp.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${exp.company} • ${exp.period}', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 13)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: () => _showExperienceForm(context, exp),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () async {
                      if (await showConfirmDelete(context, exp.title)) {
                        provider.deleteExperience(exp.id);
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

  void _showExperienceForm(BuildContext context, Experience? existingExp) {
    final formKey = GlobalKey<FormState>();
    final provider = context.read<DataProvider>();

    String title = existingExp?.title ?? '';
    String company = existingExp?.company ?? '';
    String period = existingExp?.period ?? '';
    String icon = existingExp?.icon ?? 'briefcase';
    String description = existingExp?.description ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
                Text(existingExp == null ? 'Add Experience' : 'Edit Experience', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                CustomTextField(label: 'Job Title', initialValue: title, isRequired: true, onSaved: (v) => title = v!),
                CustomTextField(label: 'Company Name', initialValue: company, isRequired: true, onSaved: (v) => company = v!),
                CustomTextField(label: 'Time Period (ex: 2021 - Present)', initialValue: period, isRequired: true, onSaved: (v) => period = v!),
                IconPickerField(label: 'Select Display Icon', initialValue: icon, onChanged: (v) => icon = v),
                CustomTextField(label: 'Job Description', initialValue: description, maxLines: 5, onSaved: (v) => description = v!),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          provider.saveExperience(Experience(
                            id: existingExp?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                            title: title, company: company, period: period, icon: icon, description: description,
                          ));
                          Navigator.pop(ctx);
                        }
                      },
                      child: const Text('Save Event'),
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
