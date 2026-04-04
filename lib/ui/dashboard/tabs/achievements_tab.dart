import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/app_models.dart';
import '../../../providers/data_provider.dart';
import '../../components/generic_list_tab.dart';
import '../../components/custom_text_field.dart';
import '../../components/icon_picker_field.dart';

class AchievementsTab extends StatelessWidget {
  const AchievementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, provider, child) {
        return GenericListTab<Achievement>(
          title: 'Achievements',
          emptyMessage: 'No achievements listed.',
          items: provider.achievements,
          onAddPressed: () => _showAchievementForm(context, null),
          itemBuilder: (ctx, ach) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(ach.text, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(ach.date, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 13)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: () => _showAchievementForm(context, ach),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () async {
                      if (await showConfirmDelete(context, ach.text)) {
                        provider.deleteAchievement(ach.id);
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

  void _showAchievementForm(BuildContext context, Achievement? existingAch) {
    final formKey = GlobalKey<FormState>();
    final provider = context.read<DataProvider>();

    String text = existingAch?.text ?? '';
    String date = existingAch?.date ?? '';
    String icon = existingAch?.icon ?? 'trophy';

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
                Text(existingAch == null ? 'Add Achievement' : 'Edit Achievement', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                CustomTextField(label: 'Achievement Description', initialValue: text, isRequired: true, maxLines: 2, onSaved: (v) => text = v!),
                CustomTextField(label: 'Date (e.g. 2023)', initialValue: date, onSaved: (v) => date = v!),
                IconPickerField(label: 'Select Trophy Icon', initialValue: icon, onChanged: (v) => icon = v),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          provider.saveAchievement(Achievement(
                            id: existingAch?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                            text: text, date: date, icon: icon,
                          ));
                          Navigator.pop(ctx);
                        }
                      },
                      child: const Text('Save Achievement'),
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
