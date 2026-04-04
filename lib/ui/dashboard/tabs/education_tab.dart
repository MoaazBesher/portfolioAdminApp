import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/app_models.dart';
import '../../../providers/data_provider.dart';
import '../../components/generic_list_tab.dart';
import '../../components/custom_text_field.dart';
import '../../components/icon_picker_field.dart';

class EducationTab extends StatelessWidget {
  const EducationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, provider, child) {
        return GenericListTab<Education>(
          title: 'Education Journey',
          emptyMessage: 'No education listed yet.',
          items: provider.education,
          onAddPressed: () => _showEducationForm(context, null),
          itemBuilder: (ctx, ed) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(ed.institution, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${ed.degree} • ${ed.date}', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 13)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: () => _showEducationForm(context, ed),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () async {
                      if (await showConfirmDelete(context, ed.institution)) {
                        provider.deleteEducation(ed.id);
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

  void _showEducationForm(BuildContext context, Education? existingEd) {
    final formKey = GlobalKey<FormState>();
    final provider = context.read<DataProvider>();

    String institution = existingEd?.institution ?? '';
    String degree = existingEd?.degree ?? '';
    String date = existingEd?.date ?? '';
    String icon = existingEd?.icon ?? 'graduation-cap';
    String detailsStr = (existingEd?.details ?? []).join('\n');

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
                Text(existingEd == null ? 'Add Education' : 'Edit Education', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                CustomTextField(label: 'Institution Name', initialValue: institution, isRequired: true, onSaved: (v) => institution = v!),
                CustomTextField(label: 'Degree', initialValue: degree, isRequired: true, onSaved: (v) => degree = v!),
                CustomTextField(label: 'Date (ex: 2018 - 2022)', initialValue: date, isRequired: true, onSaved: (v) => date = v!),
                IconPickerField(label: 'Select Display Icon', initialValue: icon, onChanged: (v) => icon = v),
                CustomTextField(label: 'Details (One per line)', initialValue: detailsStr, maxLines: 5, onSaved: (v) => detailsStr = v!),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          provider.saveEducation(Education(
                            id: existingEd?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                            institution: institution, degree: degree, date: date, icon: icon, 
                            details: detailsStr.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
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
